// lib/presentation/pages/study/quiz/quiz_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/quiz/quiz_notifier.dart';
import '../../../../application/quiz/quiz_state.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0D1B2A);
const _accent = Color(0xFFF4C430);
const _card = Color(0xFF162336);
const _surface = Color(0xFF1E2F45);
const _divider = Color(0xFF243447);

const _accentDim12 = Color(0x1FF4C430);
const _accentDim20 = Color(0x33F4C430);
const _accentDim35 = Color(0x59F4C430);
const _accentDim40 = Color(0x66F4C430);
const _accentDim80 = Color(0xCCF4C430);

const _white12 = Color(0x1FFFFFFF);
const _white15 = Color(0x26FFFFFF);
const _white25 = Color(0x40FFFFFF);
const _white45 = Color(0x73FFFFFF);
const _white55 = Color(0x8CFFFFFF);
const _black25 = Color(0x40000000);

// ── Subject Catalogue ─────────────────────────────────────────────────────────

class _SubjectEntry {
  final String name;
  final String emoji;
  final String category;
  final List<String> topics;

  const _SubjectEntry({
    required this.name,
    required this.emoji,
    required this.category,
    required this.topics,
  });
}

const List<_SubjectEntry> _kSubjects = [
  // ── FAST NUCES Core ──────────────────────────────────────────────────────
  _SubjectEntry(
    name: 'Programming Fundamentals',
    emoji: '🖥️',
    category: 'FAST Core',
    topics: [
      'Variables & Data Types',
      'Control Flow',
      'Functions & Recursion',
      'Arrays & Pointers',
      'File I/O',
      'Structs & Enums',
    ],
  ),
  _SubjectEntry(
    name: 'Object Oriented Programming',
    emoji: '🧩',
    category: 'FAST Core',
    topics: [
      'Classes & Objects',
      'Inheritance',
      'Polymorphism',
      'Encapsulation',
      'Abstraction',
      'Operator Overloading',
      'Templates & STL',
    ],
  ),
  _SubjectEntry(
    name: 'Data Structures & Algorithms',
    emoji: '🌲',
    category: 'FAST Core',
    topics: [
      'Arrays & Linked Lists',
      'Stacks & Queues',
      'Trees & BST',
      'Heaps & Priority Queues',
      'Graphs & BFS/DFS',
      'Sorting Algorithms',
      'Hashing',
    ],
  ),
  _SubjectEntry(
    name: 'Operating Systems',
    emoji: '⚙️',
    category: 'FAST Core',
    topics: [
      'Process Management',
      'Scheduling Algorithms',
      'Deadlocks',
      'Memory Management',
      'Virtual Memory',
      'File Systems',
      'I/O Systems',
    ],
  ),
  _SubjectEntry(
    name: 'Database Systems',
    emoji: '🗄️',
    category: 'FAST Core',
    topics: [
      'ER Modelling',
      'SQL Queries',
      'Normalization',
      'Transactions & ACID',
      'Indexing & B-Trees',
      'NoSQL Basics',
    ],
  ),
  _SubjectEntry(
    name: 'Computer Networks',
    emoji: '🌐',
    category: 'FAST Core',
    topics: [
      'OSI & TCP/IP Model',
      'HTTP & DNS',
      'IP Addressing & Subnetting',
      'TCP vs UDP',
      'Routing Algorithms',
      'Network Security',
    ],
  ),
  _SubjectEntry(
    name: 'Software Engineering',
    emoji: '🏗️',
    category: 'FAST Core',
    topics: [
      'SDLC Models',
      'Requirements Engineering',
      'UML Diagrams',
      'Design Patterns',
      'Testing Strategies',
      'Agile & Scrum',
    ],
  ),
  _SubjectEntry(
    name: 'Compiler Construction',
    emoji: '🔧',
    category: 'FAST Core',
    topics: [
      'Lexical Analysis',
      'Parsing & CFG',
      'Syntax-Directed Translation',
      'Semantic Analysis',
      'Intermediate Code',
      'Code Generation',
    ],
  ),
  _SubjectEntry(
    name: 'Artificial Intelligence',
    emoji: '🤖',
    category: 'FAST Core',
    topics: [
      'Search Algorithms',
      'Heuristics & A*',
      'Knowledge Representation',
      'Bayesian Networks',
      'Machine Learning Basics',
      'Neural Networks',
    ],
  ),

  // ── Mathematics ──────────────────────────────────────────────────────────
  _SubjectEntry(
    name: 'Calculus',
    emoji: '∫',
    category: 'Mathematics',
    topics: [
      'Limits & Continuity',
      'Differentiation',
      'Integration',
      'Series & Sequences',
      'Multivariable Calculus',
      'Differential Equations',
    ],
  ),
  _SubjectEntry(
    name: 'Linear Algebra',
    emoji: '📊',
    category: 'Mathematics',
    topics: [
      'Vectors & Matrices',
      'Matrix Operations',
      'Determinants',
      'Eigenvalues & Eigenvectors',
      'Linear Transformations',
      'SVD',
    ],
  ),
  _SubjectEntry(
    name: 'Discrete Mathematics',
    emoji: '🔢',
    category: 'Mathematics',
    topics: [
      'Set Theory',
      'Logic & Proofs',
      'Relations & Functions',
      'Graph Theory',
      'Combinatorics',
      'Number Theory',
    ],
  ),
  _SubjectEntry(
    name: 'Probability & Statistics',
    emoji: '🎲',
    category: 'Mathematics',
    topics: [
      'Probability Basics',
      'Distributions',
      'Expected Value',
      'Hypothesis Testing',
      'Regression',
      'Bayes Theorem',
    ],
  ),

  // ── CS Theory ────────────────────────────────────────────────────────────
  _SubjectEntry(
    name: 'Theory of Automata',
    emoji: '🤯',
    category: 'CS Theory',
    topics: [
      'DFA & NFA',
      'Regular Expressions',
      'Context-Free Grammars',
      'Pushdown Automata',
      'Turing Machines',
      'Decidability',
    ],
  ),
  _SubjectEntry(
    name: 'Design & Analysis of Algorithms',
    emoji: '📈',
    category: 'CS Theory',
    topics: [
      'Asymptotic Notation',
      'Divide & Conquer',
      'Dynamic Programming',
      'Greedy Algorithms',
      'NP-Completeness',
      'Approximation Algorithms',
    ],
  ),
  _SubjectEntry(
    name: 'Machine Learning',
    emoji: '🧠',
    category: 'CS Theory',
    topics: [
      'Supervised Learning',
      'Unsupervised Learning',
      'Decision Trees',
      'SVM',
      'Neural Networks',
      'Model Evaluation',
    ],
  ),
  _SubjectEntry(
    name: 'Information Security',
    emoji: '🔒',
    category: 'CS Theory',
    topics: [
      'Cryptography Basics',
      'Symmetric & Asymmetric Encryption',
      'Hashing',
      'Authentication',
      'Network Attacks',
      'PKI',
    ],
  ),

  // ── Programming Languages ─────────────────────────────────────────────
  _SubjectEntry(
    name: 'Python',
    emoji: '🐍',
    category: 'Programming',
    topics: [
      'Syntax & Data Types',
      'Functions & Lambdas',
      'OOP in Python',
      'File Handling',
      'Comprehensions',
      'Decorators & Generators',
    ],
  ),
  _SubjectEntry(
    name: 'Java',
    emoji: '☕',
    category: 'Programming',
    topics: [
      'OOP Concepts',
      'Collections Framework',
      'Exception Handling',
      'Multithreading',
      'Generics',
      'Java 8+ Features',
    ],
  ),
  _SubjectEntry(
    name: 'C++',
    emoji: '⚡',
    category: 'Programming',
    topics: [
      'Pointers & References',
      'STL',
      'Templates',
      'Smart Pointers',
      'Move Semantics',
      'Concurrency',
    ],
  ),
  _SubjectEntry(
    name: 'Dart & Flutter',
    emoji: '💙',
    category: 'Programming',
    topics: [
      'Dart Basics',
      'Async & Futures',
      'Widgets & State',
      'Navigation',
      'Riverpod',
      'Firebase Integration',
    ],
  ),

  // ── Engineering ───────────────────────────────────────────────────────
  _SubjectEntry(
    name: 'Digital Logic Design',
    emoji: '🔌',
    category: 'Engineering',
    topics: [
      'Boolean Algebra',
      'Logic Gates',
      'Combinational Circuits',
      'Sequential Circuits',
      'Flip-Flops',
      'FSMs',
    ],
  ),
  _SubjectEntry(
    name: 'Physics',
    emoji: '⚛️',
    category: 'Engineering',
    topics: [
      'Mechanics',
      'Thermodynamics',
      'Waves & Optics',
      'Electromagnetism',
      'Modern Physics',
      'Quantum Basics',
    ],
  ),
];

