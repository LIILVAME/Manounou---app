import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'avatar_service.dart';

class Child {
  final String id;
  final String parentId;
  final String firstName;
  final DateTime? birthDate;
  final String? info;
  final String? photoUrl;
  final String? gender; // 'M' ou 'F'
  final DateTime createdAt;
  final DateTime updatedAt;

  Child({
    required this.id,
    required this.parentId,
    required this.firstName,
    this.birthDate,
    this.info,
    this.photoUrl,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      firstName: json['first_name'] as String,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      info: json['info'] as String?,
      photoUrl: json['photo_url'] as String?,
      gender: json['gender'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'first_name': firstName,
      'birth_date': birthDate?.toIso8601String().split('T')[0],
      'info': info,
      'photo_url': photoUrl,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}

class ChildrenService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Child> _children = [];
  bool _isLoading = false;

  List<Child> get children => _children;
  bool get isLoading => _isLoading;

  // Récupérer tous les enfants de l'utilisateur connecté
  Future<void> loadChildren() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Vérifier la session avant de faire la requête
      final session = _supabase.auth.currentSession;
      if (session == null) {
        debugPrint('⚠️ Aucune session active, redirection vers login recommandée');
        _children = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Vérifier si le token est expiré et essayer de le rafraîchir
      if (session.isExpired) {
        debugPrint('🔄 Session expirée, tentative de rafraîchissement...');
        try {
          await _supabase.auth.refreshSession();
          debugPrint('✅ Session rafraîchie avec succès');
        } catch (refreshError) {
          debugPrint('❌ Erreur lors du rafraîchissement de session: $refreshError');
          // Si le rafraîchissement échoue, vider la liste et laisser l'UI gérer
          _children = [];
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('⚠️ Aucun utilisateur connecté');
        _children = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('children')
          .select('*')
          .eq('parent_id', userId)
          .order('created_at', ascending: false);

      _children = (response as List)
          .map((json) => Child.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur loadChildren: $e');
      
      // Si c'est une erreur d'authentification, vider la liste
      if (e.toString().contains('Auth') || 
          e.toString().contains('session') ||
          e.toString().contains('oauth_client_id')) {
        debugPrint('⚠️ Erreur d\'authentification détectée, vidage de la liste');
        _children = [];
      }
      
      // Ne pas rethrow pour éviter de crasher l'UI
      // L'erreur sera gérée par le dashboard qui affichera un état d'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload une photo d'enfant
  // Supporte mobile (File) et Web (XFile avec bytes)
  Future<String?> uploadChildPhoto(String childId, XFile imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$userId/$childId/$fileName';

      // Sur Web, lire les bytes depuis XFile
      // Sur mobile, utiliser File directement
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await imageFile.readAsBytes();
      }

      if (kIsWeb && bytes != null) {
        // Upload sur Web avec bytes
        await _supabase.storage
            .from('children-photos')
            .uploadBinary(storagePath, bytes, fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ));
      } else {
        // Upload sur mobile avec File
        final file = File(imageFile.path);
        await _supabase.storage
            .from('children-photos')
            .upload(storagePath, file, fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ));
      }

      // Bucket public : utiliser getPublicUrl()
      final photoUrl = _supabase.storage
          .from('children-photos')
          .getPublicUrl(storagePath);

      return photoUrl;
    } catch (e) {
      debugPrint('Erreur uploadChildPhoto: $e');
      rethrow;
    }
  }

  // Créer un enfant
  Future<Child> createChild({
    required String firstName,
    DateTime? birthDate,
    String? info,
    XFile? photoFile,
    String? gender,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Générer un avatar aléatoire si aucune photo n'est fournie
      String? initialPhotoUrl;
      if (photoFile == null && gender != null) {
        final genderEnum = AvatarService.genderFromString(gender);
        final avatarPath = AvatarService.getRandomAvatarPath(genderEnum);
        // Préfixe "avatar:" pour distinguer les avatars des photos réseau
        initialPhotoUrl = 'avatar:$avatarPath';
      }

      // Créer l'enfant d'abord
      final response = await _supabase.from('children').insert({
        'parent_id': userId,
        'first_name': firstName,
        'birth_date': birthDate?.toIso8601String().split('T')[0],
        'info': info,
        'gender': gender,
        'photo_url': initialPhotoUrl, // Avatar assigné par défaut si pas de photo
      }).select().single();

      var child = Child.fromJson(response);

      // Upload photo si fournie (remplace l'avatar)
      if (photoFile != null) {
        try {
          final photoUrl = await uploadChildPhoto(child.id, photoFile);
          if (photoUrl != null) {
            // Mettre à jour avec l'URL de la photo
            await _supabase
                .from('children')
                .update({'photo_url': photoUrl})
                .eq('id', child.id);
            
            child = Child(
              id: child.id,
              parentId: child.parentId,
              firstName: child.firstName,
              birthDate: child.birthDate,
              info: child.info,
              photoUrl: photoUrl,
              gender: child.gender,
              createdAt: child.createdAt,
              updatedAt: child.updatedAt,
            );
          }
        } catch (e) {
          debugPrint('Erreur upload photo lors création: $e');
          // Continue même si l'upload photo échoue
        }
      }

      _children.insert(0, child);
      notifyListeners();

      return child;
    } catch (e) {
      debugPrint('Erreur createChild: $e');
      rethrow;
    }
  }

  // Mettre à jour un enfant
  Future<void> updateChild({
    required String childId,
    String? firstName,
    DateTime? birthDate,
    String? info,
    XFile? photoFile,
    bool deletePhoto = false,
    String? gender,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (birthDate != null) {
        updates['birth_date'] = birthDate.toIso8601String().split('T')[0];
      }
      if (info != null) updates['info'] = info;
      if (gender != null) {
        updates['gender'] = gender;
        // Si on change le genre et qu'il n'y a pas de photo, générer un nouvel avatar
        if (deletePhoto || (photoFile == null && !updates.containsKey('photo_url'))) {
          final genderEnum = AvatarService.genderFromString(gender);
          final avatarPath = AvatarService.getRandomAvatarPath(genderEnum);
          updates['photo_url'] = 'avatar:$avatarPath';
        }
      }

      // Gérer la photo
      if (deletePhoto) {
        // Si on supprime la photo, générer un nouvel avatar si un genre est disponible
        if (gender != null) {
          final genderEnum = AvatarService.genderFromString(gender);
          if (genderEnum != null) {
            final avatarPath = AvatarService.getRandomAvatarPath(genderEnum);
            updates['photo_url'] = 'avatar:$avatarPath';
          } else {
            updates['photo_url'] = null;
          }
        } else {
          // Récupérer le genre actuel pour générer un avatar
          try {
            final currentChild = await getChildById(childId);
            if (currentChild?.gender != null) {
              final genderEnum = AvatarService.genderFromString(currentChild!.gender);
              if (genderEnum != null) {
                final avatarPath = AvatarService.getRandomAvatarPath(genderEnum);
                updates['photo_url'] = 'avatar:$avatarPath';
              } else {
                updates['photo_url'] = null;
              }
            } else {
              updates['photo_url'] = null;
            }
          } catch (e) {
            debugPrint('Erreur récupération enfant pour avatar: $e');
            updates['photo_url'] = null;
          }
        }
        // TODO: Supprimer le fichier du storage aussi si c'était une vraie photo
      } else if (photoFile != null) {
        // Si une nouvelle photo est fournie, elle remplace toujours l'avatar ou la photo existante
        try {
          final photoUrl = await uploadChildPhoto(childId, photoFile);
          if (photoUrl != null) {
            updates['photo_url'] = photoUrl;
          }
        } catch (e) {
          debugPrint('Erreur upload photo lors mise à jour: $e');
          // Continue même si l'upload photo échoue
        }
      }

      await _supabase
          .from('children')
          .update(updates)
          .eq('id', childId);

      // Recharger la liste
      await loadChildren();
    } catch (e) {
      debugPrint('Erreur updateChild: $e');
      rethrow;
    }
  }

  // Supprimer un enfant
  Future<void> deleteChild(String childId) async {
    try {
      await _supabase.from('children').delete().eq('id', childId);

      _children.removeWhere((child) => child.id == childId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur deleteChild: $e');
      rethrow;
    }
  }

  // Récupérer un enfant par ID
  Future<Child?> getChildById(String childId) async {
    try {
      final response = await _supabase
          .from('children')
          .select('*')
          .eq('id', childId)
          .single();

      return Child.fromJson(response);
    } catch (e) {
      debugPrint('Erreur getChildById: $e');
      return null;
    }
  }
}

