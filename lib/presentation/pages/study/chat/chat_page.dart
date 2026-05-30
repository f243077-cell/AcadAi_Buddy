// lib/presentation/pages/study/chat/chat_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../application/chat/chat_notifier.dart';
import '../../../../application/chat/chat_state.dart';
import '../../../../domain/study/entities/chat_message.dart';
import '../../../core/theme.dart';
import 'widgets/message_bubble.dart';

// ── Palette aliases ───────────────────────────────────────────────────────────
const _kBackground = AppColors.background;
const _kSurface = AppColors.surface;
const _kSurfaceAlt = AppColors.surfaceAlt;
const _kAccent = AppColors.accent;
const _kTextPrimary = AppColors.textPrimary;
const _kTextSecondary = AppColors.textSecondary;
const _kTextHint = AppColors.textHint;
const _kDivider = AppColors.divider;
const _kError = AppColors.error;

// ── Subject Catalogue (kept in sync with quiz_page) ───────────────────────────

class SubjectCategory {
  final String name;
  final String emoji;
  final List<String> subjects;
  const SubjectCategory({
    required this.name,
    required this.emoji,
    required this.subjects,
  });
}

const List<SubjectCategory> kSubjectCategories = [
  SubjectCategory(
    name: 'FAST NUCES Core',
    emoji: '🏫',
    subjects: [
      'Programming Fundamentals',
      'Object Oriented Programming',
      'Data Structures & Algorithms',
      'Software Design & Architecture',
      'Software Requirements Engineering',
      'Operating Systems',
      'Database Systems',
      'Computer Networks',
      'Compiler Construction',
      'Artificial Intelligence',
    ],
  ),
  SubjectCategory(
    name: 'Mathematics',
    emoji: '📐',
    subjects: [
      'Calculus',
      'Linear Algebra',
      'Discrete Mathematics',
      'Probability & Statistics',
      'Numerical Methods',
      'Differential Equations',
    ],
  ),
  SubjectCategory(
    name: 'Programming',
    emoji: '💻',
    subjects: [
      'Python',
      'Java',
      'C++',
      'C',
      'Dart & Flutter',
      'JavaScript',
      'Assembly Language',
      'Data Science with Python',
    ],
  ),
  SubjectCategory(
    name: 'CS Theory',
    emoji: '🧠',
    subjects: [
      'Theory of Automata',
      'Design & Analysis of Algorithms',
      'Computer Architecture',
      'Parallel Computing',
      'Information Security',
      'Machine Learning',
      'Deep Learning',
    ],
  ),
  SubjectCategory(
    name: 'Engineering',
    emoji: '⚙️',
    subjects: [
      'Physics',
      'Applied Physics',
      'Digital Logic Design',
      'Signals & Systems',
      'Microprocessors',
      'Electronics',
    ],
  ),
  SubjectCategory(
    name: 'Soft Skills',
    emoji: '📚',
    subjects: [
      'Technical Writing',
      'Communication Skills',
      'Professional Ethics',
      'Project Management',
      'Entrepreneurship',
    ],
  ),
];

List<String> get kAllSubjects =>
    kSubjectCategories.expand((c) => c.subjects).toList();

// ── Subject Relevance Guard ───────────────────────────────────────────────────
//
// Strategy: build a keyword fingerprint for every known subject, then score
// the user's message against the *selected* subject and all *other* subjects.
// If the message strongly matches a *different* subject and weakly matches the
// selected one, we surface a warning instead of sending.
//
// This runs in O(n·k) — entirely synchronous, zero API calls.

class _SubjectGuard {
  _SubjectGuard._();

