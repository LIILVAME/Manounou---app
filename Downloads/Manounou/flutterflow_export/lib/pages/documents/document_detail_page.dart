import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/documents_service.dart';
import '../../core/services/children_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/child_avatar.dart';

class DocumentDetailPage extends StatefulWidget {
  final String documentId;

  const DocumentDetailPage({
    super.key,
    required this.documentId,
  });

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  Document? _document;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final documentsService = context.read<DocumentsService>();
      await documentsService.loadDocuments();
      
      setState(() {
        _document = documentsService.documents.firstWhere(
          (d) => d.id == widget.documentId,
          orElse: () => documentsService.documents.first,
        );
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDocument() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce document ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final documentsService = context.read<DocumentsService>();
      await documentsService.deleteDocument(widget.documentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _shareDocument() async {
    if (_document == null) return;

    try {
      final uri = Uri.parse(_document!.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir le document'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenService = context.watch<ChildrenService>();

    if (_isLoading) {
      return Scaffold(
        backgroundColor: FamPlanColors.backgroundWhite,
        appBar: AppBar(
          title: const Text('Document'),
          elevation: 0,
          backgroundColor: FamPlanColors.backgroundWhite,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_document == null) {
      return Scaffold(
        backgroundColor: FamPlanColors.backgroundWhite,
        appBar: AppBar(
          title: const Text('Document'),
          elevation: 0,
          backgroundColor: FamPlanColors.backgroundWhite,
        ),
        body: const Center(
          child: Text('Document non trouvé'),
        ),
      );
    }

    Child? child;
    try {
      child = childrenService.children.firstWhere(
        (c) => c.id == _document!.childId,
      );
    } catch (e) {
      child = childrenService.children.isNotEmpty
          ? childrenService.children.first
          : null;
    }

    if (child == null) {
      return Scaffold(
        backgroundColor: FamPlanColors.backgroundWhite,
        appBar: AppBar(
          title: const Text('Document'),
          elevation: 0,
          backgroundColor: FamPlanColors.backgroundWhite,
        ),
        body: const Center(
          child: Text('Enfant non trouvé'),
        ),
      );
    }

    final typeLabels = {
      'certificat': 'Certificat',
      'autorisation': 'Autorisation',
      'autre': 'Autre',
    };

    return Scaffold(
      backgroundColor: FamPlanColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Document',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: FamPlanColors.textDark,
          ),
        ),
        elevation: 0,
        backgroundColor: FamPlanColors.backgroundWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
            color: FamPlanColors.tealGreen,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteDocument,
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations document
            FamPlanCard(
              backgroundColor: FamPlanColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: FamPlanColors.tealGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _document!.isImage
                              ? Icons.image
                              : _document!.isPdf
                                  ? Icons.picture_as_pdf
                                  : Icons.insert_drive_file,
                          color: FamPlanColors.tealGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _document!.fileName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: FamPlanColors.textDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              typeLabels[_document!.type] ?? _document!.type,
                              style: TextStyle(
                                fontSize: 14,
                                color: FamPlanColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Enfant
                  Row(
                    children: [
                      Icon(
                        Icons.child_care,
                        size: 20,
                        color: FamPlanColors.textLight,
                      ),
                      const SizedBox(width: 8),
                      ChildAvatar(
                        firstName: child.firstName,
                        photoUrl: child.photoUrl,
                        radius: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        child.firstName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: FamPlanColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: FamPlanColors.textLight,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateHelper.formatDateWithTime(_document!.uploadedAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: FamPlanColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visualisation
            if (_document!.isImage)
              FamPlanCard(
                backgroundColor: FamPlanColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aperçu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _document!.fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: FamPlanColors.backgroundLight,
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else if (_document!.isPdf)
              FamPlanCard(
                backgroundColor: FamPlanColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FamPlanColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: FamPlanColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _shareDocument(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FamPlanColors.tealGreen,
                                foregroundColor: FamPlanColors.white,
                              ),
                              child: const Text('Ouvrir le PDF'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
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
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: FamPlanColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              size: 64,
                              color: FamPlanColors.textLight,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _shareDocument(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FamPlanColors.tealGreen,
                                foregroundColor: FamPlanColors.white,
                              ),
                              child: const Text('Ouvrir le fichier'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

