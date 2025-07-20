import 'package:flutter/material.dart';
import '../widgets/module_completion_button.dart';
import '../services/progress_service.dart';

class BillOfRightsDetailScreen extends StatefulWidget {
  const BillOfRightsDetailScreen({super.key});

  @override
  State<BillOfRightsDetailScreen> createState() => _BillOfRightsDetailScreenState();
}

class _BillOfRightsDetailScreenState extends State<BillOfRightsDetailScreen> {
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
                    
                    // General Provisions Section
                    _buildGeneralProvisionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Key Definitions Section
                    _buildKeyDefinitionsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Fundamental Rights Section
                    _buildFundamentalRightsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Civil and Political Rights Section
                    _buildCivilPoliticalRightsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Economic Social Cultural Rights Section
                    _buildEconomicSocialCulturalRightsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Vulnerable Groups Protection Section
                    _buildVulnerableGroupsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Non-Derogable Rights Section
                    _buildNonDerogableRightsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // State of Emergency Section
                    _buildStateOfEmergencySection(),
                    
                    const SizedBox(height: 24),
                    
                    // Access to Justice Section
                    _buildAccessToJusticeSection(),
                    
                    const SizedBox(height: 24),
                    
                    // KNHREC Section
                    _buildKNHRECSection(),
                    
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
              moduleId: ProgressService.billOfRights,
              moduleName: 'Bill of Rights',
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
            'Bill of Rights',
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
          'Understanding Your Constitutional Rights & Freedoms in Kenya',
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
                '10 min read',
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
            'The Bill of Rights forms the foundation of Kenya\'s Constitution, guaranteeing fundamental human rights and freedoms to every individual. These rights are inalienable - they belong to you inherently and cannot be taken away by the state.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Core Constitutional Principles:',
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
            'Understanding these rights empowers you to claim protection, seek justice, and participate fully in Kenya\'s democratic society.',
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
      'Human dignity and equality for all',
      'Freedom of expression and conscience',
      'Right to life and personal security',
      'Access to justice without undue cost',
      'Protection from torture and slavery',
      'Social justice and rule of law',
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