  // ── Per-subject keyword sets ──────────────────────────────────────────────
  // Each entry maps a canonical subject name to a list of trigger keywords.
  // Keywords are lower-case; partial substring matching is used so that e.g.
  // "recursion" matches "recursive".
  static const Map<String, List<String>> _keywords = {
    // General off-topic / humanities
    'english': [
      'grammar',
      'essay',
      'novel',
      'poem',
      'prose',
      'literature',
      'shakespeare',
      'tense',
      'vocabulary',
      'punctuation',
      'paragraph',
      'creative writing',
      'fiction',
      'nonfiction',
      'syntax english'
    ],
    'history': [
      'world war',
      'revolution',
      'empire',
      'colonialism',
      'dynasty',
      'ancient',
      'medieval',
      'renaissance',
      'napoleon',
      'civilization',
      'archaeology',
      'ottoman',
      'mughal',
      'crusades'
    ],
    'geography': [
      'continent',
      'country',
      'capital city',
      'latitude',
      'longitude',
      'ocean',
      'mountain range',
      'river basin',
      'climate zone',
      'population density',
      'gdp per capita'
    ],
    'biology': [
      'cell',
      'dna',
      'rna',
      'mitosis',
      'meiosis',
      'photosynthesis',
      'evolution',
      'genetics',
      'organism',
      'ecosystem',
      'anatomy',
      'bacteria',
      'virus',
      'enzyme',
      'chromosome',
      'protein synthesis'
    ],
    'chemistry': [
      'periodic table',
      'element',
      'atom',
      'molecule',
      'bond',
      'reaction',
      'acid',
      'base',
      'solution',
      'oxidation',
      'reduction',
      'organic chemistry',
      'inorganic',
      'titration',
      'mole',
      'valence'
    ],
    'economics': [
      'supply',
      'demand',
      'inflation',
      'gdp',
      'fiscal policy',
      'monetary policy',
      'stock market',
      'recession',
      'trade deficit',
      'microeconomics',
      'macroeconomics'
    ],
    'psychology': [
      'cognition',
      'behaviour',
      'stimulus',
      'freud',
      'pavlov',
      'phobia',
      'anxiety disorder',
      'personality test',
      'iq',
      'mental health',
      'therapy',
      'psychoanalysis'
    ],
    'law': [
      'constitution',
      'statute',
      'tort',
      'contract law',
      'criminal law',
      'plaintiff',
      'defendant',
      'judiciary',
      'amendment',
      'verdict'
    ],
    'cooking': [
      'recipe',
      'ingredient',
      'bake',
      'fry',
      'boil',
      'cuisine',
      'spice',
      'dish',
      'meal prep',
      'calories',
      'nutrition'
    ],
    'sports': [
      'football',
      'cricket',
      'basketball',
      'tennis',
      'player',
      'match',
      'tournament',
      'league',
      'referee',
      'offside'
    ],

    // CS / STEM subjects already in the catalogue — fine to ask about them
    'Programming Fundamentals': [
      'variable',
      'loop',
      'function',
      'array',
      'pointer',
      'struct',
      'input output',
      'compilation',
      'source code',
      'flowchart',
      'pseudocode'
    ],
    'Object Oriented Programming': [
      'class',
      'object',
      'inheritance',
      'polymorphism',
      'encapsulation',
      'abstraction',
      'constructor',
      'destructor',
      'interface',
      'overloading',
      'overriding'
    ],
    'Data Structures & Algorithms': [
      'linked list',
      'stack',
      'queue',
      'tree',
      'binary tree',
      'heap',
      'graph',
      'hash',
      'sorting',
      'searching',
      'complexity',
      'big o',
      'recursion',
      'dynamic programming',
      'greedy',
      'breadth first',
      'depth first',
      'bfs',
      'dfs'
    ],
    'Operating Systems': [
      'process',
      'thread',
      'scheduling',
      'deadlock',
      'semaphore',
      'mutex',
      'memory management',
      'paging',
      'segmentation',
      'virtual memory',
      'file system',
      'kernel',
      'interrupt'
    ],
    'Database Systems': [
      'sql',
      'query',
      'table',
      'normalization',
      'join',
      'foreign key',
      'primary key',
      'transaction',
      'acid',
      'indexing',
      'trigger',
      'stored procedure',
      'nosql',
      'mongodb',
      'relational'
    ],
    'Computer Networks': [
      'tcp',
      'udp',
      'ip address',
      'subnet',
      'router',
      'switch',
      'dns',
      'http',
      'https',
      'osi model',
      'mac address',
      'firewall',
      'vpn',
      'bandwidth',
      'latency',
      'packet'
    ],
    'Calculus': [
      'derivative',
      'integral',
      'limit',
      'differential',
      'series',
      'continuity',
      'gradient',
      'optimization',
      'chain rule',
      'partial'
    ],
    'Linear Algebra': [
      'matrix',
      'vector',
      'eigenvalue',
      'eigenvector',
      'determinant',
      'transpose',
      'rank',
      'linear transformation',
      'svd'
    ],
    'Discrete Mathematics': [
      'set theory',
      'logic',
      'proof',
      'relation',
      'function math',
      'graph theory',
      'combinatorics',
      'permutation',
      'combination',
      'number theory',
      'modular'
    ],
    'Probability & Statistics': [
      'probability',
      'distribution',
      'mean',
      'variance',
      'standard deviation',
      'hypothesis',
      'regression',
      'bayes',
      'random variable',
      'confidence interval'
    ],
    'Python': [
      'python',
      'pip',
      'django',
      'flask',
      'pandas',
      'numpy',
      'list comprehension',
      'lambda python',
      'decorator python'
    ],
    'Java': [
      'java',
      'jvm',
      'spring',
      'maven',
      'gradle',
      'jar',
      'servlet',
      'annotation',
      'generics java',
      'stream api'
    ],
    'C++': [
      'c++',
      'cpp',
      'stl',
      'template',
      'smart pointer',
      'raii',
      'move semantics',
      'namespace',
      'header file'
    ],
    'Machine Learning': [
      'neural network',
      'training',
      'model',
      'feature',
      'classification',
      'regression ml',
      'overfitting',
      'gradient descent',
      'loss function',
      'backpropagation',
      'dataset',
      'epoch'
    ],
    'Information Security': [
      'encryption',
      'decryption',
      'hash function',
      'digital signature',
      'certificate',
      'firewall security',
      'attack',
      'vulnerability',
      'rsa',
      'aes',
      'public key',
      'private key'
    ],
    'Digital Logic Design': [
      'logic gate',
      'boolean',
      'flip flop',
      'mux',
      'decoder',
      'adder',
      'fsm',
      'state machine',
      'karnaugh'
    ],
    'Physics': [
      'force',
      'acceleration',
      'velocity',
      'momentum',
      'energy',
      'thermodynamics',
      'wave',
      'optics',
      'electromagnetism',
      'quantum',
      'relativity',
      'newton'
    ],
    'Theory of Automata': [
      'dfa',
      'nfa',
      'regular expression automata',
      'context free grammar',
      'pushdown automata',
      'turing machine',
      'decidability',
      'chomsky'
    ],
    'Compiler Construction': [
      'lexer',
      'parser',
      'token',
      'grammar compiler',
      'abstract syntax tree',
      'ast',
      'semantic analysis',
      'code generation',
      'symbol table',
      'intermediate representation'
    ],
    'Artificial Intelligence': [
      'search algorithm',
      'heuristic',
      'a star',
      'knowledge base',
      'inference',
      'minimax',
      'game tree',
      'csp',
      'planning ai',
      'agent'
    ],
    'Dart & Flutter': [
      'flutter',
      'dart',
      'widget',
      'stateful',
      'stateless',
      'riverpod',
      'provider',
      'navigator',
      'scaffold',
      'pubspec'
    ],
  };

