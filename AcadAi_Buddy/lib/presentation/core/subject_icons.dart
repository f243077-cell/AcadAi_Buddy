import 'package:flutter/material.dart';

import '../../domain/study/subject_catalogue.dart';

/// Maps catalogue icon keys to Material icons.
IconData iconForKey(String key) => switch (key) {
      'code' => Icons.code_rounded,
      'class' => Icons.category_rounded,
      'tree' => Icons.account_tree_rounded,
      'architecture' => Icons.architecture_rounded,
      'checklist' => Icons.checklist_rounded,
      'memory' => Icons.memory_rounded,
      'storage' => Icons.storage_rounded,
      'network' => Icons.lan_rounded,
      'build' => Icons.build_rounded,
      'ai' => Icons.psychology_rounded,
      'functions' => Icons.functions_rounded,
      'grid' => Icons.grid_on_rounded,
      'numbers' => Icons.pin_rounded,
      'chart' => Icons.insights_rounded,
      'calculate' => Icons.calculate_rounded,
      'terminal' => Icons.terminal_rounded,
      'coffee' => Icons.coffee_rounded,
      'mobile' => Icons.phone_android_rounded,
      'web' => Icons.web_rounded,
      'chip' => Icons.developer_board_rounded,
      'automata' => Icons.hub_rounded,
      'timeline' => Icons.timeline_rounded,
      'parallel' => Icons.view_column_rounded,
      'lock' => Icons.lock_rounded,
      'science' => Icons.science_rounded,
      'circuit' => Icons.electrical_services_rounded,
      'wave' => Icons.graphic_eq_rounded,
      'writing' => Icons.edit_note_rounded,
      'forum' => Icons.forum_rounded,
      'gavel' => Icons.gavel_rounded,
      'lightbulb' => Icons.lightbulb_rounded,
      _ => Icons.menu_book_rounded,
    };

IconData iconForCategory(String category) => switch (category) {
      'FAST Core' => Icons.school_rounded,
      'Mathematics' => Icons.functions_rounded,
      'Programming' => Icons.code_rounded,
      'CS Theory' => Icons.psychology_rounded,
      'Engineering' => Icons.precision_manufacturing_rounded,
      'Soft Skills' => Icons.groups_rounded,
      _ => Icons.menu_book_rounded,
    };

/// Icon for a subject name; custom subjects get a generic book.
IconData iconForSubject(String name) {
  final s = subjectByName(name);
  return s == null ? Icons.menu_book_rounded : iconForKey(s.iconKey);
}
