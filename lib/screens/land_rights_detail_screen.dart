import 'package:flutter/material.dart';
import '../widgets/module_completion_button.dart';
import '../services/progress_service.dart';
import '../services/refresh_service.dart';

class LandRightsDetailScreen extends StatefulWidget {
  const LandRightsDetailScreen({super.key});

  @override
  State<LandRightsDetailScreen> createState() => _LandRightsDetailScreenState();
}

class _LandRightsDetailScreenState extends State<LandRightsDetailScreen> {
  final RefreshService _refreshService = RefreshService();
  bool isBookmarked = false;

  Future<void> _onRefresh() async {
    try {
      // Refresh module completion status
      final result = await _refreshService.refreshModuleStatus(ProgressService.landRights);

      // Show feedback only if there are errors or warnings
      if (result.showFeedback && mounted) {
        RefreshService.showRefreshFeedback(context, result);
      }
    } catch (e) {
      if (mounted) {
        RefreshService.showRefreshFeedback(
          context,
          RefreshResult.error(
            message: 'Failed to refresh module status',
            error: e,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Title Section
                    _buildTitleSection(),

                    const SizedBox(height: 24),

                    // Quick Overview Section
                    _buildQuickOverviewSection(),

                    const SizedBox(height: 24),

                    // Land Categories Section
                    _buildLandCategoriesSection(),

                    const SizedBox(height: 24),

                    // Key Definitions Section
                    _buildKeyDefinitionsSection(),

                    const SizedBox(height: 24),

                    // Your Rights Section
                    _buildYourRightsSection(),

                    const SizedBox(height: 24),

                    // Land Tenure Types Section
                    _buildLandTenureSection(),

                    const SizedBox(height: 24),

                    // Buying and Selling Land Section
                    _buildBuyingSellingSectionn(),

                    const SizedBox(height: 24),

                    // Compulsory Acquisition Section
                    _buildCompulsoryAcquisitionSection(),

                    const SizedBox(height: 24),

                    // Legal Protection Section
                    _buildLegalProtectionSection(),

                    const SizedBox(height: 24),

                    // Important Notice Section
                    _buildImportantNotice(),

                    const SizedBox(height: 32),

                    // Completion Button (inline)
                    ModuleCompletionButton(
                      moduleId: ProgressService.landRights,
                      moduleName: 'Land Rights',
                    ),

                    const SizedBox(height: 32), // Space after completion button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary, // App theme green
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8), // Lighter green
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
            'Land Rights',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks',
                  ),
                  backgroundColor: const Color(0xFF7B1FA2),
                ),
              );
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Understanding Property Ownership in Kenya',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: const Color(0xFF7B1FA2),
              ),
              const SizedBox(width: 4),
              Text(
                '7 min read',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF7B1FA2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B1FA2).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B1FA2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'The Land Act No. 6 of 2012 is Kenya\'s comprehensive legal framework that implements Article 68 of the Constitution. This law governs all land types in Kenya and promotes sustainable administration and management of land resources.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Key Principles of the Act:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildPrinciplesList(),
          const SizedBox(height: 12),
          const Text(
            'Understanding these rights helps you make informed decisions, protect your property, and participate in Kenya\'s land governance system.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyDefinitionsSection() {
    final definitions = [
      {
        'title': 'Title Deed',
        'description': 'A legal document that proves you own a piece of land. Think of it as your land\'s birth certificate.',
        'icon': Icons.description,
        'color': const Color(0xFFFF9800), // Orange
      },
      {
        'title': 'Survey Map',
        'description': 'A detailed drawing showing the exact boundaries of your land and its location.',
        'icon': Icons.map,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Freehold vs Leasehold',
        'description': 'Freehold = you own it forever. Leasehold = you own it for a specific period (like 99 years).',
        'icon': Icons.home,
        'color': const Color(0xFF2196F3), // Blue
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Definitions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...definitions.map((definition) => _buildDefinitionCard(
          title: definition['title'] as String,
          description: definition['description'] as String,
          icon: definition['icon'] as IconData,
          color: definition['color'] as Color,
        )),
      ],
    );
  }