  // ── Off-topic subject names (not in the academic catalogue) ──────────────
  static const Set<String> _offTopicSubjects = {
    'english',
    'history',
    'geography',
    'biology',
    'chemistry',
    'economics',
    'psychology',
    'law',
    'cooking',
    'sports',
  };

  /// Returns a relevance score [0.0 – 1.0] of [message] for [subjectKey].
  static double _score(String message, String subjectKey) {
    final keywords = _keywords[subjectKey];
    if (keywords == null || keywords.isEmpty) return 0;
    final lower = message.toLowerCase();
    var hits = 0;
    for (final kw in keywords) {
      if (lower.contains(kw)) hits++;
    }
    return hits / keywords.length;
  }

  /// Main guard entry-point.
  ///
  /// Returns a [_GuardResult] describing whether the message is safe to send,
  /// and if not, which subject it seems to be about instead.
  static _GuardResult evaluate(String message, String selectedSubject) {
    if (message.trim().isEmpty) return const _GuardResult.allowed();

    final msgLower = message.toLowerCase();

    // ── 1. Hard-block: explicit off-topic subject mentions ─────────────────
    // Check if the message explicitly names a subject that is entirely outside
    // the academic catalogue (e.g. "English literature", "football match").
    for (final offTopic in _offTopicSubjects) {
      final score = _score(message, offTopic);
      if (score > 0.04) {
        // At least 2 keyword hits → flag
        return _GuardResult.blocked(
          detectedSubject: _prettyName(offTopic),
          reason: _OffTopicReason.offCatalogue,
        );
      }
    }

    // ── 2. Cross-subject check: does message match a *different* catalogue
    //       subject significantly more than the selected one? ──────────────
    final selectedScore = _score(message, selectedSubject);

    // Also compute a fuzzy match — the message might mention the selected
    // subject by name directly
    final subjectNameMentioned =
        msgLower.contains(selectedSubject.toLowerCase()) ||
            _subjectAliases(selectedSubject)
                .any((alias) => msgLower.contains(alias));

    // Build scores for every catalogue subject except the selected one
    final otherScores = <String, double>{};
    for (final key in _keywords.keys) {
      if (_offTopicSubjects.contains(key)) continue; // already handled above
      if (key == selectedSubject) continue;
      final s = _score(message, key);
      if (s > 0) otherScores[key] = s;
    }

    if (otherScores.isEmpty) return const _GuardResult.allowed();

    final bestOtherEntry =
        otherScores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final bestOtherScore = bestOtherEntry.value;
    final bestOtherSubject = bestOtherEntry.key;

    // Conditions to fire a warning:
    // • Best other subject scores at least 0.06 (≥3 keyword hits for a 50-kw set)
    // • It scores meaningfully more than the selected subject
    // • The selected subject name is not explicitly mentioned in the message
    final shouldWarn = bestOtherScore > 0.05 &&
        bestOtherScore > selectedScore * 1.8 &&
        !subjectNameMentioned;

    if (shouldWarn) {
      return _GuardResult.blocked(
        detectedSubject: bestOtherSubject,
        reason: _OffTopicReason.wrongCatalogueSubject,
      );
    }

    return const _GuardResult.allowed();
  }

