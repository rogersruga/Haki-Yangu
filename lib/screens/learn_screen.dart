import 'package:flutter/material.dart';
import 'land_rights_detail_screen.dart';
import 'employment_law_detail_screen.dart';
import 'gender_equality_detail_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Legal categories data
  final List<LegalCategory> _categories = [
    LegalCategory(
      title: 'Land Rights',
      subtitle: 'property & ownership',
      icon: Icons.home,
      color: const Color(0xFF7B1FA2), // Purple
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
      title: 'Youth & Education',
      subtitle: 'student rights',
      icon: Icons.school,
      color: const Color(0xFF9C27B0), // Purple variant
    ),
    LegalCategory(
      title: 'Criminal Justice',
      subtitle: 'legal protection',
      icon: Icons.security,
      color: const Color(0xFFF44336), // Red
    ),
    LegalCategory(
      title: 'Healthcare Rights',
      subtitle: 'medical access',
      icon: Icons.favorite,
      color: const Color(0xFF00BCD4), // Cyan
    ),
    LegalCategory(
      title: 'Family Law',
      subtitle: 'marriage & children',
      icon: Icons.family_restroom,
      color: const Color(0xFFE91E63), // Pink
    ),
    LegalCategory(
      title: 'Environment',
      subtitle: 'clean & safe',
      icon: Icons.eco,
      color: const Color(0xFF8BC34A), // Light Green
    ),
    LegalCategory(
      title: 'Freedom of Speech',
      subtitle: 'expression rights',
      icon: Icons.record_voice_over,
      color: const Color(0xFFFF5722), // Deep Orange
    ),
    LegalCategory(
      title: 'Voting Rights',
      subtitle: 'democracy participation',
      icon: Icons.how_to_vote,
      color: const Color(0xFF3F51B5), // Indigo
    ),
    LegalCategory(
      title: 'Disability Rights',
      subtitle: 'accessibility & inclusion',
      icon: Icons.accessible,
      color: const Color(0xFF009688), // Teal
    ),
    LegalCategory(
      title: 'Consumer Rights',
      subtitle: 'fair trade',
      icon: Icons.shopping_cart,
      color: const Color(0xFF673AB7), // Deep Purple
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
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories
            .where((category) =>
                category.title.toLowerCase().contains(query.toLowerCase()) ||
                category.subtitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7B1FA2), // Purple
            Color(0xFF9C27B0), // Violet
          ],
        ),
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
            'Choose a category to learn about your rights',
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter options coming soon!')),
                    );
                  },
                  icon: const Icon(
                    Icons.tune,
                    color: Color(0xFF7B1FA2),
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
                '${_filteredCategories.length} categories available',
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

  Widget _buildCategoriesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
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
