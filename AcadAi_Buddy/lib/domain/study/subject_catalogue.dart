// lib/domain/study/subject_catalogue.dart

/// The single source of truth for subjects, categories and topics.
///
/// Pure Dart — the presentation layer maps [Subject.iconKey] to an icon.
library;

class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.category,
    required this.iconKey,
    required this.topics,
  });

  /// Stable, URL-safe identifier.
  final String id;

  /// Display name; also what is stored on chats and quiz results.
  final String name;

  /// One of [kSubjectCategories].
  final String category;

  /// Presentation maps this to an icon (see `subject_icons.dart`).
  final String iconKey;

  /// Suggested topics, used by the quiz setup and chat suggestions.
  final List<String> topics;
}

/// Category display order.
const List<String> kSubjectCategories = [
  'FAST Core',
  'Mathematics',
  'Programming',
  'CS Theory',
  'Engineering',
  'Soft Skills',
];

/// Name used when the user studies something outside the catalogue.
const String kGeneralSubject = 'General';

const List<Subject> kSubjects = [
  // ── FAST Core ──────────────────────────────────────────────────────────────
  Subject(
    id: 'programming-fundamentals',
    name: 'Programming Fundamentals',
    category: 'FAST Core',
    iconKey: 'code',
    topics: [
      'Variables & Data Types',
      'Control Flow',
      'Functions & Recursion',
      'Arrays & Pointers',
      'File I/O',
      'Structs & Enums',
    ],
  ),
  Subject(
    id: 'oop',
    name: 'Object Oriented Programming',
    category: 'FAST Core',
    iconKey: 'class',
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
  Subject(
    id: 'dsa',
    name: 'Data Structures & Algorithms',
    category: 'FAST Core',
    iconKey: 'tree',
    topics: [
      'Arrays & Linked Lists',
      'Stacks & Queues',
      'Recursion',
      'Trees & BST',
      'Heaps & Priority Queues',
      'Graphs & BFS/DFS',
      'Sorting Algorithms',
      'Hashing',
    ],
  ),
  Subject(
    id: 'software-engineering',
    name: 'Software Engineering',
    category: 'FAST Core',
    iconKey: 'architecture',
    topics: [
      'SDLC Models',
      'Requirements Engineering',
      'UML Diagrams',
      'Design Patterns',
      'Testing Strategies',
      'Agile & Scrum',
    ],
  ),
  Subject(
    id: 'software-design-architecture',
    name: 'Software Design & Architecture',
    category: 'FAST Core',
    iconKey: 'architecture',
    topics: [
      'SOLID Principles',
      'Design Patterns',
      'Architectural Styles',
      'Layered & Clean Architecture',
      'Microservices',
      'UML Class & Sequence Diagrams',
    ],
  ),
  Subject(
    id: 'software-requirements-engineering',
    name: 'Software Requirements Engineering',
    category: 'FAST Core',
    iconKey: 'checklist',
    topics: [
      'Elicitation Techniques',
      'Functional vs Non-functional',
      'Use Cases & User Stories',
      'SRS Documents',
      'Requirements Validation',
      'Traceability',
    ],
  ),
  Subject(
    id: 'operating-systems',
    name: 'Operating Systems',
    category: 'FAST Core',
    iconKey: 'memory',
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
  Subject(
    id: 'database-systems',
    name: 'Database Systems',
    category: 'FAST Core',
    iconKey: 'storage',
    topics: [
      'ER Modelling',
      'SQL Queries',
      'Normalization',
      'Transactions & ACID',
      'Indexing & B-Trees',
      'NoSQL Basics',
    ],
  ),
  Subject(
    id: 'computer-networks',
    name: 'Computer Networks',
    category: 'FAST Core',
    iconKey: 'network',
    topics: [
      'OSI & TCP/IP Model',
      'HTTP & DNS',
      'IP Addressing & Subnetting',
      'TCP vs UDP',
      'Routing Algorithms',
      'Network Security',
    ],
  ),
  Subject(
    id: 'compiler-construction',
    name: 'Compiler Construction',
    category: 'FAST Core',
    iconKey: 'build',
    topics: [
      'Lexical Analysis',
      'Parsing & CFG',
      'Syntax-Directed Translation',
      'Semantic Analysis',
      'Intermediate Code',
      'Code Generation',
    ],
  ),
  Subject(
    id: 'artificial-intelligence',
    name: 'Artificial Intelligence',
    category: 'FAST Core',
    iconKey: 'ai',
    topics: [
      'Search Algorithms',
      'Heuristics & A*',
      'Knowledge Representation',
      'Bayesian Networks',
      'Machine Learning Basics',
      'Neural Networks',
    ],
  ),

  // ── Mathematics ────────────────────────────────────────────────────────────
  Subject(
    id: 'calculus',
    name: 'Calculus',
    category: 'Mathematics',
    iconKey: 'functions',
    topics: [
      'Limits & Continuity',
      'Differentiation',
      'Integration',
      'Series & Sequences',
      'Multivariable Calculus',
      'Differential Equations',
    ],
  ),
  Subject(
    id: 'linear-algebra',
    name: 'Linear Algebra',
    category: 'Mathematics',
    iconKey: 'grid',
    topics: [
      'Vectors & Matrices',
      'Matrix Operations',
      'Determinants',
      'Eigenvalues & Eigenvectors',
      'Linear Transformations',
      'SVD',
    ],
  ),
  Subject(
    id: 'discrete-mathematics',
    name: 'Discrete Mathematics',
    category: 'Mathematics',
    iconKey: 'numbers',
    topics: [
      'Set Theory',
      'Logic & Proofs',
      'Relations & Functions',
      'Graph Theory',
      'Combinatorics',
      'Number Theory',
    ],
  ),
  Subject(
    id: 'probability-statistics',
    name: 'Probability & Statistics',
    category: 'Mathematics',
    iconKey: 'chart',
    topics: [
      'Probability Basics',
      'Distributions',
      'Expected Value',
      'Hypothesis Testing',
      'Regression',
      'Bayes Theorem',
    ],
  ),
  Subject(
    id: 'numerical-methods',
    name: 'Numerical Methods',
    category: 'Mathematics',
    iconKey: 'calculate',
    topics: [
      'Root Finding',
      'Interpolation',
      'Numerical Differentiation',
      'Numerical Integration',
      'Linear Systems',
      'Error Analysis',
    ],
  ),
  Subject(
    id: 'differential-equations',
    name: 'Differential Equations',
    category: 'Mathematics',
    iconKey: 'functions',
    topics: [
      'First-Order ODEs',
      'Second-Order Linear ODEs',
      'Laplace Transforms',
      'Systems of ODEs',
      'Series Solutions',
      'Applications & Modelling',
    ],
  ),

  // ── Programming ────────────────────────────────────────────────────────────
  Subject(
    id: 'python',
    name: 'Python',
    category: 'Programming',
    iconKey: 'terminal',
    topics: [
      'Syntax & Data Types',
      'Functions & Lambdas',
      'OOP in Python',
      'File Handling',
      'Comprehensions',
      'Decorators & Generators',
    ],
  ),
  Subject(
    id: 'java',
    name: 'Java',
    category: 'Programming',
    iconKey: 'coffee',
    topics: [
      'OOP Concepts',
      'Collections Framework',
      'Exception Handling',
      'Multithreading',
      'Generics',
      'Java 8+ Features',
    ],
  ),
  Subject(
    id: 'cpp',
    name: 'C++',
    category: 'Programming',
    iconKey: 'code',
    topics: [
      'Pointers & References',
      'STL',
      'Templates',
      'Smart Pointers',
      'Move Semantics',
      'Concurrency',
    ],
  ),
  Subject(
    id: 'c',
    name: 'C',
    category: 'Programming',
    iconKey: 'code',
    topics: [
      'Pointers & Memory',
      'Arrays & Strings',
      'Structs & Unions',
      'Dynamic Allocation',
      'File I/O',
      'Preprocessor & Macros',
    ],
  ),
  Subject(
    id: 'dart-flutter',
    name: 'Dart & Flutter',
    category: 'Programming',
    iconKey: 'mobile',
    topics: [
      'Dart Basics',
      'Async & Futures',
      'Widgets & State',
      'Navigation',
      'Riverpod',
      'Firebase Integration',
    ],
  ),
  Subject(
    id: 'javascript',
    name: 'JavaScript',
    category: 'Programming',
    iconKey: 'web',
    topics: [
      'Types & Coercion',
      'Closures & Scope',
      'Promises & Async/Await',
      'DOM Manipulation',
      'ES6+ Features',
      'Event Loop',
    ],
  ),
  Subject(
    id: 'assembly-language',
    name: 'Assembly Language',
    category: 'Programming',
    iconKey: 'chip',
    topics: [
      'Registers & Flags',
      'Addressing Modes',
      'Instructions & Arithmetic',
      'Stack & Procedures',
      'Interrupts',
      'Loops & Branching',
    ],
  ),
  Subject(
    id: 'data-science-python',
    name: 'Data Science with Python',
    category: 'Programming',
    iconKey: 'chart',
    topics: [
      'NumPy',
      'Pandas DataFrames',
      'Data Cleaning',
      'Visualization',
      'Exploratory Data Analysis',
      'scikit-learn Basics',
    ],
  ),

  // ── CS Theory ──────────────────────────────────────────────────────────────
  Subject(
    id: 'theory-of-automata',
    name: 'Theory of Automata',
    category: 'CS Theory',
    iconKey: 'automata',
    topics: [
      'DFA & NFA',
      'Regular Expressions',
      'Context-Free Grammars',
      'Pushdown Automata',
      'Turing Machines',
      'Decidability',
    ],
  ),
  Subject(
    id: 'algorithms',
    name: 'Design & Analysis of Algorithms',
    category: 'CS Theory',
    iconKey: 'timeline',
    topics: [
      'Asymptotic Notation',
      'Divide & Conquer',
      'Dynamic Programming',
      'Greedy Algorithms',
      'NP-Completeness',
      'Approximation Algorithms',
    ],
  ),
  Subject(
    id: 'computer-architecture',
    name: 'Computer Architecture',
    category: 'CS Theory',
    iconKey: 'chip',
    topics: [
      'Instruction Set Architecture',
      'Pipelining',
      'Cache Memory',
      'Memory Hierarchy',
      'Performance Metrics',
      'I/O Organization',
    ],
  ),
  Subject(
    id: 'parallel-computing',
    name: 'Parallel Computing',
    category: 'CS Theory',
    iconKey: 'parallel',
    topics: [
      'Parallel Architectures',
      'Threads & OpenMP',
      'MPI Basics',
      'Synchronization',
      'Speedup & Amdahl\'s Law',
      'GPU Computing',
    ],
  ),
  Subject(
    id: 'information-security',
    name: 'Information Security',
    category: 'CS Theory',
    iconKey: 'lock',
    topics: [
      'Cryptography Basics',
      'Symmetric & Asymmetric Encryption',
      'Hashing',
      'Authentication',
      'Network Attacks',
      'PKI',
    ],
  ),
  Subject(
    id: 'machine-learning',
    name: 'Machine Learning',
    category: 'CS Theory',
    iconKey: 'ai',
    topics: [
      'Supervised Learning',
      'Unsupervised Learning',
      'Decision Trees',
      'SVM',
      'Neural Networks',
      'Model Evaluation',
    ],
  ),
  Subject(
    id: 'deep-learning',
    name: 'Deep Learning',
    category: 'CS Theory',
    iconKey: 'ai',
    topics: [
      'Backpropagation',
      'CNNs',
      'RNNs & LSTMs',
      'Transformers',
      'Regularization',
      'Optimizers',
    ],
  ),

  // ── Engineering ────────────────────────────────────────────────────────────
  Subject(
    id: 'physics',
    name: 'Physics',
    category: 'Engineering',
    iconKey: 'science',
    topics: [
      'Mechanics',
      'Thermodynamics',
      'Waves & Optics',
      'Electromagnetism',
      'Modern Physics',
      'Quantum Basics',
    ],
  ),
  Subject(
    id: 'applied-physics',
    name: 'Applied Physics',
    category: 'Engineering',
    iconKey: 'science',
    topics: [
      'Electric Fields & Potential',
      'Capacitance & Dielectrics',
      'Current & Resistance',
      'Magnetic Fields',
      'Electromagnetic Induction',
      'Semiconductors',
    ],
  ),
  Subject(
    id: 'digital-logic-design',
    name: 'Digital Logic Design',
    category: 'Engineering',
    iconKey: 'circuit',
    topics: [
      'Boolean Algebra',
      'Logic Gates',
      'Combinational Circuits',
      'Sequential Circuits',
      'Flip-Flops',
      'FSMs',
    ],
  ),
  Subject(
    id: 'signals-systems',
    name: 'Signals & Systems',
    category: 'Engineering',
    iconKey: 'wave',
    topics: [
      'Signal Classification',
      'LTI Systems',
      'Convolution',
      'Fourier Series',
      'Fourier Transform',
      'Z-Transform',
    ],
  ),
  Subject(
    id: 'microprocessors',
    name: 'Microprocessors',
    category: 'Engineering',
    iconKey: 'chip',
    topics: [
      '8086 Architecture',
      'Instruction Set',
      'Memory Interfacing',
      'I/O Interfacing',
      'Interrupts',
      'Microcontrollers',
    ],
  ),
  Subject(
    id: 'electronics',
    name: 'Electronics',
    category: 'Engineering',
    iconKey: 'circuit',
    topics: [
      'Diodes',
      'BJTs',
      'MOSFETs',
      'Amplifiers',
      'Op-Amps',
      'Power Supplies',
    ],
  ),

  // ── Soft Skills ────────────────────────────────────────────────────────────
  Subject(
    id: 'technical-writing',
    name: 'Technical Writing',
    category: 'Soft Skills',
    iconKey: 'writing',
    topics: [
      'Report Structure',
      'Clarity & Conciseness',
      'Citations & Referencing',
      'Technical Proposals',
      'Documentation',
      'Editing & Proofreading',
    ],
  ),
  Subject(
    id: 'communication-skills',
    name: 'Communication Skills',
    category: 'Soft Skills',
    iconKey: 'forum',
    topics: [
      'Presentations',
      'Active Listening',
      'Professional Email',
      'Group Discussions',
      'Interviews',
      'Non-verbal Communication',
    ],
  ),
  Subject(
    id: 'professional-ethics',
    name: 'Professional Ethics',
    category: 'Soft Skills',
    iconKey: 'gavel',
    topics: [
      'Codes of Ethics',
      'Intellectual Property',
      'Privacy',
      'Computer Crime',
      'Ethical Dilemmas',
      'Social Impact of Computing',
    ],
  ),
  Subject(
    id: 'project-management',
    name: 'Project Management',
    category: 'Soft Skills',
    iconKey: 'checklist',
    topics: [
      'Project Lifecycle',
      'Scheduling & Gantt Charts',
      'Risk Management',
      'Cost Estimation',
      'Team Management',
      'Agile Project Management',
    ],
  ),
  Subject(
    id: 'entrepreneurship',
    name: 'Entrepreneurship',
    category: 'Soft Skills',
    iconKey: 'lightbulb',
    topics: [
      'Idea Validation',
      'Business Model Canvas',
      'Market Research',
      'Pitching',
      'Funding',
      'Lean Startup',
    ],
  ),
];

/// Finds a catalogue subject by its display name (case-insensitive).
Subject? subjectByName(String name) {
  final needle = name.trim().toLowerCase();
  for (final s in kSubjects) {
    if (s.name.toLowerCase() == needle) return s;
  }
  return null;
}

/// All subjects in [category], in catalogue order.
List<Subject> subjectsInCategory(String category) =>
    kSubjects.where((s) => s.category == category).toList();
