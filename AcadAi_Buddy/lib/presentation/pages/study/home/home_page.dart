// lib/presentation/pages/study/home/home_page.dart

// ignore_for_file: unused_element

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/auth/auth_notifier.dart';
import '../../../../application/auth/auth_state.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A1628);
const _bgCard = Color(0xFF0F1F35);
const _bgCard2 = Color(0xFF132236);
const _surface = Color(0xFF1A2B3C);
const _divider = Color(0xFF1E2F45);
const _accent = Color(0xFFF4C430);
const _accentSoft = Color(0xFFE8B84B);
const _white = Colors.white;

const _a04 = Color(0x0AF4C430);
const _a08 = Color(0x14F4C430);
const _a10 = Color(0x1AF4C430);
const _a12 = Color(0x1FF4C430);
const _a15 = Color(0x26F4C430);
const _a20 = Color(0x33F4C430);
const _a40 = Color(0x66F4C430);
const _a50 = Color(0x80F4C430);

const _w10 = Color(0x1AFFFFFF);
const _w20 = Color(0x33FFFFFF);
const _w35 = Color(0x59FFFFFF);
const _w50 = Color(0x80FFFFFF);
const _w60 = Color(0x99FFFFFF);
const _w75 = Color(0xBFFFFFFF);

// ── Feature data ──────────────────────────────────────────────────────────────
class _Feature {
  final String emoji;
  final String title;
  final String tag;
  final String description;
  final String route;
  final Color glow;
  const _Feature({
    required this.emoji,
    required this.title,
    required this.tag,
    required this.description,
    required this.route,
    required this.glow,
  });
}

const _features = [
  _Feature(
    emoji: '🤖',
    title: 'Chat with AI',
    tag: 'Tutor',
    description:
        'Ask questions, get explanations, and work through problems step-by-step with your personal AI tutor.',
    route: '/chat/new',
    glow: Color(0x2259A6FF),
  ),
  _Feature(
    emoji: '📝',
    title: 'Quiz Me',
    tag: 'Practice',
    description:
        'Generate MCQ quizzes on any subject, choose a topic, and get instant AI-graded feedback.',
    route: '/quiz',
    glow: Color(0x22F4C430),
  ),
  _Feature(
    emoji: '📄',
    title: 'Summarize Notes',
    tag: 'Quick Read',
    description:
        'Paste dense lecture notes and receive a clean, structured summary in seconds.',
    route: '/summarize',
    glow: Color(0x2234C98A),
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────────
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final displayName = user?.displayName ?? 'Scholar';

    return Scaffold(
      backgroundColor: _bg,
      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoBadge(),
            const SizedBox(width: 10),
            const Text(
              'AcadAI Buddy',
              style: TextStyle(
                color: _accent,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                fontSize: 19,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          _SignOutButton(
            onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(color: _divider),
          ),
        ),
      ),

      // ── Body ──────────────────────────────────────────────────────────────
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome hero
                  _WelcomeHero(displayName: displayName),
                  const SizedBox(height: 36),

                  // Section label
                  const _SectionLabel(label: 'STUDY TOOLS'),
                  const SizedBox(height: 16),

                  // Feature cards
                  ..._features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _FeatureCard(feature: f),
                      )),

                  const SizedBox(height: 36),

                  // Stats strip
                  _StatsStrip(),
                  const SizedBox(height: 36),

                  // Quote
                  _QuoteBlock(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logo Badge ────────────────────────────────────────────────────────────────
class _LogoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _a12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _a20),
      ),
      child: const Center(
        child: Text('🎓', style: TextStyle(fontSize: 15)),
      ),
    );
  }
}

// ── Sign Out Button ───────────────────────────────────────────────────────────
class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _divider),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, size: 13, color: _w50),
            SizedBox(width: 5),
            Text(
              'Sign Out',
              style: TextStyle(
                color: _w50,
                fontSize: 12,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: _w50,
            fontSize: 10,
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            letterSpacing: 2.4,
          ),
        ),
      ],
    );
  }
}

