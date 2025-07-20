import 'package:flutter/material.dart';
import '../widgets/module_completion_button.dart';
import '../services/progress_service.dart';
import '../services/refresh_service.dart';

class HealthcareRightsDetailScreen extends StatefulWidget {
  const HealthcareRightsDetailScreen({super.key});

  @override
  State<HealthcareRightsDetailScreen> createState() => _HealthcareRightsDetailScreenState();
}

class _HealthcareRightsDetailScreenState extends State<HealthcareRightsDetailScreen> {
  final RefreshService _refreshService = RefreshService();
  bool isBookmarked = false;

  Future<void> _onRefresh() async {
    try {
      // Refresh module completion status
      final result = await _refreshService.refreshModuleStatus(ProgressService.healthcareRights);

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
                    
                    // Health System Structure Section
                    _buildHealthSystemSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Key Definitions Section
                    _buildKeyDefinitionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Your Health Rights Section
                    _buildHealthRightsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Emergency Treatment Rights Section
                    _buildEmergencyTreatmentSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Reproductive Health Rights Section
                    _buildReproductiveHealthSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Informed Consent Section
                    _buildInformedConsentSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Health Facility Levels Section
                    _buildHealthFacilityLevelsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Health Financing Section
                    _buildHealthFinancingSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Traditional Medicine Section
                    _buildTraditionalMedicineSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Health Research Section
                    _buildHealthResearchSection(),
                    
                    const SizedBox(height: 24),
                    
                    // E-Health Section
                    _buildEHealthSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Penalties and Enforcement Section
                    _buildPenaltiesEnforcementSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Legal Protection Section
                    _buildLegalProtectionSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Important Notice Section
                    _buildImportantNotice(),

                    const SizedBox(height: 32),

                    // Completion Button (inline)
                    ModuleCompletionButton(
                      moduleId: ProgressService.healthcareRights,
                      moduleName: 'Healthcare Rights',
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
            'Healthcare Rights',
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
          'Understanding Your Healthcare Rights in Kenya',
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
                '9 min read',
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
            'The Kenya Health Act, Cap. 241 establishes a unified national health system that guarantees your right to the highest attainable standard of health. It coordinates healthcare delivery between national and county governments while protecting your fundamental health rights.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Core Health Principles:',
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
            'Understanding these rights helps you access quality healthcare, make informed decisions, and hold healthcare providers accountable.',
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

  Widget _buildPrinciplesList() {
    final principles = [
      'Right to the highest attainable standard of health',
      'Equitable access to healthcare services',
      'Dignified treatment with privacy protection',
      'Free vaccination and maternity care for children under 5',
      'Emergency treatment as a fundamental right',
      'Informed consent for all medical procedures',
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

  Widget _buildHealthSystemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kenya\'s Health System Structure',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildSystemCard(
          title: 'National Government Role',
          description: 'Policy development, national referral facilities, and health product regulation.',
          icon: Icons.account_balance,
          color: const Color(0xFF4CAF50), // Green
          responsibilities: ['Health policy formulation', 'National referral hospitals', 'Health product regulation', 'Research coordination', 'Specialized laboratories'],
        ),
        const SizedBox(height: 12),
        _buildSystemCard(
          title: 'County Government Role',
          description: 'Primary healthcare delivery, county health facilities, and local health services.',
          icon: Icons.location_city,
          color: const Color(0xFF2196F3), // Blue
          responsibilities: ['Primary healthcare delivery', 'County health facilities', 'Community health services', 'Local health promotion', 'Environmental health'],
        ),
        const SizedBox(height: 12),
        _buildSystemCard(
          title: 'Public-Private Partnerships',
          description: 'Collaboration between government and private sector to expand healthcare access.',
          icon: Icons.handshake,
          color: const Color(0xFFFF9800), // Orange
          responsibilities: ['Infrastructure development', 'Service expansion', 'Technology integration', 'Quality improvement', 'Resource mobilization'],
        ),
      ],
    );
  }

  Widget _buildSystemCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> responsibilities,
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
            'Key Responsibilities:',
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
            children: responsibilities.map((responsibility) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                responsibility,
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

  Widget _buildKeyDefinitionsSection() {
    final definitions = [
      {
        'title': 'Health System',
        'description': 'An organization of people, institutions, and resources delivering healthcare services to meet health needs.',
        'icon': Icons.local_hospital,
        'color': const Color(0xFF7B1FA2), // Purple
      },
      {
        'title': 'Healthcare Provider',
        'description': 'Individuals or entities providing health services, including professionals, facilities, and institutions.',
        'icon': Icons.medical_services,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Informed Consent',
        'description': 'Permission granted by a person with legal capacity after full disclosure of the health intervention.',
        'icon': Icons.assignment,
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'title': 'Emergency Treatment',
        'description': 'Immediate medical care provided to prevent death or serious harm to health.',
        'icon': Icons.emergency,
        'color': const Color(0xFFF44336), // Red
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Healthcare Terms',
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

  Widget _buildHealthRightsSection() {
    final rights = [
      {
        'title': 'Right to Healthcare Access',
        'description': 'You have the right to access healthcare services without discrimination based on your background.',
        'icon': Icons.accessibility,
        'color': const Color(0xFF7B1FA2), // Purple
      },
      {
        'title': 'Right to Dignified Treatment',
        'description': 'Healthcare providers must treat you with dignity and respect your privacy at all times.',
        'icon': Icons.person,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Right to Information',
        'description': 'You have the right to receive clear information about your health status and treatment options.',
        'icon': Icons.info,
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'title': 'Right to Complaint',
        'description': 'You can file complaints about healthcare services and receive timely investigation and feedback.',
        'icon': Icons.report,
        'color': const Color(0xFFFF9800), // Orange
      },
      {
        'title': 'Right to Refuse Treatment',
        'description': 'You have the right to refuse medical treatment after being informed of the consequences.',
        'icon': Icons.block,
        'color': const Color(0xFFF44336), // Red
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Fundamental Health Rights',
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

  Widget _buildEmergencyTreatmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emergency Treatment Rights',
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
                      Icons.emergency,
                      color: Color(0xFFF44336),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Guaranteed Emergency Care',
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
                'Every person has an absolute right to emergency treatment to prevent death or serious harm:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildEmergencyRight('Pre-hospital emergency care and ambulance services'),
              _buildEmergencyRight('Immediate stabilization of life-threatening conditions'),
              _buildEmergencyRight('Emergency referral to appropriate facilities'),
              _buildEmergencyRight('Treatment regardless of ability to pay'),
              _buildEmergencyRight('No discrimination in emergency situations'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: const Color(0xFFF44336),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Healthcare providers who fail to provide emergency treatment when capable face fines up to 3 million KES.',
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
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyRight(String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: const Color(0xFFF44336),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              right,
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

  Widget _buildReproductiveHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reproductive Health Rights',
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
            border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.2)),
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
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.pregnant_woman,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Comprehensive Reproductive Care',
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
                'You have comprehensive rights to reproductive healthcare services:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildReproductiveRight('Access to family planning services and contraception'),
              _buildReproductiveRight('Safe pregnancy and childbirth services'),
              _buildReproductiveRight('Treatment of pregnancy complications'),
              _buildReproductiveRight('Qualified health professionals for delivery'),
              _buildReproductiveRight('Licensed facilities for maternal care'),
              _buildReproductiveRight('Free maternity care for children under 5'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special Protection:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Children under 5 years are guaranteed free vaccination and maternity care funded by national and county governments.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReproductiveRight(String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              right,
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

  Widget _buildInformedConsentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informed Consent Requirements',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildConsentCard(
          title: 'When Consent is Required',
          icon: Icons.assignment_turned_in,
          color: const Color(0xFF2196F3),
          requirements: [
            'All medical procedures and treatments',
            'Surgical interventions and operations',
            'Medical research participation',
            'Sharing of medical information',
            'Use of experimental treatments',
          ],
        ),
        const SizedBox(height: 16),
        _buildConsentCard(
          title: 'Exceptions to Consent',
          icon: Icons.emergency,
          color: const Color(0xFFF44336),
          requirements: [
            'Life-threatening emergency situations',
            'Patient is mentally incapacitated',
            'Public health emergency measures',
            'Court-ordered medical treatment',
            'Unconscious patient requiring immediate care',
          ],
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
                  'Healthcare providers must ensure you understand the treatment, risks, benefits, and alternatives before obtaining your consent. Refusal of treatment must be documented.',
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

  Widget _buildConsentCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> requirements,
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
          ...requirements.map((requirement) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  title.contains('Exceptions') ? Icons.warning : Icons.check_circle,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    requirement,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
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

  Widget _buildHealthFacilityLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Facility Levels',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kenya\'s health system is organized into six levels of care',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildFacilityLevelCard(
          level: 'Level 1',
          title: 'Community Services',
          description: 'Community health units and village health committees',
          services: ['Health promotion', 'Disease prevention', 'Basic first aid', 'Health education'],
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 12),
        _buildFacilityLevelCard(
          level: 'Level 2',
          title: 'Dispensaries',
          description: 'Basic outpatient services and preventive care',
          services: ['Outpatient care', 'Basic laboratory', 'Pharmacy services', 'Immunization'],
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 12),
        _buildFacilityLevelCard(
          level: 'Level 3',
          title: 'Health Centers',
          description: 'Comprehensive primary healthcare with maternity services',
          services: ['Maternity care', 'Minor surgery', 'Laboratory services', 'Dental care'],
          color: const Color(0xFFFF9800),
        ),
        const SizedBox(height: 12),
        _buildFacilityLevelCard(
          level: 'Level 4-6',
          title: 'Hospitals',
          description: 'Secondary and tertiary care with specialized services',
          services: ['Specialized care', 'Surgery', 'ICU services', 'Referral services'],
          color: const Color(0xFF7B1FA2),
        ),
      ],
    );
  }

  Widget _buildFacilityLevelCard({
    required String level,
    required String title,
    required String description,
    required List<String> services,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: services.take(2).map((service) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simplified remaining methods to fit within constraints
  Widget _buildHealthFinancingSection() {
    return _buildSimpleSection(
      'Universal Health Coverage',
      'The government ensures progressive financial access to healthcare through integrated insurance systems and social health protection.',
      Icons.account_balance_wallet,
      const Color(0xFF4CAF50),
    );
  }

  Widget _buildTraditionalMedicineSection() {
    return _buildSimpleSection(
      'Traditional & Alternative Medicine',
      'Integration of traditional medicine through policy formulation, regulation, and referral systems linking traditional practitioners to conventional facilities.',
      Icons.local_florist,
      const Color(0xFF2196F3),
    );
  }

  Widget _buildHealthResearchSection() {
    return _buildSimpleSection(
      'Health Research',
      'National Health Research Committee oversees research priorities, ethical standards, and allocates at least 30% of research funds to health.',
      Icons.science,
      const Color(0xFFFF9800),
    );
  }

  Widget _buildEHealthSection() {
    return _buildSimpleSection(
      'E-Health Services',
      'Formal recognition of telemedicine, M-health, e-learning, and integrated health information systems with data privacy protection.',
      Icons.computer,
      const Color(0xFF7B1FA2),
    );
  }

  Widget _buildPenaltiesEnforcementSection() {
    return _buildSimpleSection(
      'Penalties & Enforcement',
      'Violations include fines up to 10 million KES for illegal organ trade, 3 million KES for emergency treatment denial, and 2 million KES for general offenses.',
      Icons.gavel,
      const Color(0xFFF44336),
    );
  }

  Widget _buildLegalProtectionSection() {
    return _buildSimpleSection(
      'Legal Protection & Complaints',
      'Healthcare facilities must have complaint mechanisms with timely investigation and written feedback within three months.',
      Icons.shield,
      const Color(0xFF7B1FA2),
    );
  }

  Widget _buildSimpleSection(String title, String description, IconData icon, Color color) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
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
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
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
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Health Rights Matter',
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
            'Healthcare is your fundamental right. Know your rights, demand quality care, and report violations. Every healthcare facility must respect your dignity and provide appropriate care.',
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
                  content: Text('Ministry of Health contact information coming soon!'),
                  backgroundColor: Color(0xFFFF9800),
                ),
              );
            },
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Contact Ministry of Health'),
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
}