  Widget _buildDefinitionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourRightsSection() {
    final rights = [
      {
        'title': 'Your Rights as a Property Owner',
        'description': 'You can live on, rent, or develop your land as you wish.',
        'icon': Icons.home_work,
        'color': const Color(0xFF7B1FA2), // Purple
      },
      {
        'title': 'Right to Use',
        'description': 'You can live on the land, or develop it for business or farming.',
        'icon': Icons.business,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Right to Sell',
        'description': 'You can transfer ownership to someone else.',
        'icon': Icons.sell,
        'color': const Color(0xFFFF9800), // Orange
      },
      {
        'title': 'Right to Inherit',
        'description': 'You can pass the property to your family when you pass away.',
        'icon': Icons.family_restroom,
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'title': 'Right to Protection',
        'description': 'The government must protect your land from being taken unlawfully.',
        'icon': Icons.security,
        'color': const Color(0xFFF44336), // Red
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rights',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...rights.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> right = entry.value;
          return _buildRightCard(
            number: index + 1,
            title: right['title'] as String,
            description: right['description'] as String,
            icon: right['icon'] as IconData,
            color: right['color'] as Color,
          );
        }),
      ],
    );
  }

  Widget _buildRightCard({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Light orange background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Important Notice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Always verify land ownership through official channels before making any transactions. Visit the Ministry of Lands or consult with a qualified lawyer for complex land matters.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Legal assistance contacts coming soon!'),
                  backgroundColor: Color(0xFFFF9800),
                ),
              );
            },
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Get Legal Help'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinciplesList() {
    final principles = [
      'Equitable access and security of land rights',
      'Sustainable land resource management',
      'Transparency, accountability, and cost-effectiveness',
      'Elimination of gender discrimination',
      'Use of alternative dispute resolution mechanisms',
    ];

    return Column(
      children: principles.map((principle) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF7B1FA2),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                principle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildLandCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Types of Land in Kenya',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildLandCategoryCard(
          title: 'Public Land',
          description: 'Land owned by the government and managed by the National Land Commission. Includes roads, forests, and government buildings.',
          icon: Icons.account_balance,
          color: const Color(0xFF2196F3), // Blue
          examples: ['Government offices', 'Public roads', 'National parks', 'Forests'],
        ),
        const SizedBox(height: 12),
        _buildLandCategoryCard(
          title: 'Private Land',
          description: 'Land owned by individuals, companies, or organizations. You have full rights to use, develop, or sell this land.',
          icon: Icons.home,
          color: const Color(0xFF4CAF50), // Green
          examples: ['Your home', 'Private businesses', 'Individual farms', 'Company premises'],
        ),
        const SizedBox(height: 12),
        _buildLandCategoryCard(
          title: 'Community Land',
          description: 'Land owned collectively by communities. Managed according to customary law and community decisions.',
          icon: Icons.groups,
          color: const Color(0xFFFF9800), // Orange
          examples: ['Grazing areas', 'Community forests', 'Sacred sites', 'Traditional settlements'],
        ),
      ],
    );
  }

  Widget _buildLandCategoryCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Examples:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: examples.map((example) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                example,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLandTenureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Land Ownership Types (Tenure)',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildTenureCard(
          title: 'Freehold',
          description: 'You own the land forever. You can pass it to your children and their children. This is the strongest form of ownership.',
          icon: Icons.all_inclusive,
          color: const Color(0xFF4CAF50), // Green
          benefits: ['Own forever', 'Can inherit', 'Full control', 'Can sell anytime'],
        ),
        const SizedBox(height: 12),
        _buildTenureCard(
          title: 'Leasehold',
          description: 'You own the land for a specific period (like 99 years). After this period, the land returns to the government.',
          icon: Icons.schedule,
          color: const Color(0xFF2196F3), // Blue
          benefits: ['Fixed period ownership', 'Can renew lease', 'Lower initial cost', 'Can sell remaining years'],
        ),
        const SizedBox(height: 12),
        _buildTenureCard(
          title: 'Customary Rights',
          description: 'Traditional ownership based on community customs and practices. Common in rural areas and community land.',
          icon: Icons.groups,
          color: const Color(0xFFFF9800), // Orange
          benefits: ['Community recognition', 'Traditional practices', 'Collective ownership', 'Cultural significance'],
        ),
      ],
    );
  }

  Widget _buildTenureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> benefits,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Key Benefits:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBuyingSellingSectionn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buying and Selling Land',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildProcessCard(
          title: 'When Buying Land',
          icon: Icons.shopping_cart,
          color: const Color(0xFF4CAF50),
          steps: [
            'Verify the seller owns the land (check title deed)',
            'Ensure the land is not under any disputes',
            'Check if the land has any charges or loans against it',
            'Confirm the land use is suitable for your needs',
            'Get a professional land survey done',
            'Sign a written contract witnessed by two people',
            'Register the transfer at the land registry',
          ],
        ),
        const SizedBox(height: 16),
        _buildProcessCard(
          title: 'When Selling Land',
          icon: Icons.sell,
          color: const Color(0xFF2196F3),
          steps: [
            'Ensure you have clear title to the land',
            'Clear any outstanding loans or charges',
            'Get a current land valuation',
            'Prepare all necessary documents',
            'Sign a written sale contract',
            'Receive payment before transferring ownership',
            'Complete the transfer registration',
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: const Color(0xFFFF9800),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Important: All land sale contracts must be in writing and witnessed. Verbal agreements are not legally binding.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            int index = entry.key;
            String step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompulsoryAcquisitionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Compulsory Acquisition',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'When the government can take your land for public use',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF44336).withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44336).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel,
                      color: Color(0xFFF44336),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Your Protection Rights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProtectionPoint('The government can only take your land for genuine public purposes (roads, schools, hospitals)'),
              _buildProtectionPoint('You must be given proper notice before any acquisition'),
              _buildProtectionPoint('You have the right to fair and prompt compensation'),
              _buildProtectionPoint('The land must be properly surveyed and geo-referenced'),
              _buildProtectionPoint('You can challenge the acquisition in the Environment and Land Court'),
              _buildProtectionPoint('Compensation must be paid before the government takes possession'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF2196F3),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'If the government wants to acquire your land, seek legal advice immediately to ensure your rights are protected.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProtectionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFF44336),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalProtectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legal Protection & Dispute Resolution',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.balance,
                      color: Color(0xFF7B1FA2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Environment and Land Court',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'The Environment and Land Court has exclusive jurisdiction over all land disputes in Kenya. You can approach this court for:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildCourtService('Land ownership disputes'),
              _buildCourtService('Boundary disputes with neighbors'),
              _buildCourtService('Unlawful eviction cases'),
              _buildCourtService('Compensation disputes'),
              _buildCourtService('Land fraud cases'),
              _buildCourtService('Environmental protection issues'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourtService(String service) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: const Color(0xFF7B1FA2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              service,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