// Flat search list
List<_SubjectEntry> get _allSubjects => _kSubjects;

// Unique categories
List<String> get _categories =>
    _kSubjects.map((s) => s.category).toSet().toList();

// ── Question counts ───────────────────────────────────────────────────────────
const _kCounts = [5, 10, 15, 20];

// ── Page ─────────────────────────────────────────────────────────────────────

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  // Setup state
  _SubjectEntry? _subject;
  String _customSubject = '';
  bool _useCustomSubject = false;
  String _topic = ''; // optional specific topic
  int _count = 5;

  late final _notifier = ref.read(quizNotifierProvider.notifier);

  String get _effectiveSubject {
    if (_useCustomSubject) return _customSubject.trim();
    return _subject?.name ?? '';
  }

  bool get _canGenerate {
    if (_useCustomSubject) return _customSubject.trim().isNotEmpty;
    return _subject != null;
  }

  void _generate() {
    final subject = _topic.trim().isNotEmpty
        ? '$_effectiveSubject — $_topic'
        : _effectiveSubject;
    _notifier.generateQuiz(subject, _count);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizNotifierProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _accent, size: 18),
          onPressed:
              state is QuizInitial ? () => context.pop() : _notifier.resetQuiz,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _accentDim12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _accentDim20),
              ),
              child: const Center(
                  child: Text('📝', style: TextStyle(fontSize: 15))),
            ),
            const SizedBox(width: 10),
            const Text(
              'Quiz Generator',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                fontFamily: 'Georgia',
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: switch (state) {
          QuizInitial() => _SetupScreen(
              key: const ValueKey('setup'),
              subject: _subject,
              customSubject: _customSubject,
              useCustomSubject: _useCustomSubject,
              topic: _topic,
              count: _count,
              canGenerate: _canGenerate,
              onSubjectSelected: (s) => setState(() => _subject = s),
              onCustomSubjectChanged: (v) => setState(() => _customSubject = v),
              onUseCustomToggled: (v) => setState(() => _useCustomSubject = v),
              onTopicChanged: (v) => setState(() => _topic = v),
              onCountChanged: (v) => setState(() => _count = v),
              onGenerate: _generate,
            ),
          QuizLoading() => const _LoadingScreen(key: ValueKey('loading')),
          QuizLoaded(:final currentIndex) => _QuestionScreen(
              key: ValueKey('q-$currentIndex'),
              state: state,
              onAnswer: _notifier.answerQuestion,
              onNext: _notifier.nextQuestion,
            ),
          QuizFinished() => _FinishedScreen(
              key: const ValueKey('finished'),
              state: state,
              onRetry: _notifier.resetQuiz,
              onHome: context.pop,
            ),
          QuizFailure(:final error) => _FailureScreen(
              key: const ValueKey('failure'),
              error: error,
              onRetry: _notifier.resetQuiz,
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

// ── Setup Screen ──────────────────────────────────────────────────────────────

class _SetupScreen extends StatelessWidget {
  const _SetupScreen({
    super.key,
    required this.subject,
    required this.customSubject,
    required this.useCustomSubject,
    required this.topic,
    required this.count,
    required this.canGenerate,
    required this.onSubjectSelected,
    required this.onCustomSubjectChanged,
    required this.onUseCustomToggled,
    required this.onTopicChanged,
    required this.onCountChanged,
    required this.onGenerate,
  });

  final _SubjectEntry? subject;
  final String customSubject;
  final bool useCustomSubject;
  final String topic;
  final int count;
  final bool canGenerate;
  final ValueChanged<_SubjectEntry> onSubjectSelected;
  final ValueChanged<String> onCustomSubjectChanged;
  final ValueChanged<bool> onUseCustomToggled;
  final ValueChanged<String> onTopicChanged;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Banner ─────────────────────────────────────────────────
          _HeroBanner(
            subjectName: useCustomSubject
                ? (customSubject.isNotEmpty ? customSubject : null)
                : subject?.name,
          ),
          const SizedBox(height: 28),

          // ── Subject Section ─────────────────────────────────────────────
          const _SectionHeader(
            icon: Icons.menu_book_rounded,
            label: 'Choose Subject',
          ),
          const SizedBox(height: 12),

          // Toggle: catalogue vs custom
          _ToggleRow(
            useCustom: useCustomSubject,
            onToggle: onUseCustomToggled,
          ),
          const SizedBox(height: 12),

          // Either: subject browser or custom input
          if (useCustomSubject)
            _CustomSubjectInput(
              value: customSubject,
              onChanged: onCustomSubjectChanged,
            )
          else
            _SubjectSelector(
              selected: subject,
              onSelected: onSubjectSelected,
            ),

          const SizedBox(height: 24),

          // ── Topic Section ───────────────────────────────────────────────
          const _SectionHeader(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Specific Topic',
            badge: 'Optional',
          ),
          const SizedBox(height: 10),
          _TopicInput(
            subjectName:
                useCustomSubject ? customSubject : (subject?.name ?? ''),
            suggestedTopics: useCustomSubject ? [] : (subject?.topics ?? []),
            value: topic,
            onChanged: onTopicChanged,
          ),

          const SizedBox(height: 24),

          // ── Question Count ──────────────────────────────────────────────
          const _SectionHeader(
            icon: Icons.format_list_numbered_rounded,
            label: 'Number of Questions',
          ),
          const SizedBox(height: 12),
          _CountPicker(
            selected: count,
            onChanged: onCountChanged,
          ),

          const SizedBox(height: 32),

          // ── Generate Button ─────────────────────────────────────────────
          _GenerateButton(
            enabled: canGenerate,
            onPressed: onGenerate,
            subject: useCustomSubject ? customSubject : (subject?.name ?? ''),
            topic: topic,
            count: count,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({this.subjectName});
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentDim20),
        boxShadow: const [
          BoxShadow(color: _accentDim12, blurRadius: 24, spreadRadius: 0),
          BoxShadow(color: _black25, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Emblem
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accentDim12,
              border: Border.all(color: _accentDim35, width: 1.5),
            ),
            child:
                const Center(child: Text('🎓', style: TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 14),
          const Text(
            'Test Your Knowledge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              subjectName != null
                  ? 'Ready to quiz on $subjectName'
                  : 'Select a subject to get started',
              key: ValueKey(subjectName),
              style: const TextStyle(
                color: _white55,
                fontSize: 13,
                fontFamily: 'Georgia',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _accentDim12,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: _accentDim20),
          ),
          child: Icon(icon, color: _accent, size: 15),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _accentDim80,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Georgia',
            letterSpacing: 1.6,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _white12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge!,
              style: const TextStyle(
                color: _white45,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Toggle: Catalogue vs Custom ───────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.useCustom, required this.onToggle});
  final bool useCustom;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _divider),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: '📚  Browse Subjects',
            active: !useCustom,
            onTap: () => onToggle(false),
          ),
          _ToggleTab(
            label: '✏️  Custom Subject',
            active: useCustom,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? _accentDim20 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? _accentDim35 : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? _accent : _white45,
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              fontFamily: 'Georgia',
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom Subject Input ──────────────────────────────────────────────────────

class _CustomSubjectInput extends StatelessWidget {
  const _CustomSubjectInput({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StyledTextField(
          initialValue: value,
          onChanged: onChanged,
          hint: 'e.g. Thermodynamics, React Native, Sanskrit...',
          prefixIcon: Icons.edit_outlined,
          autofocus: true,
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Enter any subject — our AI will generate questions on it.',
            style: TextStyle(
              color: _white45,
              fontSize: 11,
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Subject Selector ──────────────────────────────────────────────────────────

class _SubjectSelector extends StatefulWidget {
  const _SubjectSelector({required this.selected, required this.onSelected});
  final _SubjectEntry? selected;
  final ValueChanged<_SubjectEntry> onSelected;

  @override
  State<_SubjectSelector> createState() => _SubjectSelectorState();
}

class _SubjectSelectorState extends State<_SubjectSelector> {
  String _query = '';
  String? _activeCategory;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SubjectEntry> get _filtered {
    var list = _allSubjects;
    if (_query.isNotEmpty) {
      list = list
          .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    } else if (_activeCategory != null) {
      list = list.where((s) => s.category == _activeCategory).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        _StyledTextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          hint: 'Search subjects...',
          prefixIcon: Icons.search_rounded,
          suffixWidget: _query.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: _white45),
                )
              : null,
        ),
        const SizedBox(height: 10),

        // Category filter chips (hidden during search)
        if (_query.isEmpty) ...[
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'All',
                  active: _activeCategory == null,
                  onTap: () => setState(() => _activeCategory = null),
                ),
                ...(_categories.map((cat) => _CategoryChip(
                      label: cat,
                      active: _activeCategory == cat,
                      onTap: () => setState(() => _activeCategory =
                          _activeCategory == cat ? null : cat),
                    ))),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Subject list
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _divider),
          ),
          constraints: const BoxConstraints(maxHeight: 260),
          child: _filtered.isEmpty
              ? _EmptySearch(query: _query)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: _divider,
                    ),
                    itemBuilder: (context, i) {
                      final s = _filtered[i];
                      final isSelected = s.name == widget.selected?.name;
                      return _SubjectListTile(
                        entry: s,
                        isSelected: isSelected,
                        onTap: () => widget.onSelected(s),
                      );
                    },
                  ),
                ),
        ),

        // Selected badge
        if (widget.selected != null) ...[
          const SizedBox(height: 10),
          _SelectedBadge(entry: widget.selected!),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _accentDim20 : _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? _accentDim40 : _divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? _accent : _white55,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            fontFamily: 'Georgia',
          ),
        ),
      ),
    );
  }
}