  Widget _buildGeneralProvisionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'General Provisions of the Bill of Rights',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildProvisionCard(
          title: 'Inalienable Rights',
          description: 'Your rights belong to you as an individual, not granted by the state but protected by it.',
          icon: Icons.person,
          color: const Color(0xFF4CAF50), // Green
          provisions: ['Rights are inherent to every individual', 'State must protect, not grant rights', 'Article 19 Clause 3 guarantees individual ownership', 'Cannot be taken away by government'],
        ),
        const SizedBox(height: 12),
        _buildProvisionCard(
          title: 'State Obligations',
          description: 'The government must prioritize resources to ensure the widest possible enjoyment of rights.',
          icon: Icons.account_balance,
          color: const Color(0xFF2196F3), // Blue
          provisions: ['Prioritize resources for rights realization', 'Enable access to education and health', 'Ensure rights even under resource constraints', 'Progressive realization of economic rights'],
        ),
        const SizedBox(height: 12),
        _buildProvisionCard(
          title: 'Access to Justice',
          description: 'Citizens can initiate court proceedings without fees when their rights are threatened.',
          icon: Icons.gavel,
          color: const Color(0xFFFF9800), // Orange
          provisions: ['Free court proceedings for rights violations', 'Accessible justice for all citizens', 'No financial barriers to rights protection', 'Burden of proof on state authorities'],
        ),
      ],
    );
  }

  Widget _buildProvisionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> provisions,
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
          ...provisions.map((provision) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provision,
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

  Widget _buildKeyDefinitionsSection() {
    final definitions = [
      {
        'title': 'Inalienable Rights',
        'description': 'Fundamental rights that are inherent to every person and cannot be taken away or transferred.',
        'icon': Icons.security,
        'color': const Color(0xFF7B1FA2), // Purple
      },
      {
        'title': 'Human Dignity',
        'description': 'The inherent worth and value of every human being that must be respected and protected.',
        'icon': Icons.person,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Non-Derogable Rights',
        'description': 'Absolute rights that cannot be limited or suspended even during states of emergency.',
        'icon': Icons.shield,
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'title': 'Social Justice',
        'description': 'Fair treatment and equal opportunities for all members of society regardless of background.',
        'icon': Icons.balance,
        'color': const Color(0xFFFF9800), // Orange
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Constitutional Terms',
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

  Widget _buildFundamentalRightsSection() {
    final rights = [
      {
        'title': 'Right to Life',
        'description': 'Recognized from conception, influencing legislation on abortion and maternal welfare.',
        'icon': Icons.favorite,
        'color': const Color(0xFFF44336), // Red
      },
      {
        'title': 'Right to Human Dignity',
        'description': 'Respect and protection of the inherent worth and value of every person.',
        'icon': Icons.person,
        'color': const Color(0xFF7B1FA2), // Purple
      },
      {
        'title': 'Right to Equality',
        'description': 'Equal treatment before the law regardless of gender, ethnicity, religion, or social status.',
        'icon': Icons.balance,
        'color': const Color(0xFF4CAF50), // Green
      },
      {
        'title': 'Right to Personal Security',
        'description': 'Protection from arbitrary detention, torture, and cruel, inhuman, or degrading treatment.',
        'icon': Icons.security,
        'color': const Color(0xFF2196F3), // Blue
      },
      {
        'title': 'Right to Privacy',
        'description': 'Protection from arbitrary searches and interference with personal life and communications.',
        'icon': Icons.lock,
        'color': const Color(0xFFFF9800), // Orange
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Fundamental Rights',
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

  Widget _buildCivilPoliticalRightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Civil & Political Rights',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildRightsCategory(
          title: 'Freedom of Expression',
          icon: Icons.campaign,
          color: const Color(0xFF4CAF50),
          rights: [
            'Freedom of speech and opinion',
            'Right to seek and share information',
            'Freedom of the media',
            'Right to access state information',
          ],
          limitations: 'Limited by prohibitions on hate speech, incitement to violence, and propaganda for war.',
        ),
        const SizedBox(height: 16),
        _buildRightsCategory(
          title: 'Freedom of Association',
          icon: Icons.groups,
          color: const Color(0xFF2196F3),
          rights: [
            'Right to form or join groups',
            'Freedom of peaceful assembly',
            'Right to petition authorities',
            'Freedom to demonstrate and picket',
          ],
          limitations: 'Must be peaceful and not infringe on others\' rights.',
        ),
        const SizedBox(height: 16),
        _buildRightsCategory(
          title: 'Political Rights',
          icon: Icons.how_to_vote,
          color: const Color(0xFF7B1FA2),
          rights: [
            'Right to form political parties',
            'Right to campaign for office',
            'Right to vote in elections',
            'Right to participate in governance',
          ],
          limitations: 'Subject to electoral laws and constitutional requirements.',
        ),
      ],
    );
  }

  Widget _buildRightsCategory({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> rights,
    required String limitations,
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
          ...rights.map((right) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    right,
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    limitations,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simplified remaining methods to fit within constraints
  Widget _buildEconomicSocialCulturalRightsSection() {
    return _buildSimpleSection(
      'Economic, Social & Cultural Rights',
      'Rights to fair labor practices, healthy environment, education, healthcare, housing, and protection of languages and culture.',
      Icons.work,
      const Color(0xFF4CAF50),
    );
  }

  Widget _buildVulnerableGroupsSection() {
    return _buildSimpleSection(
      'Protection of Vulnerable Groups',
      'Special rights for children, people with disabilities, youth, minorities, marginalized groups, and older persons ensuring non-discrimination and equity.',
      Icons.diversity_3,
      const Color(0xFF2196F3),
    );
  }

  Widget _buildNonDerogableRightsSection() {
    return _buildSimpleSection(
      'Non-Derogable Rights',
      'Absolute rights that cannot be limited: freedom from torture, slavery, right to fair trial, and habeas corpus - protected even during emergencies.',
      Icons.shield,
      const Color(0xFFF44336),
    );
  }

  Widget _buildStateOfEmergencySection() {
    return _buildSimpleSection(
      'Rights During State of Emergency',
      'Emergency declarations require parliamentary approval with increasing thresholds. Rights limitations must be strictly necessary and proportionate.',
      Icons.warning,
      const Color(0xFFFF9800),
    );
  }

  Widget _buildAccessToJusticeSection() {
    return _buildSimpleSection(
      'Access to Justice',
      'Right to fair hearing, presumption of innocence, informed of charges, remain silent, and court proceedings without fees for rights violations.',
      Icons.gavel,
      const Color(0xFF7B1FA2),
    );
  }

  Widget _buildKNHRECSection() {
    return _buildSimpleSection(
      'Kenya National Human Rights Commission',
      'Guardian and promoter of human rights empowered to monitor, investigate, and enforce the Bill of Rights with systematic violation addressing.',
      Icons.account_balance,
      const Color(0xFF4CAF50),
    );
  }

  Widget _buildLegalProtectionSection() {
    return _buildSimpleSection(
      'Legal Protection & Remedies',
      'Courts can issue compensation and injunctions for rights violations. Chief Justice ensures accessible and effective remedies under the Bill of Rights.',
      Icons.security,
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
                  Icons.account_balance,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Constitutional Rights',
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
            'These rights are yours by virtue of being human. They cannot be taken away and must be protected by the state. Know your rights, exercise them responsibly, and seek justice when they are violated.',
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
                  content: Text('KNHREC contact information coming soon!'),
                  backgroundColor: Color(0xFFFF9800),
                ),
              );
            },
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Contact KNHREC'),
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
