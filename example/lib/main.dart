import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:genealogy_chart/genealogy_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genealogy Chart Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9747FF)),
        useMaterial3: true,
      ),
      home: const ExampleListPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Example List Page (10 cards, section headers)
// ---------------------------------------------------------------------------

class ExampleListPage extends StatelessWidget {
  const ExampleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genealogy Chart Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Core Demos'),
          _ExampleCard(
            title: 'Simple Family Tree',
            description: 'Search, export, 4-generation tree',
            icon: Icons.family_restroom,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SimpleFamilyTreePage()),
            ),
          ),
          _ExampleCard(
            title: 'Card & Detailed Styles',
            description: 'Toggle card / detailed node styles',
            icon: Icons.credit_card,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CardStylePage()),
            ),
          ),
          _ExampleCard(
            title: 'Compact View',
            description: 'Adjustable layout parameters',
            icon: Icons.view_compact,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompactViewPage()),
            ),
          ),
          _ExampleCard(
            title: 'Interactive Editing',
            description: 'Drag-drop, add/edit/delete members',
            icon: Icons.edit,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditingDemoPage()),
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Theming & Styling'),
          _ExampleCard(
            title: 'Custom Themes',
            description: 'Dark, midnight, forest, sunset palettes',
            icon: Icons.palette,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomThemesPage()),
            ),
          ),
          _ExampleCard(
            title: 'Edge Styles',
            description: 'Line style, arrows, width & color',
            icon: Icons.timeline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EdgeStylesPage()),
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(title: 'Advanced Features'),
          _ExampleCard(
            title: 'Generic Graph',
            description: 'Org chart with custom nodes & orientation',
            icon: Icons.account_tree,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GenericGraphPage()),
            ),
          ),
          _ExampleCard(
            title: 'Memorial Page',
            description: 'Historical family, deceased members',
            icon: Icons.local_florist,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MemorialPage()),
            ),
          ),
          _ExampleCard(
            title: 'Linked Families',
            description: 'Cross-family navigation',
            icon: Icons.link,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LinkedFamiliesPage()),
            ),
          ),
          _ExampleCard(
            title: 'Multiple Spouses',
            description: 'Remarriage & ex-spouse demo',
            icon: Icons.people,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MultipleSpousesPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample Data Generators
// ---------------------------------------------------------------------------

List<FamilyMember> generateSampleFamily() {
  return [
    // Great Grandparents (generation -2)
    FamilyMember(
      id: 'ggf',
      name: 'Robert Smith Sr.',
      firstName: 'Robert',
      lastName: 'Smith',
      gender: Gender.male,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.greatGrandfather,
      generation: -2,
      spouseIds: ['ggm'],
      birthDate: DateTime(1910, 3, 15),
      deathDate: DateTime(1985, 11, 2),
      bio: 'Founder of the Smith family homestead',
      location: 'Springfield, IL',
      causeOfDeath: 'Natural causes',
      burialLocation: 'Oak Hill Cemetery, Springfield',
    ),
    FamilyMember(
      id: 'ggm',
      name: 'Mary Smith',
      firstName: 'Mary',
      lastName: 'Smith',
      gender: Gender.female,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.greatGrandmother,
      generation: -2,
      spouseIds: ['ggf'],
      birthDate: DateTime(1912, 7, 22),
      deathDate: DateTime(1990, 4, 18),
      bio: 'Teacher and community leader',
      location: 'Springfield, IL',
      causeOfDeath: 'Natural causes',
      burialLocation: 'Oak Hill Cemetery, Springfield',
    ),

    // Grandparents (generation -1)
    FamilyMember(
      id: 'gf',
      name: 'John Smith',
      firstName: 'John',
      lastName: 'Smith',
      gender: Gender.male,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.grandfather,
      generation: -1,
      parentIds: ['ggf'],
      spouseIds: ['gm', 'gm2'],
      birthDate: DateTime(1935, 1, 10),
      deathDate: DateTime(2010, 6, 30),
      bio: 'Served in the military, later became an engineer',
      location: 'Chicago, IL',
      causeOfDeath: 'Heart disease',
      burialLocation: 'Rosehill Cemetery, Chicago',
    ),
    FamilyMember(
      id: 'gm',
      name: 'Elizabeth Smith',
      firstName: 'Elizabeth',
      lastName: 'Smith',
      gender: Gender.female,
      status: MemberStatus.offline,
      relationship: FamilyRelationship.grandmother,
      generation: -1,
      spouseIds: ['gf'],
      birthDate: DateTime(1938, 9, 5),
      bio: 'Retired nurse, avid gardener',
      location: 'Chicago, IL',
    ),
    // Second wife of grandfather
    FamilyMember(
      id: 'gm2',
      name: 'Patricia Davis',
      firstName: 'Patricia',
      lastName: 'Davis',
      gender: Gender.female,
      status: MemberStatus.offline,
      relationship: FamilyRelationship.grandmother,
      generation: -1,
      spouseIds: ['gf'],
      birthDate: DateTime(1940, 12, 1),
      bio: 'Artist and philanthropist',
      location: 'Evanston, IL',
    ),

    // Parents (generation 0)
    FamilyMember(
      id: 'father',
      name: 'Michael Smith',
      firstName: 'Michael',
      lastName: 'Smith',
      gender: Gender.male,
      status: MemberStatus.online,
      relationship: FamilyRelationship.father,
      generation: 0,
      parentIds: ['gf'],
      spouseIds: ['mother'],
      birthDate: DateTime(1965, 4, 20),
      bio: 'Software architect at a tech company',
      location: 'San Francisco, CA',
    ),
    FamilyMember(
      id: 'mother',
      name: 'Sarah Smith',
      firstName: 'Sarah',
      lastName: 'Johnson',
      gender: Gender.female,
      status: MemberStatus.online,
      relationship: FamilyRelationship.mother,
      generation: 0,
      spouseIds: ['father'],
      birthDate: DateTime(1967, 8, 14),
      bio: 'Pediatrician and volunteer',
      location: 'San Francisco, CA',
      linkedFamilies: [
        LinkedFamilyInfo(
          familyId: 'johnson-family',
          familyName: 'Johnson Family',
          memberId: 'mother',
          relationshipType: 'birth',
        ),
      ],
    ),
    // Uncle from second marriage
    FamilyMember(
      id: 'uncle_p',
      name: 'Thomas Smith',
      firstName: 'Thomas',
      lastName: 'Smith',
      gender: Gender.male,
      status: MemberStatus.online,
      relationship: FamilyRelationship.uncle,
      generation: 0,
      parentIds: ['gf'],
      spouseIds: ['aunt_p'],
      birthDate: DateTime(1970, 2, 28),
      bio: 'Chef and restaurant owner',
      location: 'New York, NY',
    ),
    FamilyMember(
      id: 'aunt_p',
      name: 'Linda Martinez',
      firstName: 'Linda',
      lastName: 'Martinez',
      gender: Gender.female,
      status: MemberStatus.online,
      relationship: FamilyRelationship.aunt,
      generation: 0,
      spouseIds: ['uncle_p'],
      birthDate: DateTime(1972, 5, 16),
      bio: 'Interior designer',
      location: 'New York, NY',
    ),

    // Self and siblings (generation 1)
    FamilyMember(
      id: 'self',
      name: 'David Smith',
      firstName: 'David',
      lastName: 'Smith',
      gender: Gender.male,
      status: MemberStatus.currentUser,
      relationship: FamilyRelationship.self,
      generation: 1,
      parentIds: ['father'],
      spouseIds: ['spouse'],
      birthDate: DateTime(1990, 6, 15),
      bio: 'Full-stack developer',
      location: 'Austin, TX',
    ),
    FamilyMember(
      id: 'spouse',
      name: 'Emma Wilson',
      firstName: 'Emma',
      lastName: 'Wilson',
      gender: Gender.female,
      status: MemberStatus.online,
      relationship: FamilyRelationship.spouse,
      generation: 1,
      spouseIds: ['self'],
      birthDate: DateTime(1992, 2, 10),
      bio: 'UX designer and illustrator',
      location: 'Austin, TX',
      linkedFamilies: [
        LinkedFamilyInfo(
          familyId: 'wilson-family',
          familyName: 'Wilson Family',
          memberId: 'spouse',
          relationshipType: 'birth',
        ),
      ],
    ),
    FamilyMember(
      id: 'brother',
      name: 'James Smith',
      firstName: 'James',
      lastName: 'Smith',
      gender: Gender.male,
      status: MemberStatus.offline,
      relationship: FamilyRelationship.brother,
      generation: 1,
      parentIds: ['father'],
      birthDate: DateTime(1993, 11, 3),
      bio: 'Marine biologist',
      location: 'San Diego, CA',
    ),
    FamilyMember(
      id: 'sister',
      name: 'Jessica Smith',
      firstName: 'Jessica',
      lastName: 'Smith',
      gender: Gender.female,
      status: MemberStatus.online,
      relationship: FamilyRelationship.sister,
      generation: 1,
      parentIds: ['father'],
      spouseIds: ['bil'],
      birthDate: DateTime(1995, 7, 19),
      bio: 'Elementary school teacher',
      location: 'Portland, OR',
    ),
    FamilyMember(
      id: 'bil',
      name: 'Mark Johnson',
      firstName: 'Mark',
      lastName: 'Johnson',
      gender: Gender.male,
      status: MemberStatus.offline,
      relationship: FamilyRelationship.brotherInLaw,
      generation: 1,
      spouseIds: ['sister'],
      birthDate: DateTime(1994, 1, 25),
      bio: 'Graphic designer',
      location: 'Portland, OR',
    ),

    // Children (generation 2)
    FamilyMember(
      id: 'son',
      name: 'Ethan Smith',
      firstName: 'Ethan',
      lastName: 'Smith',
      gender: Gender.male,
      status: MemberStatus.online,
      relationship: FamilyRelationship.son,
      generation: 2,
      parentIds: ['self'],
      birthDate: DateTime(2015, 5, 12),
      bio: 'Loves dinosaurs and soccer',
      location: 'Austin, TX',
    ),
    FamilyMember(
      id: 'daughter',
      name: 'Olivia Smith',
      firstName: 'Olivia',
      lastName: 'Smith',
      gender: Gender.female,
      status: MemberStatus.online,
      relationship: FamilyRelationship.daughter,
      generation: 2,
      parentIds: ['self'],
      birthDate: DateTime(2018, 8, 23),
      bio: 'Aspiring artist',
      location: 'Austin, TX',
    ),
    FamilyMember(
      id: 'nephew',
      name: 'Lucas Johnson',
      firstName: 'Lucas',
      lastName: 'Johnson',
      gender: Gender.male,
      status: MemberStatus.online,
      relationship: FamilyRelationship.nephew,
      generation: 2,
      parentIds: ['sister'],
      birthDate: DateTime(2016, 3, 7),
      bio: 'Loves building LEGO',
      location: 'Portland, OR',
    ),
  ];
}

List<FamilyMember> generateMemorialFamily() {
  return [
    FamilyMember(
      id: 'mem_gf',
      name: 'William Harrison',
      firstName: 'William',
      lastName: 'Harrison',
      gender: Gender.male,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.grandfather,
      generation: -1,
      spouseIds: ['mem_gm'],
      birthDate: DateTime(1890, 5, 1),
      deathDate: DateTime(1965, 12, 15),
      bio: 'WWI veteran, schoolmaster for 30 years',
      location: 'Boston, MA',
      causeOfDeath: 'Pneumonia',
      burialLocation: 'Mount Auburn Cemetery, Cambridge',
    ),
    FamilyMember(
      id: 'mem_gm',
      name: 'Eleanor Harrison',
      firstName: 'Eleanor',
      lastName: 'Harrison',
      gender: Gender.female,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.grandmother,
      generation: -1,
      spouseIds: ['mem_gf'],
      birthDate: DateTime(1895, 3, 22),
      deathDate: DateTime(1970, 8, 10),
      bio: 'Suffragette, published poet',
      location: 'Boston, MA',
      causeOfDeath: 'Stroke',
      burialLocation: 'Mount Auburn Cemetery, Cambridge',
    ),
    FamilyMember(
      id: 'mem_f',
      name: 'George Harrison',
      firstName: 'George',
      lastName: 'Harrison',
      gender: Gender.male,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.father,
      generation: 0,
      parentIds: ['mem_gf'],
      spouseIds: ['mem_m'],
      birthDate: DateTime(1920, 11, 8),
      deathDate: DateTime(1995, 2, 14),
      bio: 'WWII veteran, civil engineer who built bridges',
      location: 'New York, NY',
      causeOfDeath: 'Cancer',
      burialLocation: 'Green-Wood Cemetery, Brooklyn',
    ),
    FamilyMember(
      id: 'mem_m',
      name: 'Dorothy Harrison',
      firstName: 'Dorothy',
      lastName: 'Harrison',
      gender: Gender.female,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.mother,
      generation: 0,
      spouseIds: ['mem_f'],
      birthDate: DateTime(1925, 6, 30),
      deathDate: DateTime(2000, 9, 5),
      bio: 'Registered nurse, Red Cross volunteer',
      location: 'New York, NY',
      causeOfDeath: 'Heart failure',
      burialLocation: 'Green-Wood Cemetery, Brooklyn',
    ),
    FamilyMember(
      id: 'mem_uncle',
      name: 'Arthur Harrison',
      firstName: 'Arthur',
      lastName: 'Harrison',
      gender: Gender.male,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.uncle,
      generation: 0,
      parentIds: ['mem_gf'],
      birthDate: DateTime(1923, 4, 12),
      deathDate: DateTime(1944, 6, 6),
      bio: 'Gave his life on D-Day',
      location: 'Normandy, France',
      causeOfDeath: 'Killed in action',
      burialLocation: 'Normandy American Cemetery, France',
    ),
    FamilyMember(
      id: 'mem_s1',
      name: 'Richard Harrison',
      firstName: 'Richard',
      lastName: 'Harrison',
      gender: Gender.male,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.brother,
      generation: 1,
      parentIds: ['mem_f'],
      birthDate: DateTime(1948, 7, 4),
      deathDate: DateTime(2018, 1, 20),
      bio: 'Professor of History at Columbia University',
      location: 'New York, NY',
      causeOfDeath: 'Natural causes',
      burialLocation: 'Green-Wood Cemetery, Brooklyn',
    ),
    FamilyMember(
      id: 'mem_s2',
      name: 'Margaret Harrison',
      firstName: 'Margaret',
      lastName: 'Harrison',
      gender: Gender.female,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.sister,
      generation: 1,
      parentIds: ['mem_f'],
      birthDate: DateTime(1950, 10, 15),
      deathDate: DateTime(2020, 3, 8),
      bio: 'Classical pianist, performed at Carnegie Hall',
      location: 'Vienna, Austria',
      causeOfDeath: 'Respiratory illness',
      burialLocation: 'Zentralfriedhof, Vienna',
    ),
  ];
}

List<FamilyMember> generateWilsonFamily() {
  return [
    FamilyMember(
      id: 'w_gf',
      name: 'Henry Wilson',
      firstName: 'Henry',
      lastName: 'Wilson',
      gender: Gender.male,
      status: MemberStatus.deceased,
      relationship: FamilyRelationship.grandfather,
      generation: -1,
      spouseIds: ['w_gm'],
      birthDate: DateTime(1932, 3, 10),
      deathDate: DateTime(2005, 7, 22),
      bio: 'Farmer and community elder',
      location: 'Denver, CO',
    ),
    FamilyMember(
      id: 'w_gm',
      name: 'Rose Wilson',
      firstName: 'Rose',
      lastName: 'Wilson',
      gender: Gender.female,
      status: MemberStatus.offline,
      relationship: FamilyRelationship.grandmother,
      generation: -1,
      spouseIds: ['w_gf'],
      birthDate: DateTime(1935, 8, 18),
      bio: 'Quilter and baker, known for apple pies',
      location: 'Denver, CO',
    ),
    FamilyMember(
      id: 'w_father',
      name: 'Charles Wilson',
      firstName: 'Charles',
      lastName: 'Wilson',
      gender: Gender.male,
      status: MemberStatus.online,
      relationship: FamilyRelationship.father,
      generation: 0,
      parentIds: ['w_gf'],
      spouseIds: ['w_mother'],
      birthDate: DateTime(1960, 12, 5),
      bio: 'Veterinarian',
      location: 'Austin, TX',
    ),
    FamilyMember(
      id: 'w_mother',
      name: 'Karen Wilson',
      firstName: 'Karen',
      lastName: 'Wilson',
      gender: Gender.female,
      status: MemberStatus.online,
      relationship: FamilyRelationship.mother,
      generation: 0,
      spouseIds: ['w_father'],
      birthDate: DateTime(1962, 4, 17),
      bio: 'Botanist and nature photographer',
      location: 'Austin, TX',
    ),
    FamilyMember(
      id: 'w_emma',
      name: 'Emma Wilson',
      firstName: 'Emma',
      lastName: 'Wilson',
      gender: Gender.female,
      status: MemberStatus.online,
      relationship: FamilyRelationship.daughter,
      generation: 1,
      parentIds: ['w_father'],
      birthDate: DateTime(1992, 2, 10),
      bio: 'UX designer and illustrator',
      location: 'Austin, TX',
      linkedFamilies: [
        LinkedFamilyInfo(
          familyId: 'smith-family',
          familyName: 'Smith Family',
          memberId: 'spouse',
          relationshipType: 'marriage',
        ),
      ],
    ),
    FamilyMember(
      id: 'w_brother',
      name: 'Nathan Wilson',
      firstName: 'Nathan',
      lastName: 'Wilson',
      gender: Gender.male,
      status: MemberStatus.online,
      relationship: FamilyRelationship.son,
      generation: 1,
      parentIds: ['w_father'],
      birthDate: DateTime(1995, 9, 30),
      bio: 'Mechanical engineer',
      location: 'Houston, TX',
    ),
  ];
}

GraphData<String> _buildOrgChartData() {
  final nodes = <GraphNode<String>>[
    GraphNode(id: 'ceo', data: 'CEO\nAlice Johnson', childIds: ['cto', 'cfo', 'coo']),
    GraphNode(id: 'cto', data: 'CTO\nBob Chen', parentIds: ['ceo'], childIds: ['dev_lead', 'qa_lead']),
    GraphNode(id: 'cfo', data: 'CFO\nCarla Ruiz', parentIds: ['ceo'], childIds: ['accounting']),
    GraphNode(id: 'coo', data: 'COO\nDan Park', parentIds: ['ceo'], childIds: ['ops', 'hr']),
    GraphNode(id: 'dev_lead', data: 'Dev Lead\nEve Adams', parentIds: ['cto'], childIds: ['dev1', 'dev2']),
    GraphNode(id: 'qa_lead', data: 'QA Lead\nFrank Liu', parentIds: ['cto']),
    GraphNode(id: 'accounting', data: 'Accounting\nGrace Kim', parentIds: ['cfo']),
    GraphNode(id: 'ops', data: 'Operations\nHank Brown', parentIds: ['coo']),
    GraphNode(id: 'hr', data: 'HR\nIvy Patel', parentIds: ['coo']),
    GraphNode(id: 'dev1', data: 'Developer\nJack White', parentIds: ['dev_lead']),
    GraphNode(id: 'dev2', data: 'Developer\nKate Green', parentIds: ['dev_lead']),
  ];

  final edges = <GraphEdge>[
    GraphEdge(sourceId: 'ceo', targetId: 'cto'),
    GraphEdge(sourceId: 'ceo', targetId: 'cfo'),
    GraphEdge(sourceId: 'ceo', targetId: 'coo'),
    GraphEdge(sourceId: 'cto', targetId: 'dev_lead'),
    GraphEdge(sourceId: 'cto', targetId: 'qa_lead'),
    GraphEdge(sourceId: 'cfo', targetId: 'accounting'),
    GraphEdge(sourceId: 'coo', targetId: 'ops'),
    GraphEdge(sourceId: 'coo', targetId: 'hr'),
    GraphEdge(sourceId: 'dev_lead', targetId: 'dev1'),
    GraphEdge(sourceId: 'dev_lead', targetId: 'dev2'),
  ];

  return GraphData(nodes: nodes, edges: edges);
}

// ---------------------------------------------------------------------------
// 1. Simple Family Tree Page (Search + Export)
// ---------------------------------------------------------------------------

class SimpleFamilyTreePage extends StatefulWidget {
  const SimpleFamilyTreePage({super.key});

  @override
  State<SimpleFamilyTreePage> createState() => _SimpleFamilyTreePageState();
}

class _SimpleFamilyTreePageState extends State<SimpleFamilyTreePage> {
  final _controller = GenealogyChartController<FamilyMember>();
  final _repaintKey = GlobalKey();
  late final List<FamilyMember> _members;
  FamilyMember? _selectedMember;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _members = generateSampleFamily();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportChart() async {
    setState(() => _exporting = true);
    try {
      final Uint8List? bytes = await _controller.exportImage(
        repaintBoundaryKey: _repaintKey,
        format: ImageFormat.png,
        pixelRatio: 2.0,
      );
      if (!mounted) return;
      if (bytes != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported PNG (${bytes.length} bytes)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Family Tree'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          ChartSearchBar(
            controller: _controller,
            members: _members,
          ),
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.image),
            onPressed: _exporting ? null : _exportChart,
            tooltip: 'Export as PNG',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.resetView(),
            tooltip: 'Reset view',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedMember != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Selected: ${_selectedMember!.name}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (_selectedMember!.relationship.label != 'Other') ...[
                    const SizedBox(width: 8),
                    Text(
                      '(${_selectedMember!.relationship.label})',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() => _selectedMember = null);
                      _controller.clearSelection();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: GenealogyChart<FamilyMember>.family(
                members: _members,
                familyController: _controller,
                familyNodeStyle: FamilyNodeStyle.circleAvatar,
                onMemberTap: (member) {
                  setState(() => _selectedMember = member);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tapped: ${member.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                onMemberLongPress: (member) {
                  _showMemberOptions(context, member);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberOptions(BuildContext context, FamilyMember member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(member.name),
              subtitle: Text(member.relationship.label),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.child_care),
              title: const Text('Add Child'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Add Spouse'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Card & Detailed Styles Page
// ---------------------------------------------------------------------------

class CardStylePage extends StatefulWidget {
  const CardStylePage({super.key});

  @override
  State<CardStylePage> createState() => _CardStylePageState();
}

class _CardStylePageState extends State<CardStylePage> {
  late final List<FamilyMember> _members;
  FamilyNodeStyle _style = FamilyNodeStyle.card;
  FamilyMember? _selectedMember;

  @override
  void initState() {
    super.initState();
    _members = generateSampleFamily();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card & Detailed Styles'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<FamilyNodeStyle>(
              segments: const [
                ButtonSegment(
                  value: FamilyNodeStyle.card,
                  label: Text('Card'),
                  icon: Icon(Icons.credit_card),
                ),
                ButtonSegment(
                  value: FamilyNodeStyle.detailed,
                  label: Text('Detailed'),
                  icon: Icon(Icons.article),
                ),
              ],
              selected: {_style},
              onSelectionChanged: (s) => setState(() => _style = s.first),
            ),
          ),
          if (_selectedMember != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedMember!.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            _selectedMember!.relationship.label,
                            if (_selectedMember!.lifespan != null) _selectedMember!.lifespan,
                            if (_selectedMember!.location != null) _selectedMember!.location,
                          ].join(' \u2022 '),
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _selectedMember = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: _members,
              familyNodeStyle: _style,
              onMemberTap: (m) => setState(() => _selectedMember = m),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Compact View Page (adjustable layout params)
// ---------------------------------------------------------------------------

class CompactViewPage extends StatefulWidget {
  const CompactViewPage({super.key});

  @override
  State<CompactViewPage> createState() => _CompactViewPageState();
}

class _CompactViewPageState extends State<CompactViewPage> {
  late final List<FamilyMember> _members;
  double _generationHeight = 150;
  double _siblingSpacing = 80;
  double _spouseSpacing = 40;
  bool _panelExpanded = false;

  @override
  void initState() {
    super.initState();
    _members = generateSampleFamily();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compact View'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_panelExpanded ? Icons.tune_outlined : Icons.tune),
            onPressed: () => setState(() => _panelExpanded = !_panelExpanded),
            tooltip: 'Layout settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: _members,
              familyNodeStyle: FamilyNodeStyle.compact,
              layout: FamilyTreeLayout(
                generationHeight: _generationHeight,
                siblingSpacing: _siblingSpacing,
                spouseSpacing: _spouseSpacing,
              ),
              onMemberTap: (m) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${m.name} (${m.relationship.label})'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  _SliderRow(
                    label: 'Generation Height',
                    value: _generationHeight,
                    min: 80,
                    max: 300,
                    onChanged: (v) => setState(() => _generationHeight = v),
                  ),
                  _SliderRow(
                    label: 'Sibling Spacing',
                    value: _siblingSpacing,
                    min: 30,
                    max: 200,
                    onChanged: (v) => setState(() => _siblingSpacing = v),
                  ),
                  _SliderRow(
                    label: 'Spouse Spacing',
                    value: _spouseSpacing,
                    min: 10,
                    max: 120,
                    onChanged: (v) => setState(() => _spouseSpacing = v),
                  ),
                ],
              ),
            ),
            crossFadeState:
                _panelExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 44,
          child: Text(value.round().toString(), textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Custom Themes Page
// ---------------------------------------------------------------------------

class CustomThemesPage extends StatefulWidget {
  const CustomThemesPage({super.key});

  @override
  State<CustomThemesPage> createState() => _CustomThemesPageState();
}

class _CustomThemesPageState extends State<CustomThemesPage> {
  late final List<FamilyMember> _members;
  int _paletteIndex = 0;
  bool _showGrid = false;
  FamilyNodeStyle _nodeStyle = FamilyNodeStyle.circleAvatar;

  static const _paletteNames = ['Dark', 'Midnight Blue', 'Forest', 'Sunset'];

  @override
  void initState() {
    super.initState();
    _members = generateSampleFamily();
  }

  GenealogyChartTheme _buildTheme() {
    switch (_paletteIndex) {
      case 0: // Dark
        return GenealogyChartTheme.dark.copyWith(showGrid: _showGrid);
      case 1: // Midnight Blue
        return GenealogyChartTheme.dark.copyWith(
          backgroundColor: const Color(0xFF0D1B2A),
          gridColor: const Color(0xFF1B2838),
          showGrid: _showGrid,
          selectionColor: const Color(0xFF64B5F6),
          nodeTheme: const NodeTheme(
            backgroundColor: Color(0xFF1B2838),
            borderColor: Color(0xFF1E88E5),
            borderWidth: 2,
            statusColors: {
              MemberStatus.currentUser: Color(0xFF64B5F6),
              MemberStatus.online: Color(0xFF81C784),
              MemberStatus.offline: Color(0xFF78909C),
              MemberStatus.deceased: Color(0xFF616161),
            },
          ),
          edgeTheme: const EdgeTheme(
            lineColor: Color(0xFF1E88E5),
            spouseLineColor: Color(0xFF1E88E5),
            parentChildLineColor: Color(0xFF1E88E5),
            siblingLineColor: Color(0xFF1E88E5),
            primaryBranchColor: Color(0xFF1E88E5),
            secondaryBranchColor: Color(0xFF546E7A),
          ),
          nameTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          detailTextStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
        );
      case 2: // Forest
        return GenealogyChartTheme(
          backgroundColor: const Color(0xFF1B3A1B),
          gridColor: const Color(0xFF2E5A2E),
          showGrid: _showGrid,
          selectionColor: const Color(0xFFA5D6A7),
          nodeTheme: const NodeTheme(
            backgroundColor: Color(0xFF2E5A2E),
            borderColor: Color(0xFF4CAF50),
            borderWidth: 2,
            statusColors: {
              MemberStatus.currentUser: Color(0xFFA5D6A7),
              MemberStatus.online: Color(0xFF81C784),
              MemberStatus.offline: Color(0xFF78909C),
              MemberStatus.deceased: Color(0xFF616161),
            },
          ),
          edgeTheme: const EdgeTheme(
            lineColor: Color(0xFF4CAF50),
            spouseLineColor: Color(0xFF4CAF50),
            parentChildLineColor: Color(0xFF4CAF50),
            siblingLineColor: Color(0xFF4CAF50),
            primaryBranchColor: Color(0xFF4CAF50),
            secondaryBranchColor: Color(0xFF2E7D32),
          ),
          nameTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          detailTextStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
        );
      case 3: // Sunset
        return GenealogyChartTheme(
          backgroundColor: const Color(0xFF2D1B36),
          gridColor: const Color(0xFF3D2B46),
          showGrid: _showGrid,
          selectionColor: const Color(0xFFFFAB91),
          nodeTheme: const NodeTheme(
            backgroundColor: Color(0xFF3D2B46),
            borderColor: Color(0xFFFF7043),
            borderWidth: 2,
            statusColors: {
              MemberStatus.currentUser: Color(0xFFFFAB91),
              MemberStatus.online: Color(0xFFFFCC80),
              MemberStatus.offline: Color(0xFF78909C),
              MemberStatus.deceased: Color(0xFF616161),
            },
          ),
          edgeTheme: const EdgeTheme(
            lineColor: Color(0xFFFF7043),
            spouseLineColor: Color(0xFFFF7043),
            parentChildLineColor: Color(0xFFFF7043),
            siblingLineColor: Color(0xFFFF7043),
            primaryBranchColor: Color(0xFFFF7043),
            secondaryBranchColor: Color(0xFFBF360C),
          ),
          nameTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          detailTextStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
        );
      default:
        return GenealogyChartTheme.dark.copyWith(showGrid: _showGrid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _buildTheme();
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Theme: ${_paletteNames[_paletteIndex]}'),
        backgroundColor: theme.nodeTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: theme.nodeTheme.backgroundColor,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_paletteNames.length, (i) {
                      final selected = i == _paletteIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_paletteNames[i]),
                          selected: selected,
                          onSelected: (_) => setState(() => _paletteIndex = i),
                          selectedColor: theme.selectionColor.withValues(alpha: 0.3),
                          labelStyle: TextStyle(
                            color: selected ? theme.selectionColor : Colors.grey[400],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Grid'),
                      selected: _showGrid,
                      onSelected: (v) => setState(() => _showGrid = v),
                      selectedColor: theme.selectionColor.withValues(alpha: 0.3),
                      labelStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DropdownButton<FamilyNodeStyle>(
                          value: _nodeStyle,
                          dropdownColor: theme.nodeTheme.backgroundColor,
                          style: TextStyle(color: Colors.grey[300]),
                          underline: Container(height: 1, color: Colors.grey[600]),
                          items: FamilyNodeStyle.values.map((s) {
                            return DropdownMenuItem(value: s, child: Text(s.name));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _nodeStyle = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: _members,
              familyNodeStyle: _nodeStyle,
              theme: theme,
              onMemberTap: (m) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(m.name),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Edge Styles Page
// ---------------------------------------------------------------------------

class EdgeStylesPage extends StatefulWidget {
  const EdgeStylesPage({super.key});

  @override
  State<EdgeStylesPage> createState() => _EdgeStylesPageState();
}

class _EdgeStylesPageState extends State<EdgeStylesPage> {
  late final List<FamilyMember> _members;
  EdgeLineStyle _lineStyle = EdgeLineStyle.solid;
  ArrowType _arrowType = ArrowType.none;
  double _lineWidth = 2.0;
  int _colorIndex = 0;

  static const _colorPresets = <Color>[
    Color(0xFF9747FF),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFFFF9800),
  ];
  @override
  void initState() {
    super.initState();
    _members = generateSampleFamily();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorPresets[_colorIndex];
    final edgeTheme = EdgeTheme(
      lineColor: color,
      lineWidth: _lineWidth,
      lineStyle: _lineStyle,
      arrowStyle: ArrowStyle(type: _arrowType, size: 10, color: color),
      spouseLineColor: color,
      parentChildLineColor: color,
      siblingLineColor: color,
      primaryBranchColor: color,
      secondaryBranchColor: color.withValues(alpha: 0.5),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edge Styles'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line style
                Row(
                  children: [
                    const SizedBox(width: 72, child: Text('Line:', style: TextStyle(fontSize: 13))),
                    Expanded(
                      child: SegmentedButton<EdgeLineStyle>(
                        segments: const [
                          ButtonSegment(value: EdgeLineStyle.solid, label: Text('Solid')),
                          ButtonSegment(value: EdgeLineStyle.dashed, label: Text('Dashed')),
                          ButtonSegment(value: EdgeLineStyle.dotted, label: Text('Dotted')),
                        ],
                        selected: {_lineStyle},
                        onSelectionChanged: (s) => setState(() => _lineStyle = s.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Arrow type
                Row(
                  children: [
                    const SizedBox(width: 72, child: Text('Arrows:', style: TextStyle(fontSize: 13))),
                    Expanded(
                      child: SegmentedButton<ArrowType>(
                        segments: const [
                          ButtonSegment(value: ArrowType.none, label: Text('None')),
                          ButtonSegment(value: ArrowType.filled, label: Text('Filled')),
                          ButtonSegment(value: ArrowType.open, label: Text('Open')),
                          ButtonSegment(value: ArrowType.diamond, label: Text('Diamond')),
                        ],
                        selected: {_arrowType},
                        onSelectionChanged: (s) => setState(() => _arrowType = s.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Line width
                Row(
                  children: [
                    const SizedBox(width: 72, child: Text('Width:', style: TextStyle(fontSize: 13))),
                    Expanded(
                      child: Slider(
                        value: _lineWidth,
                        min: 1,
                        max: 6,
                        divisions: 10,
                        label: _lineWidth.toStringAsFixed(1),
                        onChanged: (v) => setState(() => _lineWidth = v),
                      ),
                    ),
                    SizedBox(width: 30, child: Text(_lineWidth.toStringAsFixed(1))),
                  ],
                ),
                // Color chips
                Row(
                  children: [
                    const SizedBox(width: 72, child: Text('Color:', style: TextStyle(fontSize: 13))),
                    ...List.generate(_colorPresets.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _colorIndex = i),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: _colorPresets[i],
                            child: i == _colorIndex
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: _members,
              familyNodeStyle: FamilyNodeStyle.circleAvatar,
              theme: GenealogyChartTheme(edgeTheme: edgeTheme),
              onMemberTap: (m) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(m.name),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Generic Graph Page (Org chart)
// ---------------------------------------------------------------------------

class GenericGraphPage extends StatefulWidget {
  const GenericGraphPage({super.key});

  @override
  State<GenericGraphPage> createState() => _GenericGraphPageState();
}

class _GenericGraphPageState extends State<GenericGraphPage> {
  final _controller = GenealogyChartController<String>();
  late final GraphData<String> _data;
  TreeOrientation _orientation = TreeOrientation.topToBottom;

  @override
  void initState() {
    super.initState();
    _data = _buildOrgChartData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generic Graph (Org Chart)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButton<TreeOrientation>(
              value: _orientation,
              isExpanded: true,
              items: TreeOrientation.values.map((o) {
                return DropdownMenuItem(value: o, child: Text(o.name));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _orientation = v);
              },
            ),
          ),
          Expanded(
            child: GenealogyChart<String>.graph(
              data: _data,
              controller: _controller,
              layout: TreeLayout<String>(
                configuration: LayoutConfiguration(orientation: _orientation),
              ),
              enableCollapse: true,
              nodeBuilder: (context, node, state) {
                final lines = node.data.split('\n');
                final title = lines.first;
                final subtitle = lines.length > 1 ? lines[1] : '';
                final isCollapsed = state.isCollapsed;
                return GestureDetector(
                  onDoubleTap: () => _controller.toggleCollapse(node.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: state.isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300]!,
                        width: state.isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        if (isCollapsed)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(Icons.expand_more, size: 14, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                  ),
                );
              },
              onNodeTap: (node) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped: ${node.data.split('\n').first}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              onNodeDoubleTap: (node) {
                _controller.toggleCollapse(node.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Memorial Page
// ---------------------------------------------------------------------------

class MemorialPage extends StatefulWidget {
  const MemorialPage({super.key});

  @override
  State<MemorialPage> createState() => _MemorialPageState();
}

class _MemorialPageState extends State<MemorialPage> {
  late final List<FamilyMember> _members;
  FamilyNodeStyle _style = FamilyNodeStyle.memorial;
  FamilyMember? _selected;

  @override
  void initState() {
    super.initState();
    _members = generateMemorialFamily();
  }

  int? _ageAtDeath(FamilyMember m) {
    if (m.birthDate != null && m.deathDate != null) {
      final years = m.deathDate!.year - m.birthDate!.year;
      final before = (m.deathDate!.month < m.birthDate!.month) ||
          (m.deathDate!.month == m.birthDate!.month && m.deathDate!.day < m.birthDate!.day);
      return before ? years - 1 : years;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorial'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<FamilyNodeStyle>(
              segments: const [
                ButtonSegment(value: FamilyNodeStyle.memorial, label: Text('Memorial')),
                ButtonSegment(value: FamilyNodeStyle.detailed, label: Text('Detailed')),
              ],
              selected: {_style},
              onSelectionChanged: (s) => setState(() => _style = s.first),
            ),
          ),
          if (_selected != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selected!.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  if (_selected!.lifespan != null)
                    Text('Lifespan: ${_selected!.lifespan}',
                        style: TextStyle(color: Colors.grey[700])),
                  if (_ageAtDeath(_selected!) != null)
                    Text('Age at death: ${_ageAtDeath(_selected!)}',
                        style: TextStyle(color: Colors.grey[700])),
                  if (_selected!.causeOfDeath != null)
                    Text('Cause: ${_selected!.causeOfDeath}',
                        style: TextStyle(color: Colors.grey[700])),
                  if (_selected!.burialLocation != null)
                    Text('Burial: ${_selected!.burialLocation}',
                        style: TextStyle(color: Colors.grey[700])),
                  if (_selected!.bio != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_selected!.bio!,
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                    ),
                ],
              ),
            ),
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: _members,
              familyNodeStyle: _style,
              onMemberTap: (m) => setState(() => _selected = m),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Linked Families Page
// ---------------------------------------------------------------------------

class LinkedFamiliesPage extends StatefulWidget {
  const LinkedFamiliesPage({super.key});

  @override
  State<LinkedFamiliesPage> createState() => _LinkedFamiliesPageState();
}

class _LinkedFamiliesPageState extends State<LinkedFamiliesPage> {
  late final List<FamilyMember> _smithFamily;
  late final List<FamilyMember> _wilsonFamily;
  String _currentFamilyId = 'smith-family';

  @override
  void initState() {
    super.initState();
    _smithFamily = generateSampleFamily();
    _wilsonFamily = generateWilsonFamily();
  }

  List<FamilyMember> get _currentMembers =>
      _currentFamilyId == 'smith-family' ? _smithFamily : _wilsonFamily;

  String get _currentFamilyName =>
      _currentFamilyId == 'smith-family' ? 'Smith Family' : 'Wilson Family';

  void _switchFamily(String familyId) {
    setState(() => _currentFamilyId = familyId);
  }

  void _showLinkedInfo(BuildContext context, FamilyMember member) {
    if (!member.hasLinkedFamily) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(member.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Member of $_currentFamilyName'),
            ),
            const Divider(),
            ...member.linkedFamilies.map((link) => ListTile(
                  leading: const Icon(Icons.link),
                  title: Text(link.familyName),
                  subtitle: Text('Linked via ${link.relationshipType}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pop(ctx);
                    _switchFamily(link.familyId);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Linked: $_currentFamilyName'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'smith-family', label: Text('Smith Family')),
                ButtonSegment(value: 'wilson-family', label: Text('Wilson Family')),
              ],
              selected: {_currentFamilyId},
              onSelectionChanged: (s) => _switchFamily(s.first),
            ),
          ),
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: _currentMembers,
              familyNodeStyle: FamilyNodeStyle.card,
              onMemberTap: (member) {
                if (member.hasLinkedFamily) {
                  _showLinkedInfo(context, member);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(member.name),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9. Multiple Spouses Page
// ---------------------------------------------------------------------------

class MultipleSpousesPage extends StatefulWidget {
  const MultipleSpousesPage({super.key});

  @override
  State<MultipleSpousesPage> createState() => _MultipleSpousesPageState();
}

class _MultipleSpousesPageState extends State<MultipleSpousesPage> {
  FamilyNodeStyle _style = FamilyNodeStyle.circleAvatar;
  FamilyMember? _selected;

  List<FamilyMember> _buildFamily() {
    return [
      FamilyMember(
        id: 'patriarch',
        name: 'John Smith',
        firstName: 'John',
        lastName: 'Smith',
        gender: Gender.male,
        status: MemberStatus.deceased,
        relationship: FamilyRelationship.grandfather,
        generation: -1,
        spouseIds: ['wife1', 'wife2'],
        birthDate: DateTime(1935, 1, 10),
        deathDate: DateTime(2010, 6, 30),
        bio: 'Patriarch with two marriages',
        location: 'Chicago, IL',
      ),
      FamilyMember(
        id: 'wife1',
        name: 'Elizabeth Smith',
        firstName: 'Elizabeth',
        lastName: 'Smith',
        gender: Gender.female,
        status: MemberStatus.offline,
        relationship: FamilyRelationship.grandmother,
        generation: -1,
        spouseIds: ['patriarch'],
        birthDate: DateTime(1938, 9, 5),
        bio: 'First wife, mother of Michael',
        location: 'Chicago, IL',
      ),
      FamilyMember(
        id: 'wife2',
        name: 'Patricia Davis',
        firstName: 'Patricia',
        lastName: 'Davis',
        gender: Gender.female,
        status: MemberStatus.offline,
        relationship: FamilyRelationship.exSpouse,
        generation: -1,
        spouseIds: ['patriarch'],
        birthDate: DateTime(1940, 12, 1),
        bio: 'Second wife, mother of Thomas',
        location: 'Evanston, IL',
      ),
      FamilyMember(
        id: 'ms_child1',
        name: 'Michael Smith',
        firstName: 'Michael',
        lastName: 'Smith',
        gender: Gender.male,
        status: MemberStatus.online,
        relationship: FamilyRelationship.father,
        generation: 0,
        parentIds: ['patriarch'],
        birthDate: DateTime(1965, 4, 20),
        bio: 'Son from first marriage',
        location: 'San Francisco, CA',
      ),
      FamilyMember(
        id: 'ms_child2',
        name: 'Thomas Smith',
        firstName: 'Thomas',
        lastName: 'Smith',
        gender: Gender.male,
        status: MemberStatus.online,
        relationship: FamilyRelationship.uncle,
        generation: 0,
        parentIds: ['patriarch'],
        birthDate: DateTime(1970, 2, 28),
        bio: 'Son from second marriage',
        location: 'New York, NY',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final members = _buildFamily();
    final patriarch = members.firstWhere((m) => m.id == 'patriarch');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Spouses'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<FamilyNodeStyle>(
              segments: const [
                ButtonSegment(value: FamilyNodeStyle.circleAvatar, label: Text('Circle')),
                ButtonSegment(value: FamilyNodeStyle.card, label: Text('Card')),
              ],
              selected: {_style},
              onSelectionChanged: (s) => setState(() => _style = s.first),
            ),
          ),
          // Info panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patriarch.name} \u2014 hasMultipleSpouses: ${patriarch.hasMultipleSpouses}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Spouse count: ${patriarch.spouseIds.length}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                if (_selected != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Selected: ${_selected!.name} (${_selected!.relationship.label})',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: members,
              familyNodeStyle: _style,
              onMemberTap: (m) => setState(() => _selected = m),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive Editing Demo Page (kept from original)
// ---------------------------------------------------------------------------

class EditingDemoPage extends StatefulWidget {
  const EditingDemoPage({super.key});

  @override
  State<EditingDemoPage> createState() => _EditingDemoPageState();
}

class _EditingDemoPageState extends State<EditingDemoPage> {
  late FamilyEditController _editController;
  final _chartController = GenealogyChartController<FamilyMember>();
  FamilyMember? _selectedMember;

  @override
  void initState() {
    super.initState();
    _editController = FamilyEditController(
      initialMembers: generateSampleFamily(),
      maxHistorySize: 50,
    );
    _editController.addListener(_onEditChange);
  }

  void _onEditChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _editController.removeListener(_onEditChange);
    _editController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Editing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _editController.canUndo ? () => _editController.undo() : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _editController.canRedo ? () => _editController.redo() : null,
            tooltip: 'Redo',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drag members to reparent. Tap to select, long-press for options.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedMember != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${_selectedMember!.name}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _ActionChip(
                    icon: Icons.edit,
                    label: 'Edit',
                    onPressed: () => _editMember(_selectedMember!),
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.person_add,
                    label: 'Add Child',
                    onPressed: () => _addChild(_selectedMember!),
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: Colors.red,
                    onPressed: () => _deleteMember(_selectedMember!),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() => _selectedMember = null);
                      _chartController.clearSelection();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: GenealogyChart<FamilyMember>.family(
              members: _editController.members,
              familyController: _chartController,
              editController: _editController,
              familyNodeStyle: FamilyNodeStyle.circleAvatar,
              enableDragDrop: true,
              onMemberTap: (member) {
                setState(() => _selectedMember = member);
              },
              onMemberLongPress: (member) {
                setState(() => _selectedMember = member);
                _showMemberMenu(context, member);
              },
              onMemberDropped: (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Moved ${result.droppedMember.name} \u2192 ${result.targetMember?.name ?? "canvas"} (${result.relation.name})',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewMember,
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
      ),
    );
  }

  void _showMemberMenu(BuildContext context, FamilyMember member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?'),
              ),
              title: Text(member.name),
              subtitle: Text(member.relationship.label),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editMember(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Child'),
              onTap: () {
                Navigator.pop(context);
                _addChild(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Add Spouse'),
              onTap: () {
                Navigator.pop(context);
                _addSpouse(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteMember(member);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addNewMember() async {
    final name = await _showNameDialog(context, 'Add New Member');
    if (name != null && name.isNotEmpty) {
      final newMember = FamilyMember(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        status: MemberStatus.online,
        relationship: FamilyRelationship.other,
        generation: 0,
      );
      _editController.addMember(newMember);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $name')),
      );
    }
  }

  void _editMember(FamilyMember member) async {
    final result = await MemberEditDialog.show(
      context,
      member: member,
      onDelete: (m) => _deleteMember(m),
    );
    if (result != null) {
      _editController.updateMember(result);
      setState(() => _selectedMember = result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${result.name}')),
      );
    }
  }

  void _addChild(FamilyMember parent) async {
    final name = await _showNameDialog(context, 'Add Child to ${parent.name}');
    if (name != null && name.isNotEmpty) {
      final child = FamilyMember(
        id: 'child_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        status: MemberStatus.online,
        relationship: FamilyRelationship.son,
        generation: parent.generation + 1,
      );
      _editController.addChild(child, parent.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $name as child of ${parent.name}')),
      );
    }
  }

  void _addSpouse(FamilyMember member) async {
    final name = await _showNameDialog(context, 'Add Spouse to ${member.name}');
    if (name != null && name.isNotEmpty) {
      final spouse = FamilyMember(
        id: 'spouse_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        status: MemberStatus.online,
        relationship: FamilyRelationship.spouse,
        generation: member.generation,
      );
      _editController.addSpouse(spouse, member.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $name as spouse of ${member.name}')),
      );
    }
  }

  void _deleteMember(FamilyMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _editController.removeMember(member.id);
      if (_selectedMember?.id == member.id) {
        setState(() => _selectedMember = null);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted ${member.name}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _editController.undo(),
          ),
        ),
      );
    }
  }

  Future<String?> _showNameDialog(BuildContext context, String title) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
    );
  }
}
