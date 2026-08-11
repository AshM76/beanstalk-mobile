import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/cash_bubble.dart';
import '../../data/cash_tips.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kPrimary = Color(0xFF2E7D32);
const _kAccent  = Color(0xFFE8F5E9);

const _kDoneKey    = 'onboarding_complete';
const _kProfileKey = 'profile_display_name';
const _kRiskKey    = 'profile_investor_type';
const _kAgeKey     = 'profile_age_group';

// ── Public helpers ────────────────────────────────────────────────────────────

Future<bool> isOnboardingComplete() async {
  final p = await SharedPreferences.getInstance();
  return p.getBool(_kDoneKey) ?? false;
}

// ── Risk quiz data ────────────────────────────────────────────────────────────

class _Question {
  final String text;
  final List<String> options; // 3 options, scored 0/1/2 (cautious→bold)
  const _Question(this.text, this.options);
}

const _kQuestions = [
  _Question(
    'The market drops 20% suddenly. What do you do?',
    [
      'Sell everything — protect what I have',
      'Hold steady and wait it out',
      'Buy more — great discount!',
    ],
  ),
  _Question(
    'Which investing style sounds most like you?',
    [
      'Slow and steady — I prefer low risk',
      'Balanced — some risk is okay for better returns',
      'All-in — I want maximum growth potential',
    ],
  ),
  _Question(
    'How long could you leave money invested without needing it?',
    [
      'Less than 1 year',
      '1–5 years',
      'More than 5 years',
    ],
  ),
];

// 0–2 → Careful Planter, 3–4 → Balanced Builder, 5–6 → Bold Investor
String _scoreToProfile(int score) {
  if (score <= 2) return 'Careful Planter';
  if (score <= 4) return 'Balanced Builder';
  return 'Bold Investor';
}

const _kProfileDetails = {
  'Careful Planter': (
    emoji: '🌱',
    tagline: 'You value stability over speed.',
    description:
        'You prefer to protect your capital and grow steadily. Lower-risk '
        'investments like ETFs, bonds, and dividend stocks are a great fit for you.',
    color: Color(0xFF1565C0),
  ),
  'Balanced Builder': (
    emoji: '⚖️',
    tagline: 'You balance growth with caution.',
    description:
        'You\'re comfortable taking moderate risks for better long-term returns. '
        'A mix of growth stocks and stable assets suits you well.',
    color: Color(0xFF2E7D32),
  ),
  'Bold Investor': (
    emoji: '🚀',
    tagline: 'You chase high growth potential.',
    description:
        'You\'re willing to take on risk for the chance of big rewards. '
        'Growth stocks, emerging markets, and new sectors excite you.',
    color: Color(0xFF6A1B9A),
  ),
};

// ── Age groups ────────────────────────────────────────────────────────────────

const _kAgeGroups = [
  ('🎒', 'High School',         'Ages 13–18'),
  ('🎓', 'College',             'Ages 18–24'),
  ('💼', 'Young Professional',  'Ages 24–35'),
  ('🏡', 'Adult',               'Ages 35+'),
];

// ── Flow ──────────────────────────────────────────────────────────────────────

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageController = PageController();
  int _page = 0;

  // Collected data
  String _ageGroup = '';
  final _scores    = <int>[];   // one entry per quiz question answered
  String _profile  = '';
  final _nameCtrl  = TextEditingController();

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final displayName = _nameCtrl.text.trim().isEmpty ? 'Investor' : _nameCtrl.text.trim();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDoneKey, true);
    await p.setString(_kProfileKey, displayName);
    await p.setString(_kRiskKey, _profile);
    await p.setString(_kAgeKey, _ageGroup);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _WelcomePage(onNext: _next),
            _AgePickerPage(
              selected: _ageGroup,
              onSelect: (g) => setState(() => _ageGroup = g),
              onNext: _ageGroup.isNotEmpty ? _next : null,
            ),
            _QuizPage(
              scores: _scores,
              onDone: (scores) {
                setState(() {
                  _scores
                    ..clear()
                    ..addAll(scores);
                  _profile = _scoreToProfile(scores.fold(0, (a, b) => a + b));
                });
                _next();
              },
            ),
            _ResultPage(
              profile: _profile,
              onNext: _next,
            ),
            _NamePage(
              controller: _nameCtrl,
              onFinish: _finish,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _StepDots(current: _page, total: 5),
    );
  }
}

