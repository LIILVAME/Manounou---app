import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/children_service.dart';
import '../../core/widgets/child_avatar.dart';
import '../../core/widgets/elegant_snackbar.dart';
import '../../core/utils/date_helper.dart';

class ChildFormPage extends StatefulWidget {
  final String? childId;

  const ChildFormPage({super.key, this.childId});

  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _infoController = TextEditingController();
  final _imagePicker = ImagePicker();
  DateTime? _birthDate;
  XFile? _selectedPhoto;
  String? _existingPhotoUrl;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Child? _existingChild;
  String? _selectedGender; // 'M' ou 'F'
  bool _photoDeleted = false; // Flag pour savoir si la photo a été supprimée explicitement

  @override
  void initState() {
    super.initState();
    if (widget.childId != null) {
      _loadChild();
    }
  }

  Future<void> _loadChild() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final childrenService = context.read<ChildrenService>();
      final child = await childrenService.getChildById(widget.childId!);
      
      if (child != null && mounted) {
        setState(() {
          _existingChild = child;
          _firstNameController.text = child.firstName;
          _infoController.text = child.info ?? '';
          _birthDate = child.birthDate;
          _existingPhotoUrl = child.photoUrl;
          _selectedGender = child.gender;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await DateHelper.showBirthDatePicker(
      context,
      initialDate: _birthDate,
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedPhoto = pickedFile;
          _photoDeleted = false; // Réinitialiser le flag si on sélectionne une nouvelle photo
          // Ne pas effacer _existingPhotoUrl ici, on en a besoin pour savoir si on doit supprimer
          // La nouvelle photo remplacera l'existante lors de la sauvegarde
        });
      }
    } catch (e) {
      if (mounted) {
        ElegantSnackbar.showError(
          context,
          'Erreur lors de la sélection de la photo: $e',
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_existingPhotoUrl != null || _selectedPhoto != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPhoto = null;
                    _existingPhotoUrl = null;
                    _photoDeleted = true; // Marquer que la photo a été supprimée
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Vérifier la session avant de sauvegarder
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        setState(() {
          _errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        });
        // Rediriger vers login après un court délai
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
        return;
      }

      // Vérifier si le token est expiré et essayer de le rafraîchir
      if (session.isExpired) {
        try {
          await Supabase.instance.client.auth.refreshSession();
        } catch (refreshError) {
          setState(() {
            _errorMessage = 'Session expirée. Veuillez vous reconnecter.';
          });
          // Rediriger vers login après un court délai
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.go('/login');
            }
          });
          return;
        }
      }

      final childrenService = context.read<ChildrenService>();

      if (widget.childId != null) {
        // Mise à jour
        // Si on a sélectionné une nouvelle photo, elle remplace toujours l'existante (avatar ou photo)
        // Si on a supprimé la photo explicitement, on génère un nouvel avatar
        
        await childrenService.updateChild(
          childId: widget.childId!,
          firstName: _firstNameController.text.trim(),
          birthDate: _birthDate,
          info: _infoController.text.trim().isEmpty
              ? null
              : _infoController.text.trim(),
          photoFile: _selectedPhoto, // Nouvelle photo (remplace toujours l'existante)
          deletePhoto: _photoDeleted, // True seulement si l'utilisateur a explicitement supprimé la photo
          gender: _selectedGender,
        );
      } else {
        // Création
        await childrenService.createChild(
          firstName: _firstNameController.text.trim(),
          birthDate: _birthDate,
          info: _infoController.text.trim().isEmpty
              ? null
              : _infoController.text.trim(),
          photoFile: _selectedPhoto,
          gender: _selectedGender,
        );
      }

      if (mounted) {
        // Feedback haptique
        HapticFeedback.mediumImpact();
        
        // Notification de succès
        final isEditing = widget.childId != null;
        ElegantSnackbar.showSuccess(
          context,
          isEditing
              ? '${_firstNameController.text.trim()} a été mis à jour'
              : '${_firstNameController.text.trim()} a été ajouté',
        );
        
        // Recharger la liste des enfants
        await childrenService.loadChildren();
        
        // Retourner à la liste
        if (Navigator.canPop(context)) {
          context.pop();
        } else {
          context.go('/children');
        }
      }
    } catch (e) {
      final errorString = e.toString();
      
      // Détecter les erreurs d'authentification
      if (errorString.contains('Auth') || 
          errorString.contains('session') ||
          errorString.contains('oauth_client_id')) {
        setState(() {
          _errorMessage = 'Session expirée. Veuillez vous reconnecter.';
        });
        
        // Rediriger vers login après un court délai
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      } else {
        // Autres erreurs (réseau, validation, etc.)
        setState(() {
          _errorMessage = 'Erreur lors de l\'enregistrement. Veuillez réessayer.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.childId != null;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Modifier enfant' : 'Ajouter un enfant'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier enfant' : 'Ajouter un enfant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    children: [
                      _selectedPhoto != null
                          ? FutureBuilder<Uint8List?>(
                              future: _selectedPhoto!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return CircleAvatar(
                                    radius: 60,
                                    backgroundImage: MemoryImage(snapshot.data!),
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            )
                          : _existingPhotoUrl != null
                              ? ChildAvatar(
                                  firstName: _firstNameController.text.isNotEmpty
                                      ? _firstNameController.text
                                      : 'E',
                                  photoUrl: _existingPhotoUrl,
                                  gender: _selectedGender,
                                  radius: 60,
                                )
                              : ChildAvatar(
                                  firstName: _firstNameController.text.isNotEmpty
                                      ? _firstNameController.text
                                      : 'E',
                                  gender: _selectedGender,
                                  radius: 60,
                                ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.photo_camera),
                  label: Text(
                    _selectedPhoto != null || _existingPhotoUrl != null
                        ? 'Changer la photo'
                        : 'Ajouter une photo',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Prénom
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le prénom est obligatoire';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Date de naissance
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  child: Text(
                    _birthDate != null
                        ? DateHelper.formatFullDate(_birthDate!)
                        : 'Sélectionner une date',
                    style: TextStyle(
                      color: _birthDate != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Genre
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  prefixIcon: Icon(Icons.accessibility_new),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Garçon')),
                  DropdownMenuItem(value: 'F', child: Text('Fille')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _infoController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[300]!, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Enregistrer' : 'Ajouter'),
              ),
              const SizedBox(height: 8),

              // Bouton Annuler
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (Navigator.canPop(context)) {
                          context.pop();
                        } else {
                          context.go('/children');
                        }
                      },
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

