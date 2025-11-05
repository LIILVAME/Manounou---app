import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

import '../../core/services/documents_service.dart';
import '../../core/services/children_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/widgets/child_avatar.dart';

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedChildId;
  String? _selectedType = 'autre';
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChildrenService>().loadChildren();
    });
  }

  Future<void> _pickFile() async {
    try {
      // Sur web, utiliser uniquement file_picker pour tout (évite les problèmes avec path)
      // Sur mobile, permettre de choisir entre galerie/camera et fichiers
      String? source;
      
      if (kIsWeb) {
        // Sur web, toujours utiliser file_picker
        source = 'file';
      } else {
        // Sur mobile, permettre de choisir
        source = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Choisir une source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galerie photos'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Appareil photo'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Fichiers (PDF, images, etc.)'),
                  onTap: () => Navigator.pop(context, 'file'),
                ),
              ],
            ),
          ),
        );
      }

      if (source == null) return;

      if (source == 'file') {
        // Utiliser file_picker pour tous les types de fichiers
        // Sur web, withData: true est OBLIGATOIRE pour éviter l'accès à path
        FilePickerResult? result;
        try {
          result = await FilePicker.platform.pickFiles(
            type: FileType.any,
            allowMultiple: false,
            withData: true, // Charger les bytes pour web (OBLIGATOIRE)
          );
        } catch (e) {
          // Si file_picker lui-même cause une erreur (accès à path interne)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la sélection du fichier: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (result != null && result.files.isNotEmpty) {
          final originalFile = result.files.single;
          
          // Sur web, file_picker avec withData: true charge toujours les bytes
          // On ne vérifie QUE bytes, jamais path (car path cause une exception sur web)
          if (originalFile.bytes != null) {
            // Créer un PlatformFile sécurisé sans jamais accéder à path sur web
            setState(() {
              if (kIsWeb) {
                // Sur web, créer PlatformFile avec bytes uniquement
                // NE JAMAIS accéder à originalFile.path (même pour vérifier)
                _selectedFile = PlatformFile(
                  name: originalFile.name,
                  size: originalFile.size,
                  bytes: originalFile.bytes,
                );
              } else {
                // Sur mobile, utiliser bytes si disponible, sinon path
                if (originalFile.bytes != null) {
                  // Préférer bytes si disponible
                  _selectedFile = PlatformFile(
                    name: originalFile.name,
                    size: originalFile.size,
                    bytes: originalFile.bytes,
                    path: null, // Ne pas utiliser path si bytes est disponible
                  );
                } else {
                  // Fallback sur path seulement si bytes n'est pas disponible
                  _selectedFile = originalFile;
                }
              }
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Impossible de charger le fichier. Veuillez réessayer.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      } else {
        // Utiliser image_picker pour photos (galerie/camera) - UNIQUEMENT sur mobile
        final picker = image_picker.ImagePicker();
        final imageSource = source == 'camera'
            ? image_picker.ImageSource.camera
            : image_picker.ImageSource.gallery;
        
        final file = await picker.pickImage(source: imageSource);
        if (file != null) {
          // Convertir XFile en PlatformFile
          final bytes = await file.readAsBytes();
          
          // Sur mobile uniquement, on peut accéder à path
          String? filePath;
          try {
            filePath = file.path;
          } catch (e) {
            // Ignorer si path n'est pas disponible
            filePath = null;
          }
          
          setState(() {
            _selectedFile = PlatformFile(
              name: file.name,
              path: filePath,
              size: bytes.length,
              bytes: bytes,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un fichier'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un enfant'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final documentsService = context.read<DocumentsService>();
      await documentsService.uploadDocument(
        _selectedChildId!,
        _selectedFile!,
        _selectedType!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploadé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenService = context.watch<ChildrenService>();

    return Scaffold(
      backgroundColor: FamPlanColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Ajouter un document',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: FamPlanColors.textDark,
          ),
        ),
        elevation: 0,
        backgroundColor: FamPlanColors.backgroundWhite,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sélection enfant
              FamPlanCard(
                backgroundColor: FamPlanColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enfant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedChildId,
                      decoration: InputDecoration(
                        hintText: 'Sélectionner un enfant',
                        filled: true,
                        fillColor: FamPlanColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: childrenService.children.map((child) {
                          return DropdownMenuItem<String>(
                            value: child.id,
                            child: Row(
                              children: [
                                ChildAvatar(
                                  firstName: child.firstName,
                                  photoUrl: child.photoUrl,
                                  radius: 12,
                                ),
                                const SizedBox(width: 12),
                                Text(child.firstName),
                              ],
                            ),
                          );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedChildId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un enfant';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sélection type
              FamPlanCard(
                backgroundColor: FamPlanColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type de document',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        hintText: 'Sélectionner un type',
                        filled: true,
                        fillColor: FamPlanColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'certificat',
                          child: Text('Certificat'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'autorisation',
                          child: Text('Autorisation'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'autre',
                          child: Text('Autre'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sélection fichier
              FamPlanCard(
                backgroundColor: FamPlanColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fichier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FamPlanColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FamPlanColors.tealGreen.withValues(alpha: 0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _selectedFile != null
                                  ? Icons.check_circle
                                  : Icons.add_circle_outline,
                              size: 48,
                              color: _selectedFile != null
                                  ? FamPlanColors.tealGreen
                                  : FamPlanColors.textLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _selectedFile != null
                                  ? _selectedFile!.name
                                  : 'Appuyez pour sélectionner un fichier',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedFile != null
                                    ? FamPlanColors.textDark
                                    : FamPlanColors.textLight,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FamPlanColors.tealGreen,
                  foregroundColor: FamPlanColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FamPlanColors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