  static String _prettyName(String key) {
    const pretty = {
      'english': 'English / Literature',
      'history': 'History',
      'geography': 'Geography',
      'biology': 'Biology',
      'chemistry': 'Chemistry',
      'economics': 'Economics',
      'psychology': 'Psychology',
      'law': 'Law',
      'cooking': 'Cooking / Food',
      'sports': 'Sports',
    };
    return pretty[key] ?? key;
  }

  /// Common shorthand aliases for catalogue subjects.
  static List<String> _subjectAliases(String subject) {
    const aliases = <String, List<String>>{
      'Data Structures & Algorithms': ['dsa', 'data structure'],
      'Object Oriented Programming': ['oop'],
      'Operating Systems': ['os'],
      'Database Systems': ['dbms', 'database'],
      'Computer Networks': ['cn', 'networking'],
      'Probability & Statistics': ['stats', 'statistics'],
      'Linear Algebra': ['linalg'],
      'Discrete Mathematics': ['dm', 'discrete math'],
      'Machine Learning': ['ml'],
      'Information Security': ['infosec', 'cyber security'],
      'Artificial Intelligence': ['ai'],
      'Theory of Automata': ['toa', 'automata'],
      'Compiler Construction': ['cc'],
      'Digital Logic Design': ['dld'],
      'Design & Analysis of Algorithms': ['daa'],
      'Dart & Flutter': ['dart', 'flutter'],
      'Programming Fundamentals': ['pf'],
    };
    return aliases[subject] ?? [];
  }
}