// ── Welcome Hero ──────────────────────────────────────────────────────────────
class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.displayName});
  final String displayName;

  @override
  Widget build(BuildContext context) {
    // Clamp name so it never overflows on small devices
    final shortName = displayName.length > 16
        ? '${displayName.substring(0, 14)}…'
        : displayName;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bgCard2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _a15),
        boxShadow: const [
          BoxShadow(
              color: Color(0x28000000), blurRadius: 24, offset: Offset(0, 8)),
          BoxShadow(color: _a08, blurRadius: 32, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative arc in the corner
            Positioned(
              right: -30,
              top: -30,
              child: _DecorativeArc(),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar row — uses Flexible to prevent overflow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _Avatar(),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $shortName! 👋',
                              style: const TextStyle(
                                color: _white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Georgia',
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'What would you like to study today?',
                              style: TextStyle(
                                color: _w50,
                                fontSize: 12,
                                fontFamily: 'Georgia',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(color: _divider),
                  ),
                  const SizedBox(height: 16),

                  // Stats chips — wrapped so they never overflow
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                          label: 'AI Tutor', icon: Icons.auto_awesome_rounded),
                      _StatChip(
                          label: 'Any Subjects', icon: Icons.menu_book_rounded),
                      _StatChip(
                          label: 'Instant Help', icon: Icons.bolt_rounded),
                      _StatChip(label: 'Quiz Gen', icon: Icons.quiz_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Decorative Arc ────────────────────────────────────────────────────────────
class _DecorativeArc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(120, 120),
      painter: _ArcPainter(),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x12F4C430)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width, 0), radius: 40.0 + i * 24),
        math.pi / 2,
        math.pi / 2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _a12,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _a20, width: 1.5),
        boxShadow: const [
          BoxShadow(color: _a15, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: const Center(
        child: Text('🎓', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _a08,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _a20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _accent, size: 11),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: _accent,
              fontSize: 11,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature Card ──────────────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push(feature.route),
        borderRadius: BorderRadius.circular(16),
        splashColor: _a08,
        highlightColor: _a04,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _divider),
            boxShadow: [
              BoxShadow(
                color: feature.glow,
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _a10,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _a20),
                ),
                child: Center(
                  child:
                      Text(feature.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),

              const SizedBox(width: 16),

              // Text — Expanded prevents horizontal overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + tag — Flexible prevents tag from being clipped
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            feature.title,
                            style: const TextStyle(
                              color: _white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Georgia',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TagBadge(label: feature.tag),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feature.description,
                      style: const TextStyle(
                        color: _w50,
                        fontSize: 12,
                        fontFamily: 'Georgia',
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.chevron_right_rounded, color: _w35, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tag Badge ─────────────────────────────────────────────────────────────────
class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _a15,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _a20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _accent,
          fontSize: 10,
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Stats Strip ───────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      // IntrinsicHeight + Row with dividers — avoids overflow by letting
      // each cell use Expanded and keeping text small.
      child: const IntrinsicHeight(
        child: Row(
          children: [
            _StripStat(value: 'Any', label: 'Subjects'),
            _VerticalDivider(),
            _StripStat(value: 'AI', label: 'Powered'),
            _VerticalDivider(),
            _StripStat(value: '∞', label: 'Questions'),
            _VerticalDivider(),
            _StripStat(value: '24/7', label: 'Available'),
          ],
        ),
      ),
    );
  }
}

class _StripStat extends StatelessWidget {
  const _StripStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _w35,
              fontSize: 10,
              fontFamily: 'Georgia',
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(color: _divider),
    );
  }
}

// ── Quote Block ───────────────────────────────────────────────────────────────
class _QuoteBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        // color and gradient cannot coexist — use gradient only,
        // starting from a near-opaque card tone on the left.
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF122035), Color(0xFF0F1F35)],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold left bar
          Container(
            width: 3,
            height: 54,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(color: _a40, blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Quote text — Expanded prevents horizontal overflow
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"The more that you read, the more things you will know."',
                  style: TextStyle(
                    color: _w60,
                    fontSize: 13,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '— Dr. Seuss',
                  style: TextStyle(
                    color: _accentSoft,
                    fontSize: 11,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
