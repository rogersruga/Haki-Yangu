import 'package:flutter/material.dart';
import '../widgets/module_completion_button.dart';
import '../services/progress_service.dart';

class GenderEqualityDetailScreen extends StatefulWidget {
  const GenderEqualityDetailScreen({super.key});

  @override
  State<GenderEqualityDetailScreen> createState() => _GenderEqualityDetailScreenState();
}

class _GenderEqualityDetailScreenState extends State<GenderEqualityDetailScreen> {
  bool isBookmarked = false;

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
              child: SingleChildScrollView(
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
                    
                    // NGEC Functions Section
                    _buildNGECFunctionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Key Definitions Section
                    _buildKeyDefinitionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Your Rights Section
                    _buildYourRightsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Gender Mainstreaming Section
                    _buildGenderMainstreamingSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Complaint Process Section
                    _buildComplaintProcessSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Investigative Powers Section
                    _buildInvestigativePowersSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Marginalized Groups Protection Section
                    _buildMarginalizedGroupsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Penalties and Enforcement Section
                    _buildPenaltiesEnforcementSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Legal Protection Section
                    _buildLegalProtectionSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Important Notice Section
                    _buildImportantNotice(),
                    
                    const SizedBox(height: 24), // Space for completion button
                  ],
                ),
              ),
            ),

            // Completion Button
            ModuleCompletionButton(
              moduleId: ProgressService.genderEquality,
              moduleName: 'Gender Equality',
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
            'Gender Equality',
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
          'Understanding Gender Equality & Your Rights in Kenya',
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
                '6 min read',
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
            'The National Gender and Equality Commission Act, 2011 establishes the NGEC as Kenya\'s constitutional body for promoting gender equality, protecting marginalized groups, and ensuring freedom from discrimination.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Core Principles:',
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
            'Understanding these rights helps you access protection, report discrimination, and participate in Kenya\'s journey toward true equality.',
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
      'Respect for Kenya\'s diversity and inclusiveness',
      'Gender equality and non-discrimination',
      'Protection of marginalized groups',
      'Adherence to human rights treaties',
      'Observance of natural justice and impartiality',
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

  Widget _buildNGECFunctionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NGEC Functions & Powers',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildFunctionCard(
          title: 'Promotion & Monitoring',
          description: 'Actively promotes gender equality and monitors integration of equality principles across national and county laws.',
          icon: Icons.trending_up,
          color: const Color(0xFF4CAF50), // Green
          functions: ['Promote gender equality', 'Monitor policy compliance', 'Advise on legal frameworks', 'Ensure treaty adherence'],
        ),
        const SizedBox(height: 12),
        _buildFunctionCard(
          title: 'Investigation & Enforcement',
          description: 'Investigates complaints and violations of equality principles, recommending improvements and remedies.',
          icon: Icons.search,
          color: const Color(0xFF2196F3), // Blue
          functions: ['Investigate complaints', 'Initiate inquiries', 'Recommend remedies', 'Refer criminal matters'],
        ),
        const SizedBox(height: 12),
        _buildFunctionCard(
          title: 'Research & Education',
          description: 'Conducts research and public education to foster a culture of equality and non-discrimination.',
          icon: Icons.school,
          color: const Color(0xFFFF9800), // Orange
          functions: ['Conduct research', 'Public education', 'Audit special groups', 'Produce reports'],
        ),
      ],
    );
  }

  Widget _buildFunctionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> functions,
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
            'Key Functions:',
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
            children: functions.map((function) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                function,
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
        'title': 'Gender Mainstreaming',
        'description': 'The process of integrating gender perspectives into all policies, programs, and activities to ensure equal benefits for all genders.',
        'icon': Icons.balance,
        'color': const Color(0xFF7B1FA2), // Purple
      },
      {
        'title': 'Marginalized Groups',
        'description': 'Groups that face discrimination including women, persons with disabilities, minorities, children, and other vulnerable populations.',
        'icon': Icons.groups,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Non-Discrimination',
        'description': 'The principle that all people should be treated equally regardless of gender, race, disability, or other characteristics.',
        'icon': Icons.people,
        'color': const Color(0xFF2196F3), // Blue
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Gender Equality Terms',
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
        'title': 'Right to Equal Treatment',
        'description': 'You cannot be discriminated against based on gender, race, disability, or other protected characteristics.',
        'icon': Icons.balance,
        'color': const Color(0xFF7B1FA2), // Purple
      },
      {
        'title': 'Right to File Complaints',
        'description': 'You can submit complaints to NGEC about discrimination or inequality, either orally or in writing.',
        'icon': Icons.report,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Right to Fair Investigation',
        'description': 'NGEC will investigate your complaint fairly, with due process and protection of your rights.',
        'icon': Icons.search,
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'title': 'Right to Remedies',
        'description': 'You are entitled to appropriate remedies and recommendations for addressing discrimination.',
        'icon': Icons.healing,
        'color': const Color(0xFFFF9800), // Orange
      },
      {
        'title': 'Right to Protection',
        'description': 'You are protected from retaliation for filing complaints or participating in investigations.',
        'icon': Icons.security,
        'color': const Color(0xFFF44336), // Red
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Gender Equality Rights',
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

  Widget _buildGenderMainstreamingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender Mainstreaming & Affirmative Action',
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
                      Icons.trending_up,
                      color: Color(0xFF7B1FA2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Development Planning Integration',
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
                'NGEC facilitates the mainstreaming of gender and marginalized groups in development planning and advises on affirmative action policies to ensure:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildMainstreamingPoint('Equal participation in decision-making processes'),
              _buildMainstreamingPoint('Fair representation in leadership positions'),
              _buildMainstreamingPoint('Equitable access to resources and opportunities'),
              _buildMainstreamingPoint('Integration of gender perspectives in all policies'),
              _buildMainstreamingPoint('Special measures for marginalized groups'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainstreamingPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: const Color(0xFF7B1FA2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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

  Widget _buildComplaintProcessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How to File a Complaint',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildProcessCard(
          title: 'Filing Your Complaint',
          icon: Icons.edit_document,
          color: const Color(0xFF4CAF50),
          steps: [
            'Submit complaint orally or in writing to NGEC',
            'Provide details of the discrimination or inequality',
            'Include any supporting evidence or documentation',
            'NGEC will record and review your complaint',
            'You may be asked for additional information',
            'Investigation will be initiated if warranted',
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF4CAF50),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'NGEC may decline to investigate trivial cases or those already adequately remedied, but will inform you of such decisions.',
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

  Widget _buildInvestigativePowersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NGEC Investigative Powers',
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
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel,
                      color: Color(0xFF2196F3),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Investigation Authority',
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
                'NGEC has comprehensive powers to investigate discrimination and equality violations:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildInvestigativePower('Investigate individuals, public offices, and private institutions'),
              _buildInvestigativePower('Enlist public officers and government agencies for assistance'),
              _buildInvestigativePower('Conduct public hearings when appropriate'),
              _buildInvestigativePower('Issue summonses and require evidence'),
              _buildInvestigativePower('Refer criminal matters to Director of Public Prosecutions'),
              _buildInvestigativePower('Recommend alternative judicial remedies'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Process Protection:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All persons potentially affected by investigations are entitled to be heard and present a defense. Statements made during proceedings are protected from use in other legal cases.',
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

  Widget _buildInvestigativePower(String power) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              power,
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

  Widget _buildMarginalizedGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Protection of Marginalized Groups',
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
                      Icons.diversity_3,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Special Protection Groups',
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
                'NGEC provides special protection and advocacy for:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Women', 'Persons with Disabilities', 'Minorities', 'Children',
                  'Elderly Persons', 'Youth', 'Ethnic Communities', 'Religious Groups'
                ].map((group) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    group,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
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
                      'Special Measures:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NGEC ensures compliance with international treaties and advises on affirmative action policies to promote equal participation and representation of marginalized groups in all sectors.',
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

  Widget _buildPenaltiesEnforcementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Penalties & Enforcement',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildPenaltyCard(
          title: 'Obstruction of NGEC',
          penalty: 'Up to 500,000 KES fine or 2 years imprisonment',
          icon: Icons.block,
          color: const Color(0xFFF44336),
        ),
        const SizedBox(height: 12),
        _buildPenaltyCard(
          title: 'False Information',
          penalty: 'Up to 500,000 KES fine or 2 years imprisonment',
          icon: Icons.report_problem,
          color: const Color(0xFFFF9800),
        ),
        const SizedBox(height: 12),
        _buildPenaltyCard(
          title: 'Failure to Honor Summons',
          penalty: 'Up to 500,000 KES fine or 2 years imprisonment',
          icon: Icons.gavel,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7B1FA2).withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF7B1FA2),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Enforcement Authority',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'NGEC has the authority to issue detailed reports with recommended actions and timelines. Organizations must provide progress reports on implementation, and unimplemented recommendations can be escalated to Parliament.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltyCard({
    required String title,
    required String penalty,
    required IconData icon,
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
                const SizedBox(height: 4),
                Text(
                  penalty,
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

  Widget _buildLegalProtectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legal Protection & Reporting',
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
                      Icons.shield,
                      color: Color(0xFF7B1FA2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'NGEC Reporting & Accountability',
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
                'NGEC maintains transparency and accountability through:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              _buildReportingService('Annual reports to President and Parliament'),
              _buildReportingService('Public dissemination of findings and recommendations'),
              _buildReportingService('Confidential handling of sensitive information'),
              _buildReportingService('Secure correspondence from persons in custody'),
              _buildReportingService('Collaboration with other human rights institutions'),
              _buildReportingService('International treaty compliance monitoring'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportingService(String service) {
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
            'If you experience discrimination or inequality, don\'t hesitate to contact NGEC. Your complaint can be submitted orally or in writing, and you have the right to fair investigation and appropriate remedies.',
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
                  content: Text('NGEC contact information coming soon!'),
                  backgroundColor: Color(0xFFFF9800),
                ),
              );
            },
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Contact NGEC'),
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