enum _OffTopicReason { offCatalogue, wrongCatalogueSubject }

class _GuardResult {
  final bool allowed;
  final String? detectedSubject;
  final _OffTopicReason? reason;

  const _GuardResult.allowed()
      : allowed = true,
        detectedSubject = null,
        reason = null;

  const _GuardResult.blocked({
    required this.detectedSubject,
    required this.reason,
  }) : allowed = false;
}

// ── Chat Page ─────────────────────────────────────────────────────────────────

class ChatPage extends ConsumerStatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final String _resolvedChatId;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  String _selectedSubject = 'Programming Fundamentals';
  bool _hasText = false;

  // Guard state
  _GuardResult _guardResult = const _GuardResult.allowed();
  bool _userOverrodeGuard = false; // user explicitly dismissed the warning

  @override
  void initState() {
    super.initState();
    _resolvedChatId =
        widget.chatId == 'new' ? const Uuid().v4() : widget.chatId;

    _textController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).loadMessages(_resolvedChatId);
    });
  }

  void _onTextChanged() {
    final text = _textController.text;
    final hasText = text.trim().isNotEmpty;
    final guard = hasText && !_userOverrodeGuard
        ? _SubjectGuard.evaluate(text, _selectedSubject)
        : const _GuardResult.allowed();

    if (hasText != _hasText || guard.allowed != _guardResult.allowed) {
      setState(() {
        _hasText = hasText;
        _guardResult = guard;
      });
    }
  }

  void _onSubjectChanged(String subject) {
    setState(() {
      _selectedSubject = subject;
      _userOverrodeGuard = false;
      // Re-evaluate guard with new subject
      _guardResult = _textController.text.trim().isNotEmpty
          ? _SubjectGuard.evaluate(_textController.text, subject)
          : const _GuardResult.allowed();
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Final guard check before sending
    final guard = _SubjectGuard.evaluate(text, _selectedSubject);
    if (!guard.allowed && !_userOverrodeGuard) {
      // Shake the warning banner instead of sending
      setState(() => _guardResult = guard);
      return;
    }

    _textController.clear();
    setState(() {
      _hasText = false;
      _guardResult = const _GuardResult.allowed();
      _userOverrodeGuard = false;
    });

    await ref
        .read(chatNotifierProvider.notifier)
        .sendMessage(text, _resolvedChatId, _selectedSubject);
    _scrollToBottom();
  }

  Future<void> _handleImagePick() async {
    final text = _textController.text.trim();
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      _textController.clear();
      setState(() {
        _hasText = false;
        _guardResult = const _GuardResult.allowed();
        _userOverrodeGuard = false;
      });
      await ref.read(chatNotifierProvider.notifier).sendImageMessage(
          text.isEmpty ? 'Explain this image.' : text, bytes, _resolvedChatId);
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick image.')),
      );
    }
  }

  void _openSubjectPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubjectPickerSheet(
        selected: _selectedSubject,
        onSelected: (subject) {
          _onSubjectChanged(subject);
          Navigator.pop(context);
        },
      ),
    );
  }

  List<ChatMessage> _getMessages(ChatState state) {
    if (state is ChatLoaded) return state.messages;
    if (state is ChatSending) return state.messages;
    return [];
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChatState>(chatNotifierProvider, (prev, next) {
      final prevMsgs = _getMessages(prev ?? const ChatInitial());
      final nextMsgs = _getMessages(next);
      if (nextMsgs.length != prevMsgs.length) _scrollToBottom();
      if (next is ChatFailureState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: _kError, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(next.error,
                    style: const TextStyle(color: _kTextPrimary, fontSize: 13)),
              ),
            ]),
          ),
        );
      }
    });

    final chatState = ref.watch(chatNotifierProvider);
    final messages = _getMessages(chatState);
    final isSending = chatState is ChatSending;
    final isLoading = chatState is ChatLoading;
    final showGuardBanner = !_guardResult.allowed && _hasText;

    return Scaffold(
      backgroundColor: _kBackground,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(height: 1, color: _kDivider),

          // ── Message list ──────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _kAccent))
                : messages.isEmpty
                    ? _EmptyState(subject: _selectedSubject)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: messages.length + (isSending ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && isSending) {
                            return const _TypingIndicator();
                          }
                          return MessageBubble(message: messages[index]);
                        },
                      ),
          ),

          // ── Guard Banner (sits just above the input row) ──────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            child: showGuardBanner
                ? _SubjectGuardBanner(
                    result: _guardResult,
                    selectedSubject: _selectedSubject,
                    onDismiss: () => setState(() => _userOverrodeGuard = true),
                    onChangeSubject: _openSubjectPicker,
                  )
                : const SizedBox.shrink(),
          ),

          // ── Input row ─────────────────────────────────────────────────────
          _ChatInputRow(
            controller: _textController,
            subject: _selectedSubject,
            hasText: _hasText,
            isSending: isSending,
            isBlocked: showGuardBanner && !_userOverrodeGuard,
            onSend: _handleSend,
            onImagePick: _handleImagePick,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _kBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: _kTextSecondary),
        onPressed: () {
          ref.read(chatNotifierProvider.notifier).clearChat();
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0x1FF4C430),
              borderRadius: BorderRadius.circular(6),
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 8),
          const Text('AI Tutor',
              style: TextStyle(
                color: _kAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              )),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: _openSubjectPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kDivider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book_rounded,
                      size: 13, color: _kAccent),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      _selectedSubject,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontSize: 12,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: _kAccent),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Subject Guard Banner ──────────────────────────────────────────────────────