// ── Step dots ─────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            final active = i == current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width:  active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? _kPrimary : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Page 1 — Welcome ──────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Cash waving hello
          SvgPicture.asset(
            'assets/images/cash/cash_happy.svg',
            height: 120,
          ),
          const SizedBox(height: 16),
          const Text(
            'Beanstalk',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: _kPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Learn. Trade. Compete.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'The smartest way to learn investing — with virtual money, real market data, and friendly competition.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black45, height: 1.6),
          ),
          const SizedBox(height: 28),
          const CashBubble(
            message: CashTips.onboardingWelcome,
            mood: CashMood.happy,
          ),
          const Spacer(flex: 3),
          _PrimaryButton(label: "Let's Get Started", onTap: onNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Page 2 — Age picker ───────────────────────────────────────────────────────

class _AgePickerPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback? onNext;
  const _AgePickerPage(
      {required this.selected, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cash's bubble scrolls with the content; the Continue button below
          // stays pinned regardless of how tall the bubble grows.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text('Who are you?',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 6),
                  const Text('We\'ll personalise your experience.',
                      style: TextStyle(fontSize: 15, color: Colors.black45)),
                  const SizedBox(height: 32),
                  ...List.generate(_kAgeGroups.length, (i) {
                    final g       = _kAgeGroups[i];
                    final isSelected = selected == g.$2;
                    return GestureDetector(
                      onTap: () => onSelect(g.$2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color:       isSelected ? _kAccent : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                          border:      Border.all(
                            color: isSelected ? _kPrimary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(g.$1, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g.$2,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? _kPrimary : Colors.black87)),
                                Text(g.$3,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black45)),
                              ],
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: _kPrimary, size: 22),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (selected.isNotEmpty) ...[
                    CashBubble(
                      message: CashTips.ageGroupComments[selected] ??
                          "Great choice! Every investor starts somewhere. Let's find your style!",
                      mood: CashMood.happy,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _PrimaryButton(
            label: 'Continue',
            onTap: onNext,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Page 3 — Risk quiz ────────────────────────────────────────────────────────

class _QuizPage extends StatefulWidget {
  final List<int> scores;
  final ValueChanged<List<int>> onDone;
  const _QuizPage({required this.scores, required this.onDone});

  @override
  State<_QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<_QuizPage> {
  int _q        = 0;
  int? _picked;
  final _answers = <int>[];

  void _select(int idx) => setState(() => _picked = idx);

  void _advance() {
    if (_picked == null) return;
    _answers.add(_picked!);
    if (_q < _kQuestions.length - 1) {
      setState(() { _q++; _picked = null; });
    } else {
      widget.onDone(List.from(_answers));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _kQuestions[_q];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              Text(
                'Question ${_q + 1} of ${_kQuestions.length}',
                style: const TextStyle(
                    fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              // Mini progress bar
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_q + 1) / _kQuestions.length,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            q.text,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
          ),
          const SizedBox(height: 28),
          ...List.generate(q.options.length, (i) {
            final sel = _picked == i;
            return GestureDetector(
              onTap: () => _select(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color:        sel ? _kAccent : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(
                    color: sel ? _kPrimary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.options[i],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                          color: sel ? _kPrimary : Colors.black87,
                        ),
                      ),
                    ),
                    if (sel)
                      const Icon(Icons.check_circle_rounded,
                          color: _kPrimary, size: 20),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          if (_picked != null) ...[
            CashBubble(
              message: CashTips.quizChoiceComments[_q][_picked!],
              mood: CashMood.encouraging,
            ),
            const SizedBox(height: 8),
          ],
          _PrimaryButton(
            label: _q < _kQuestions.length - 1 ? 'Next Question' : 'See My Profile',
            onTap: _picked != null ? _advance : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Page 4 — Result ───────────────────────────────────────────────────────────

class _ResultPage extends StatelessWidget {
  final String profile;
  final VoidCallback onNext;
  const _ResultPage({required this.profile, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final details = _kProfileDetails[profile] ??
        _kProfileDetails['Balanced Builder']!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: details.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: details.color, width: 3),
            ),
            child: Center(
              child: Text(details.emoji,
                  style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re a',
            style: TextStyle(
                fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            profile,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: details.color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            details.tagline,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            details.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: Colors.black54, height: 1.6),
          ),
          const SizedBox(height: 24),
          CashBubble(
            message: CashTips.profileReactions[profile] ??
                "Awesome profile! You're going to do great things in the market! 🌱",
            mood: CashMood.excited,
          ),
          const Spacer(flex: 3),
          _PrimaryButton(label: 'Continue', onTap: onNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Page 5 — Display name ─────────────────────────────────────────────────────

class _NamePage extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onFinish;
  const _NamePage({required this.controller, required this.onFinish});

  @override
  State<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<_NamePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          32, 40, 32, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What should we call you?',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          const Text(
            'This is your display name on leaderboards.',
            style: TextStyle(fontSize: 15, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          const CashBubble(
            message: "Don't be shy! Even 'Warren B.' had to start somewhere. Pick a name you're proud to put on leaderboards! 😄",
            mood: CashMood.happy,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: widget.controller,
            autofocus: false,
            maxLength: 24,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'e.g. Alex, InvestorPro…',
              hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.normal),
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _kPrimary, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => widget.onFinish(),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Start Investing →',
            onTap: widget.onFinish,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: widget.onFinish,
              child: const Text('Skip for now',
                  style: TextStyle(color: Colors.black38, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared button ─────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? _kPrimary : Colors.grey.shade300,
          foregroundColor: enabled ? Colors.white : Colors.grey.shade500,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: enabled ? 2 : 0,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