class _SubjectListTile extends StatelessWidget {
  const _SubjectListTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });
  final _SubjectEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: isSelected ? _accentDim12 : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Text(entry.emoji, style: const TextStyle(fontSize: 17)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: TextStyle(
                        color: isSelected ? _accent : Colors.white,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    Text(
                      entry.category,
                      style: const TextStyle(
                        color: _white45,
                        fontSize: 11,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: _accent, size: 18)
              else
                const Icon(Icons.chevron_right_rounded,
                    color: _white25, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge({required this.entry});
  final _SubjectEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _accentDim12,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accentDim20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: _accent, size: 14),
          const SizedBox(width: 6),
          Text(
            '${entry.emoji}  ${entry.name}',
            style: const TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            'No results for "$query"',
            style: const TextStyle(
              color: _white55,
              fontFamily: 'Georgia',
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Switch to Custom Subject to use it anyway',
            style: TextStyle(
              color: _white25,
              fontFamily: 'Georgia',
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Topic Input ───────────────────────────────────────────────────────────────

class _TopicInput extends StatefulWidget {
  const _TopicInput({
    required this.subjectName,
    required this.suggestedTopics,
    required this.value,
    required this.onChanged,
  });
  final String subjectName;
  final List<String> suggestedTopics;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_TopicInput> createState() => _TopicInputState();
}

class _TopicInputState extends State<_TopicInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TopicInput old) {
    super.didUpdateWidget(old);
    // Sync controller if subject changed and parent cleared topic
    if (widget.value != _ctrl.text && widget.value.isEmpty) {
      _ctrl.clear();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StyledTextField(
          controller: _ctrl,
          onChanged: widget.onChanged,
          hint: widget.subjectName.isNotEmpty
              ? 'e.g. specific topic in ${widget.subjectName}...'
              : 'e.g. Recursion, SQL Joins, Newton\'s Laws...',
          prefixIcon: Icons.topic_outlined,
        ),
        // Suggested topic chips
        if (widget.suggestedTopics.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'SUGGESTIONS',
            style: TextStyle(
              color: _white25,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.suggestedTopics.map((t) {
              final active = _ctrl.text == t;
              return GestureDetector(
                onTap: () {
                  final next = active ? '' : t;
                  _ctrl.text = next;
                  widget.onChanged(next);
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: active ? _accentDim20 : _surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: active ? _accentDim40 : _divider,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: active ? _accent : _white55,
                      fontSize: 11,
                      fontFamily: 'Georgia',
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ── Count Picker ──────────────────────────────────────────────────────────────

class _CountPicker extends StatelessWidget {
  const _CountPicker({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _kCounts.map((count) {
        final active = count == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(count),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  color: active ? _accentDim20 : _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? _accentDim40 : _divider,
                    width: active ? 1.5 : 1,
                  ),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: _accentDim20,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        color: active ? _accent : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    Text(
                      'Qs',
                      style: TextStyle(
                        color: active ? _accentDim80 : _white25,
                        fontSize: 10,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Generate Button ───────────────────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({
    required this.enabled,
    required this.onPressed,
    required this.subject,
    required this.topic,
    required this.count,
  });

  final bool enabled;
  final VoidCallback onPressed;
  final String subject;
  final String topic;
  final int count;

  @override
  Widget build(BuildContext context) {
    final label = topic.trim().isNotEmpty
        ? '$count questions on "$topic" ($subject)'
        : '$count questions on $subject';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: enabled
                  ? const [
                      BoxShadow(
                        color: _accentDim35,
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? _accent : _surface,
                foregroundColor: _bg,
                disabledBackgroundColor: _surface,
                disabledForegroundColor: _white25,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 19),
                  SizedBox(width: 10),
                  Text(
                    'Generate Quiz',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      fontFamily: 'Georgia',
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (enabled && subject.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: _white45,
              fontSize: 11,
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (!enabled) ...[
          const SizedBox(height: 8),
          const Text(
            'Select or enter a subject to continue',
            style: TextStyle(
              color: _white25,
              fontSize: 11,
              fontFamily: 'Georgia',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ── Styled Text Field (shared) ────────────────────────────────────────────────

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    this.controller,
    this.initialValue,
    required this.onChanged,
    required this.hint,
    required this.prefixIcon,
    this.suffixWidget,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixWidget;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Georgia',
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _white25,
          fontFamily: 'Georgia',
          fontSize: 13,
        ),
        prefixIcon: Icon(prefixIcon, color: _white45, size: 18),
        suffixIcon: suffixWidget != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixWidget,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: _card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      ),
    );
  }
}

// ── Loading Screen ────────────────────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _accentDim12,
              shape: BoxShape.circle,
              border: Border.all(color: _accentDim35, width: 1.5),
            ),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: _accent,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Crafting your quiz...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This usually takes a few seconds',
            style: TextStyle(
              color: _white45,
              fontSize: 12,
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question Screen ───────────────────────────────────────────────────────────

class _QuestionScreen extends StatelessWidget {
  const _QuestionScreen({
    super.key,
    required this.state,
    required this.onAnswer,
    required this.onNext,
  });

  final QuizLoaded state;
  final ValueChanged<String> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final current = state.currentIndex;
    final total = state.questions.length;
    final question = state.questions[current];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (current + 1) / total,
                    backgroundColor: _card,
                    color: _accent,
                    minHeight: 7,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${current + 1} / $total',
                style: const TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Georgia',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Question ${current + 1} of $total',
            style: const TextStyle(
              color: _white45,
              fontSize: 11,
              fontFamily: 'Georgia',
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 18),

          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _accentDim20),
              boxShadow: const [
                BoxShadow(
                    color: _black25, blurRadius: 12, offset: Offset(0, 4)),
              ],
            ),
            child: Text(
              question.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'Georgia',
                height: 1.55,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Options
          ...question.options.map((option) => _OptionTile(
                option: option,
                answer: question.answer,
                selectedAnswer: state.selectedAnswer,
                answered: state.answered,
                onTap: state.answered ? null : () => onAnswer(option),
              )),

          if (state.answered) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      current + 1 < total ? 'Next Question' : 'See Results',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: 'Georgia',
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 17),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

// ── Option Tile ───────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.answer,
    required this.selectedAnswer,
    required this.answered,
    required this.onTap,
  });

  final String option;
  final String answer;
  final String? selectedAnswer;
  final bool answered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bgColor = _card;
    Color borderColor = _white15;
    Widget? trailingIcon;

    if (answered) {
      if (option == answer) {
        bgColor = const Color(0xFF1A4731);
        borderColor = Colors.greenAccent;
        trailingIcon = const Icon(Icons.check_circle_rounded,
            color: Colors.greenAccent, size: 20);
      } else if (option == selectedAnswer) {
        bgColor = const Color(0xFF4A1A1A);
        borderColor = Colors.redAccent;
        trailingIcon =
            const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Georgia',
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    trailingIcon,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Finished Screen ───────────────────────────────────────────────────────────

class _FinishedScreen extends StatelessWidget {
  const _FinishedScreen({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onHome,
  });

  final QuizFinished state;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  static const _thresholds = [
    (0.8, '🌟  Excellent!', Color(0xFF4CAF7D)),
    (0.6, '👍  Good Job!', _accent),
    (0.4, '📖  Keep Going!', Color(0xFFFF9800)),
  ];

  (String, Color) get _result {
    final pct = state.score / state.total;
    for (final (t, msg, color) in _thresholds) {
      if (pct >= t) return (msg, color);
    }
    return ('💪  Keep Practising!', Colors.orangeAccent);
  }

  @override
  Widget build(BuildContext context) {
    final (msg, scoreColor) = _result;
    final pct = (state.score / state.total * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          children: [
            // Trophy
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                border: Border.all(color: _accentDim40, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: _accentDim20, blurRadius: 28, spreadRadius: 4),
                ],
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                fontFamily: 'Georgia',
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 20),

            // Score ring
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accentDim20),
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${state.score}',
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      TextSpan(
                        text: ' / ${state.total}',
                        style: const TextStyle(
                          color: _white55,
                          fontSize: 28,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  // Mini progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: state.score / state.total,
                      backgroundColor: _surface,
                      color: scoreColor,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$pct% correct',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 13,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              style: TextStyle(
                color: scoreColor,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia',
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 36),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: _accentDim40,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    fontFamily: 'Georgia',
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: onHome,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: _white25, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Go Home',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    fontFamily: 'Georgia',
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Failure Screen ────────────────────────────────────────────────────────────

class _FailureScreen extends StatelessWidget {
  const _FailureScreen({super.key, required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0x1FCF6679),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33CF6679)),
              ),
              child: const Center(
                child: Text('⚠️', style: TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              style: const TextStyle(
                color: _white55,
                fontSize: 13,
                fontFamily: 'Georgia',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