class _SubjectGuardBanner extends StatefulWidget {
  const _SubjectGuardBanner({
    required this.result,
    required this.selectedSubject,
    required this.onDismiss,
    required this.onChangeSubject,
  });

  final _GuardResult result;
  final String selectedSubject;
  final VoidCallback onDismiss;
  final VoidCallback onChangeSubject;

  @override
  State<_SubjectGuardBanner> createState() => _SubjectGuardBannerState();
}

class _SubjectGuardBannerState extends State<_SubjectGuardBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    // Auto-shake on first appearance
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _shakeCtrl.forward(from: 0));
  }

  @override
  void didUpdateWidget(_SubjectGuardBanner old) {
    super.didUpdateWidget(old);
    // Reshake when the guard fires again (user retried without overriding)
    if (old.result.detectedSubject != widget.result.detectedSubject) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  String get _headline {
    return widget.result.reason == _OffTopicReason.offCatalogue
        ? 'Topic not in your study scope'
        : 'Looks like a different subject';
  }

  String get _body {
    final detected = widget.result.detectedSubject ?? 'another subject';
    final selected = widget.selectedSubject;
    if (widget.result.reason == _OffTopicReason.offCatalogue) {
      return 'Your message appears to be about $detected, which is outside '
          'your current subject ($selected). The AI Tutor is focused on '
          '$selected only.';
    }
    return 'Your message seems to be about $detected, but your current '
        'subject is set to $selected. Switch subject or send anyway if '
        'the topic overlaps.';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2E1E), // very dark green-navy
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E5C34), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E5C34),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🚫', style: TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _headline,
                        style: const TextStyle(
                          color: Color(0xFF7EE894),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _body,
                        style: const TextStyle(
                          color: Color(0xFF8FAF92),
                          fontSize: 12,
                          fontFamily: 'Georgia',
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Action buttons ────────────────────────────────────────────
            Row(
              children: [
                // Change subject
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onChangeSubject,
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E5C34),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz_rounded,
                              size: 14, color: Color(0xFF7EE894)),
                          SizedBox(width: 5),
                          Text(
                            'Change Subject',
                            style: TextStyle(
                              color: Color(0xFF7EE894),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send anyway
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onDismiss,
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2F45),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF2E5C34), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded,
                              size: 13, color: Color(0xFF8FAF92)),
                          SizedBox(width: 5),
                          Text(
                            'Send Anyway',
                            style: TextStyle(
                              color: Color(0xFF8FAF92),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subject Picker Sheet ──────────────────────────────────────────────────────

class _SubjectPickerSheet extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _SubjectPickerSheet({required this.selected, required this.onSelected});

  @override
  State<_SubjectPickerSheet> createState() => _SubjectPickerSheetState();
}

class _SubjectPickerSheetState extends State<_SubjectPickerSheet> {
  final _searchController = TextEditingController();
  final _customController = TextEditingController();
  String _query = '';
  bool _showCustomInput = false;

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }

  List<String> get _filteredSubjects {
    if (_query.isEmpty) return [];
    return kAllSubjects
        .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppColors.divider),
          left: BorderSide(color: AppColors.divider),
          right: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _kTextHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Select Subject',
                    style: TextStyle(
                      color: _kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      setState(() => _showCustomInput = !_showCustomInput),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x1FF4C430),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x33F4C430)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showCustomInput ? Icons.close : Icons.add,
                          size: 12,
                          color: _kAccent,
                        ),
                        const SizedBox(width: 4),
                        const Text('Custom',
                            style: TextStyle(
                              color: _kAccent,
                              fontSize: 11,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_showCustomInput) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customController,
                      autofocus: true,
                      style: const TextStyle(
                        color: _kTextPrimary,
                        fontFamily: 'Georgia',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter any subject...',
                        hintStyle: const TextStyle(
                            color: _kTextHint, fontFamily: 'Georgia'),
                        filled: true,
                        fillColor: _kSurfaceAlt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _kDivider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _kDivider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _kAccent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      final custom = _customController.text.trim();
                      if (custom.isNotEmpty) widget.onSelected(custom);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: _kBackground, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(
                color: _kTextPrimary,
                fontFamily: 'Georgia',
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search subjects...',
                hintStyle:
                    const TextStyle(color: _kTextHint, fontFamily: 'Georgia'),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: _kTextSecondary, size: 18),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: _kTextSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: _kSurfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kDivider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kDivider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kAccent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _kDivider),
          Expanded(
            child: _query.isNotEmpty
                ? _SearchResults(
                    results: _filteredSubjects,
                    selected: widget.selected,
                    onSelected: widget.onSelected,
                    query: _query,
                  )
                : _CategoryList(
                    selected: widget.selected,
                    onSelected: widget.onSelected,
                  ),
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}

// ── Search Results ────────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.results,
    required this.selected,
    required this.onSelected,
    required this.query,
  });
  final List<String> results;
  final String selected;
  final ValueChanged<String> onSelected;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text('No subjects found for "$query"',
                style: const TextStyle(
                    color: _kTextSecondary,
                    fontFamily: 'Georgia',
                    fontSize: 14)),
            const SizedBox(height: 6),
            const Text('Use "Custom" to add your own subject',
                style: TextStyle(
                    color: _kTextHint, fontFamily: 'Georgia', fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final subject = results[index];
        return _SubjectTile(
          subject: subject,
          isSelected: subject == selected,
          onTap: () => onSelected(subject),
        );
      },
    );
  }
}

