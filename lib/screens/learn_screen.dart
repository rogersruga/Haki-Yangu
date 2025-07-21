import 'package:flutter/material.dart';
import '../services/refresh_service.dart';
import 'land_rights_detail_screen.dart';
import 'employment_law_detail_screen.dart';
import 'gender_equality_detail_screen.dart';
import 'elections_act_detail_screen.dart';
import 'healthcare_rights_detail_screen.dart';
import 'bill_of_rights_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

enum SortOrder { none, aToZ, zToA }

class _LearnScreenState extends State<LearnScreen> {
  final RefreshService _refreshService = RefreshService();
  final TextEditingController _searchController = TextEditingController();
  SortOrder _currentSortOrder = SortOrder.none;
  
  // Legal categories data
  final List<LegalCategory> _categories = [
    LegalCategory(
      title: 'Land Rights',
      subtitle: 'property & ownership',
      icon: Icons.home,
      color: const Color(0xFF1B5E20), // Deep green
    ),
    LegalCategory(
      title: 'Employment Law',
      subtitle: 'worker rights',
      icon: Icons.work,
      color: const Color(0xFF4CAF50), // Green
    ),
    LegalCategory(
      title: 'Gender Equality',
      subtitle: 'equal rights',
      icon: Icons.people,
      color: const Color(0xFFFF9800), // Orange
    ),
    LegalCategory(
      title: 'Healthcare Rights',
      subtitle: 'medical access',
      icon: Icons.favorite,
      color: const Color(0xFF00BCD4), // Cyan
    ),
    LegalCategory(
      title: 'Bill of Rights',
      subtitle: 'rights and freedoms',
      icon: Icons.record_voice_over,
      color: const Color(0xFFFF5722), // Deep Orange
    ),
    LegalCategory(
      title: 'Elections Act',
      subtitle: 'electoral processes',
      icon: Icons.how_to_vote,
      color: const Color(0xFF3F51B5), // Indigo
    ),
  ];

  List<LegalCategory> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = List.from(_categories);
      } else {
        _filteredCategories = _categories
            .where((category) =>
                category.title.toLowerCase().contains(query.toLowerCase()) ||
                category.subtitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _applySorting();
    });
  }

  void _applySorting() {
    switch (_currentSortOrder) {
      case SortOrder.aToZ:
        _filteredCategories.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOrder.zToA:
        _filteredCategories.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOrder.none:
        // Keep original order - do nothing
        break;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Sort Modules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),

              // Sort options
              _buildSortOption(
                title: 'Default Order',
                subtitle: 'Original category order',
                icon: Icons.list,
                isSelected: _currentSortOrder == SortOrder.none,
                onTap: () => _setSortOrder(SortOrder.none),
              ),
              _buildSortOption(
                title: 'A to Z',
                subtitle: 'Sort alphabetically ascending',
                icon: Icons.sort_by_alpha,
                isSelected: _currentSortOrder == SortOrder.aToZ,
                onTap: () => _setSortOrder(SortOrder.aToZ),
              ),
              _buildSortOption(
                title: 'Z to A',
                subtitle: 'Sort alphabetically descending',
                icon: Icons.sort_by_alpha,
                isSelected: _currentSortOrder == SortOrder.zToA,
                onTap: () => _setSortOrder(SortOrder.zToA),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            )
          : null,
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }

  void _setSortOrder(SortOrder sortOrder) {
    setState(() {
      _currentSortOrder = sortOrder;
      _filterCategories(_searchController.text);
    });
  }

  String _getSortOrderText() {
    switch (_currentSortOrder) {
      case SortOrder.aToZ:
        return ' • Sorted A-Z';
      case SortOrder.zToA:
        return ' • Sorted Z-A';
      case SortOrder.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavigationBar(),
            
            // Header Section
            _buildHeaderSection(),
            
            // Search and Filter Bar
            _buildSearchAndFilterBar(),
            
            // Legal Categories Grid
            Expanded(
              child: _buildCategoriesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Text(
            'Justice Simplified',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmarks coming soon!')),
              );
            },
            icon: const Icon(
              Icons.bookmark_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Legal Topics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a module and start learning about your rights',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCategories,
                    decoration: const InputDecoration(
                      hintText: 'Search legal topics...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _showFilterOptions,
                  icon: Icon(
                    Icons.tune,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                '${_filteredCategories.length} modules available${_getSortOrderText()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    try {
      // Refresh learning content
      final result = await _refreshService.refreshLearningContent();

      // Show feedback only if there are errors or warnings
      if (result.showFeedback && mounted) {
        RefreshService.showRefreshFeedback(context, result);
      }
    } catch (e) {
      if (mounted) {
        RefreshService.showRefreshFeedback(
          context,
          RefreshResult.error(
            message: 'Failed to refresh learning content',
            error: e,
          ),
        );
      }
    }
  }

  Widget _buildCategoriesGrid() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: _filteredCategories.length,
          itemBuilder: (context, index) {
            final category = _filteredCategories[index];
            return _buildCategoryCard(category);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(LegalCategory category) {
    return GestureDetector(
      onTap: () {
        if (category.title.trim() == 'Land Rights') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LandRightsDetailScreen(),
            ),
          );
        } else if (category.title.contains('Employment')) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const EmploymentLawDetailScreen(),
            ),
          );
        } else if (category.title.trim() == 'Gender Equality') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GenderEqualityDetailScreen(),
            ),
          );
        } else if (category.title.trim() == 'Elections Act') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ElectionsActDetailScreen(),
            ),
          );
        } else if (category.title.trim() == 'Healthcare Rights') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HealthcareRightsDetailScreen(),
            ),
          );
        } else if (category.title.trim() == 'Bill of Rights') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BillOfRightsDetailScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${category.title} details coming soon!'),
              backgroundColor: category.color,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                category.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                category.subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LegalCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  LegalCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
