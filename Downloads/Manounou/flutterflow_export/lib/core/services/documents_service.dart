import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class Document {
  final String id;
  final String childId;
  final String fileName;
  final String fileUrl;
  final String type; // 'certificat', 'autorisation', 'autre'
  final DateTime uploadedAt;

  Document({
    required this.id,
    required this.childId,
    required this.fileName,
    required this.fileUrl,
    required this.type,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      type: json['type'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'file_name': fileName,
      'file_url': fileUrl,
      'type': type,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  bool get isImage {
    final ext = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  bool get isPdf {
    return fileName.toLowerCase().endsWith('.pdf');
  }
}

class DocumentsService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Document> _documents = [];
  bool _isLoading = false;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;

  /// Charger tous les documents de l'utilisateur
  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _documents = [];
        notifyListeners();
        return;
      }

      // Récupérer les enfants de l'utilisateur d'abord
      final childrenResponse = await _supabase
          .from('children')
          .select('id')
          .eq('parent_id', userId);

      final childrenIds = (childrenResponse as List<dynamic>)
          .map((c) => c['id'] as String)
          .toList();

      if (childrenIds.isEmpty) {
        _documents = [];
        notifyListeners();
        return;
      }

      // Récupérer les documents de ces enfants
      List<dynamic> allDocuments = [];
      for (final childId in childrenIds) {
        try {
          final childDocuments = await _supabase
              .from('documents')
              .select('*')
              .eq('child_id', childId)
              .order('uploaded_at', ascending: false);
          allDocuments.addAll(childDocuments as List<dynamic>);
        } catch (e) {
          debugPrint('Erreur chargement documents pour enfant $childId: $e');
        }
      }

      // Trier par date
      allDocuments.sort((a, b) {
        final aDate = DateTime.parse(a['uploaded_at'] as String);
        final bDate = DateTime.parse(b['uploaded_at'] as String);
        return bDate.compareTo(aDate); // Plus récent en premier
      });

      _documents = allDocuments
          .map((json) => Document.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur loadDocuments: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les documents d'un enfant spécifique
  Future<List<Document>> loadDocumentsForChild(String childId) async {
    try {
      final response = await _supabase
          .from('documents')
          .select('*')
          .eq('child_id', childId)
          .order('uploaded_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Document.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erreur loadDocumentsForChild: $e');
      rethrow;
    }
  }

  /// Uploader un document vers Supabase Storage
  Future<String> uploadDocument(String childId, PlatformFile file, String type) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Générer un nom de fichier unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = file.name;
      final fileExtension = fileName.split('.').last;
      final storagePath = '$childId/$timestamp.$fileExtension';

      // Lire les bytes du fichier
      Uint8List bytes;
      if (file.bytes != null) {
        // Web ou fichier déjà chargé en mémoire - TOUJOURS utiliser bytes sur web
        bytes = file.bytes!;
      } else if (!kIsWeb) {
        // Mobile : essayer de lire depuis le chemin (seulement si bytes n'est pas disponible)
        // Protéger l'accès à path avec try-catch
        try {
          // Vérifier path sans déclencher d'exception
          final pathValue = file.path;
          if (pathValue != null && pathValue.isNotEmpty) {
            final fileData = await File(pathValue).readAsBytes();
            bytes = Uint8List.fromList(fileData);
          } else {
            throw Exception('Fichier invalide: ni bytes ni path disponible');
          }
        } catch (e) {
          // Si path n'est pas disponible ou cause une exception
          throw Exception('Fichier invalide: impossible de lire depuis path: $e');
        }
      } else {
        // Sur web, on DOIT avoir bytes (ne jamais utiliser path)
        throw Exception('Fichier invalide sur web: bytes requis mais non disponible');
      }

      // Upload vers Supabase Storage
      await _supabase.storage
          .from('documents')
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(fileExtension),
              upsert: false,
            ),
          );
      final fileUrl = _supabase.storage
          .from('documents')
          .getPublicUrl(storagePath);

      // Créer l'entrée dans la table documents
      final response = await _supabase.from('documents').insert({
        'child_id': childId,
        'file_name': fileName,
        'file_url': fileUrl,
        'type': type,
        'uploaded_at': DateTime.now().toIso8601String(),
      }).select().single();

      final document = Document.fromJson(response);
      _documents.insert(0, document);
      notifyListeners();

      return fileUrl;
    } catch (e) {
      debugPrint('Erreur uploadDocument: $e');
      rethrow;
    }
  }

  /// Supprimer un document
  Future<void> deleteDocument(String documentId) async {
    try {
      // Récupérer le document pour obtenir le chemin du fichier
      final document = _documents.firstWhere((d) => d.id == documentId);
      
      // Extraire le chemin du storage depuis l'URL
      final url = document.fileUrl;
      final pathMatch = RegExp(r'/storage/v1/object/public/documents/(.+)$').firstMatch(url);
      if (pathMatch != null) {
        final storagePath = pathMatch.group(1)!;
        
        // Supprimer le fichier du storage
        await _supabase.storage.from('documents').remove([storagePath]);
      }

      // Supprimer l'entrée dans la table
      await _supabase.from('documents').delete().eq('id', documentId);

      _documents.removeWhere((d) => d.id == documentId);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur deleteDocument: $e');
      rethrow;
    }
  }

  /// Filtrer les documents par type
  List<Document> getDocumentsByType(String type) {
    return _documents.where((d) => d.type == type).toList();
  }

  /// Filtrer les documents par enfant
  List<Document> getDocumentsByChild(String childId) {
    return _documents.where((d) => d.childId == childId).toList();
  }

  /// Rechercher des documents par nom
  List<Document> searchDocuments(String query) {
    final lowerQuery = query.toLowerCase();
    return _documents
        .where((d) => d.fileName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}