// ── Category List ─────────────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: kSubjectCategories.length,
      itemBuilder: (context, catIndex) {
        final category = kSubjectCategories[catIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    category.name.toUpperCase(),
                    style: const TextStyle(
                      color: _kTextSecondary,
                      fontSize: 10,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            ...category.subjects.map((subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _SubjectTile(
                    subject: subject,
                    isSelected: subject == selected,
                    onTap: () => onSelected(subject),
                  ),
                )),
          ],
        );
      },
    );
  }
}

// ── Subject Tile ──────────────────────────────────────────────────────────────

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });
  final String subject;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0x1FF4C430) : const Color(0xFF1E2F45),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0x33F4C430) : _kDivider,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(subject,
                    style: TextStyle(
                      color: isSelected ? _kAccent : _kTextPrimary,
                      fontSize: 14,
                      fontFamily: 'Georgia',
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    )),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: _kAccent, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.subject});
  final String subject;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kSurface,
                shape: BoxShape.circle,
                border: Border.all(color: _kDivider),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 34))),
            ),
            const SizedBox(height: 20),
            Text(
              'Ask me anything about\n$subject!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kTextPrimary,
                fontSize: 16,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type your question below or send\nan image to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _kTextSecondary,
                fontSize: 13,
                fontFamily: 'Georgia',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: const BoxDecoration(
              color: Color(0x1FF4C430),
              shape: BoxShape.circle,
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B3C),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: _kDivider),
            ),
            child: FadeTransition(
              opacity: _animation,
              child: const Text('● ● ●',
                  style: TextStyle(
                    color: _kTextSecondary,
                    fontSize: 12,
                    letterSpacing: 3,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input Row ─────────────────────────────────────────────────────────────────

class _ChatInputRow extends StatelessWidget {
  const _ChatInputRow({
    required this.controller,
    required this.subject,
    required this.hasText,
    required this.isSending,
    required this.isBlocked,
    required this.onSend,
    required this.onImagePick,
  });

  final TextEditingController controller;
  final String subject;
  final bool hasText;
  final bool isSending;
  final bool isBlocked; // guard is active and not yet overridden
  final VoidCallback onSend;
  final VoidCallback onImagePick;

  @override
  Widget build(BuildContext context) {
    // When blocked: send icon turns into a warning icon, button dims to amber
    final sendColor = isBlocked
        ? const Color(0xFFFF9800)
        : (isSending || !hasText)
            ? const Color(0x66F4C430)
            : _kAccent;

    return Container(
      color: _kBackground,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Image picker
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: IconButton(
              icon: const Icon(Icons.image_outlined),
              color: _kTextSecondary,
              iconSize: 22,
              onPressed: isSending ? null : onImagePick,
              style: IconButton.styleFrom(
                backgroundColor: _kSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: _kDivider),
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text field — border turns amber when blocked
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isBlocked ? const Color(0x66FF9800) : _kDivider,
                  width: isBlocked ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: controller,
                enabled: !isSending,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: _kTextPrimary,
                  fontFamily: 'Georgia',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about $subject...',
                  hintStyle: const TextStyle(
                    color: _kTextSecondary,
                    fontFamily: 'Georgia',
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send / blocked button
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: IconButton(
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kBackground))
                  : Icon(
                      isBlocked
                          ? Icons.warning_amber_rounded
                          : Icons.send_rounded,
                      size: 20,
                    ),
              color: _kBackground,
              iconSize: 20,
              // Blocked: still tappable — pressing it triggers _handleSend
              // which will reshake the banner (not override it).
              onPressed:
                  (isSending || (!hasText && !isBlocked)) ? null : onSend,
              style: IconButton.styleFrom(
                backgroundColor: sendColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
