import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/services/documents_service.dart';
import '../../core/services/children_service.dart';
import '../../core/theme/famplan_colors.dart';
import '../../core/widgets/famplan_card.dart';
import '../../core/widgets/animated_fab.dart';
import '../../core/utils/date_helper.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  String? _selectedChildId;
  String? _selectedType;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentsService>().loadDocuments();
      context.read<ChildrenService>().loadChildren();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Document> get _filteredDocuments {
    final documentsService = context.watch<DocumentsService>();
    var documents = documentsService.documents;

    // Filtre par enfant
    if (_selectedChildId != null) {
      documents = documents.where((d) => d.childId == _selectedChildId).toList();
    }

    // Filtre par type
    if (_selectedType != null) {
      documents = documents.where((d) => d.type == _selectedType).toList();
    }

    // Recherche par nom
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      documents = documents
          .where((d) => d.fileName.toLowerCase().contains(query))
          .toList();
    }

    return documents;
  }

  @override
  Widget build(BuildContext context) {
    final documentsService = context.watch<DocumentsService>();
    final childrenService = context.watch<ChildrenService>();

    return Scaffold(
      backgroundColor: FamPlanColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Documents',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: FamPlanColors.textDark,
          ),
        ),
        elevation: 0,
        backgroundColor: FamPlanColors.backgroundWhite,
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: FamPlanColors.backgroundLight,
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un document...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: FamPlanColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                
                // Filtres
                Row(
                  children: [
                    // Filtre par enfant
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedChildId,
                        decoration: InputDecoration(
                          labelText: 'Enfant',
                          filled: true,
                          fillColor: FamPlanColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous les enfants'),
                          ),
                          ...childrenService.children.map((child) {
                            return DropdownMenuItem<String>(
                              value: child.id,
                              child: Text(child.firstName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedChildId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Filtre par type
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          filled: true,
                          fillColor: FamPlanColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tous les types'),
                          ),
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
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des documents
          Expanded(
            child: documentsService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDocuments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty ||
                                      _selectedChildId != null ||
                                      _selectedType != null
                                  ? 'Aucun document trouvé'
                                  : 'Aucun document',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (_searchController.text.isEmpty &&
                                _selectedChildId == null &&
                                _selectedType == null)
                              Text(
                                'Ajoutez votre premier document',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDocuments.length,
                        itemBuilder: (context, index) {
                          final document = _filteredDocuments[index];
                          final child = childrenService.children.firstWhere(
                            (c) => c.id == document.childId,
                            orElse: () => childrenService.children.first,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDocumentCard(context, document, child.firstName),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        onPressed: () => context.push('/documents/upload'),
        icon: Icons.add,
        backgroundColor: FamPlanColors.tealGreen,
        foregroundColor: FamPlanColors.white,
        tooltip: 'Ajouter un document',
        enableRotation: true,
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    Document document,
    String childName,
  ) {
    final typeLabels = {
      'certificat': 'Certificat',
      'autorisation': 'Autorisation',
      'autre': 'Autre',
    };

    return FamPlanCard(
      backgroundColor: FamPlanColors.getCardColor(document.hashCode % 7),
      onTap: () => context.push('/documents/${document.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icône type de fichier
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: FamPlanColors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              document.isImage
                  ? Icons.image
                  : document.isPdf
                      ? Icons.picture_as_pdf
                      : Icons.insert_drive_file,
              color: FamPlanColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.child_care,
                      size: 14,
                      color: FamPlanColors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      childName,
                      style: TextStyle(
                        fontSize: 12,
                        color: FamPlanColors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.label_outline,
                      size: 14,
                      color: FamPlanColors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      typeLabels[document.type] ?? document.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: FamPlanColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateHelper.formatShortDate(document.uploadedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: FamPlanColors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Icône flèche
          Icon(
            Icons.chevron_right,
            color: FamPlanColors.white.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}
