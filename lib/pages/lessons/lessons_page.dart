import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'lesson_content.dart';
import '../../services/lesson/lesson_service.dart';
import '../../services/notification/notification_service.dart';
import '../../widgets/cash_bubble.dart';
import '../../data/cash_tips.dart';

class Lesson {
  final String id;
  final String title;
  final String category;
  final String level;
  final int durationMinutes;
  final int xpReward;
  final String emoji;
  const Lesson({required this.id, required this.title, required this.category,
    required this.level, required this.durationMinutes, required this.xpReward,
    required this.emoji});
}

const kCategoryColors = {
  'Basics':    Color(0xFF1565C0),
  'Portfolio': Color(0xFF2E7D32),
  'Strategy':  Color(0xFF6A1B9A),
  'Advanced':  Color(0xFFC62828),
  'Crypto':    Color(0xFFF57F17),
  'Money':     Color(0xFF00838F),
};

const kLessons = [
  Lesson(id:'l1',  title:'What is a Stock?',               category:'Basics',    level:'Beginner',     durationMinutes:7,  xpReward:80,  emoji:'📈'),
  Lesson(id:'l2',  title:'How Markets Work',               category:'Basics',    level:'Beginner',     durationMinutes:8,  xpReward:75,  emoji:'🏛️'),
  Lesson(id:'l3',  title:'Reading a Stock Chart',          category:'Basics',    level:'Beginner',     durationMinutes:8,  xpReward:75,  emoji:'📊'),
  Lesson(id:'l4',  title:'Bid/Ask & Spreads',              category:'Basics',    level:'Beginner',     durationMinutes:6,  xpReward:70,  emoji:'💱'),
  Lesson(id:'l5',  title:'Diversification',                category:'Portfolio', level:'Beginner',     durationMinutes:8,  xpReward:80,  emoji:'🥧'),
  Lesson(id:'l6',  title:'Risk vs Return',                 category:'Portfolio', level:'Beginner',     durationMinutes:8,  xpReward:80,  emoji:'⚖️'),
  Lesson(id:'l7',  title:'Asset Allocation',               category:'Portfolio', level:'Intermediate', durationMinutes:8,  xpReward:80,  emoji:'🗂️'),
  Lesson(id:'l8',  title:'ETFs & Mutual Funds',            category:'Portfolio', level:'Intermediate', durationMinutes:9,  xpReward:80,  emoji:'🧺'),
  Lesson(id:'l9',  title:'Real Estate Investing 101',      category:'Portfolio', level:'Intermediate', durationMinutes:9,  xpReward:85,  emoji:'🏠'),
  Lesson(id:'l10', title:'REITs & Commercial Real Estate', category:'Portfolio', level:'Intermediate', durationMinutes:8,  xpReward:80,  emoji:'🏢'),
  Lesson(id:'l11', title:'Dollar-Cost Averaging',          category:'Strategy',  level:'Beginner',     durationMinutes:7,  xpReward:75,  emoji:'📅'),
  Lesson(id:'l12', title:'Value vs Growth Investing',      category:'Strategy',  level:'Intermediate', durationMinutes:8,  xpReward:80,  emoji:'🔍'),
  Lesson(id:'l13', title:'Dividend Investing',             category:'Strategy',  level:'Intermediate', durationMinutes:7,  xpReward:75,  emoji:'💰'),
  Lesson(id:'l14', title:'Technical Analysis Intro',       category:'Strategy',  level:'Intermediate', durationMinutes:9,  xpReward:85,  emoji:'📉'),
  Lesson(id:'l15', title:'Options Basics',                 category:'Advanced',  level:'Advanced',     durationMinutes:10, xpReward:90,  emoji:'🎯'),
  Lesson(id:'l16', title:'Short Selling',                  category:'Advanced',  level:'Advanced',     durationMinutes:9,  xpReward:85,  emoji:'📉'),
  Lesson(id:'l17', title:'Margin Trading',                 category:'Advanced',  level:'Advanced',     durationMinutes:9,  xpReward:85,  emoji:'⚡'),
  Lesson(id:'l18', title:'Crypto Fundamentals',            category:'Crypto',    level:'Intermediate', durationMinutes:8,  xpReward:80,  emoji:'🪙'),
  // ── Money Fundamentals (new) ──
  Lesson(id:'l19', title:'Budgeting Basics',               category:'Money',     level:'Beginner',     durationMinutes:7,  xpReward:75,  emoji:'💵'),
  Lesson(id:'l20', title:'Credit Scores',                  category:'Money',     level:'Beginner',     durationMinutes:8,  xpReward:80,  emoji:'💳'),
  Lesson(id:'l21', title:'Taxes 101',                      category:'Money',     level:'Beginner',     durationMinutes:9,  xpReward:80,  emoji:'🧾'),
  Lesson(id:'l22', title:'Emergency Funds',                category:'Money',     level:'Beginner',     durationMinutes:6,  xpReward:70,  emoji:'🛡️'),
  Lesson(id:'l23', title:'Compound Interest',              category:'Money',     level:'Beginner',     durationMinutes:7,  xpReward:80,  emoji:'✨'),
  Lesson(id:'l24', title:'Inflation',                      category:'Money',     level:'Beginner',     durationMinutes:7,  xpReward:75,  emoji:'📉'),
  Lesson(id:'l25', title:'Banking Basics',                 category:'Money',     level:'Beginner',     durationMinutes:7,  xpReward:70,  emoji:'🏦'),
  Lesson(id:'l26', title:'Student Loans',                  category:'Money',     level:'Intermediate', durationMinutes:8,  xpReward:80,  emoji:'🎓'),
];

// ── Lessons Page ──
class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});
  @override
  State<LessonsPage> createState() => LessonsPageState();
}

// Public so HomeScreen can hold a GlobalKey<LessonsPageState> and call reload().
class LessonsPageState extends State<LessonsPage> with AutomaticKeepAliveClientMixin {
  String _selected = 'All';
  final _cats = ['All', 'Basics', 'Portfolio', 'Strategy', 'Advanced', 'Crypto', 'Money'];
  Map<String, LessonProgress> _progress = {};
  int _totalXp = 0;
  int _completedCount = 0;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final data = await LessonService.loadAll();
    if (mounted) {
      setState(() {
        _progress = data.progress;
        _totalXp = data.xp;
        _completedCount = data.count;
        _loading = false;
      });
    }
  }

  // Called externally (e.g. from HomeScreen on tab switch)
  void reload() => _loadProgress();

  List<Lesson> get _filtered => _selected == 'All'
      ? kLessons
      : kLessons.where((l) => l.category == _selected).toList();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final total = kLessons.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Learn', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final sel = _cats[i] == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = _cats[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_cats[i], style: TextStyle(
                      color: sel ? const Color(0xFF2E7D32) : Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Text('⭐', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 4),
                    _loading
                        ? Container(
                            width: 48, height: 13,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text('$_totalXp XP', style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF57F17),
                            fontSize: 13)),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$_completedCount of $total completed',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('${(_completedCount / total * 100).round()}%',
                              style: const TextStyle(fontSize: 12,
                                  color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? _completedCount / total : 0,
                          backgroundColor: const Color(0xFFF0F0F0),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF2E7D32)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lesson list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final lesson = _filtered[i];
                final prog = _progress[lesson.id];
                return _LessonCard(
                  lesson: lesson,
                  progress: prog,
                  onTap: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => LessonDetailPage(lesson: lesson)));
                    await _loadProgress();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lesson Card ──
class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final LessonProgress? progress;
  final VoidCallback onTap;
  const _LessonCard({required this.lesson, required this.onTap, this.progress});

  @override
  Widget build(BuildContext context) {
    final color = kCategoryColors[lesson.category] ?? const Color(0xFF2E7D32);
    final done = progress != null;
    final passed = progress?.passed ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: done ? Border.all(
            color: passed ? const Color(0xFFA5D6A7) : Colors.orange.shade200,
            width: 1.5,
          ) : null,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with completion badge
              Stack(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: done
                          ? (passed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0))
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(lesson.emoji,
                        style: const TextStyle(fontSize: 26))),
                  ),
                  if (done)
                    Positioned(
                      right: -2, bottom: -2,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: passed ? const Color(0xFF2E7D32) : Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            passed ? Icons.check : Icons.refresh,
                            size: 11, color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(lesson.category, style: TextStyle(
                            fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(lesson.level, style: const TextStyle(
                            fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(lesson.title, style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.timer_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text('${lesson.durationMinutes} min',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 10),
                      if (!done) ...[
                        const Text('⭐', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 3),
                        Text('+${lesson.xpReward} XP',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                      if (done) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: passed
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Score: ${progress!.scoreLabel}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: passed
                                      ? const Color(0xFF2E7D32)
                                      : Colors.orange)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          passed
                              ? '+${progress!.xpEarned} XP earned'
                              : 'Retake to earn XP',
                          style: TextStyle(
                              fontSize: 11,
                              color: passed
                                  ? const Color(0xFF2E7D32)
                                  : Colors.orange),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Lesson Detail Page ──
class LessonDetailPage extends StatefulWidget {
  final Lesson lesson;
  const LessonDetailPage({super.key, required this.lesson});
  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  int _slide = 0;
  bool _showQuiz = false;
  int _quizIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _completed = false;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  LessonContent? get _content => kLessonContent[widget.lesson.id];

  List<Map<String, String>> get _slides {
    final c = _content;
    if (c == null) return [
      {'title': 'Coming Soon', 'body': 'Full lesson content coming soon!'}
    ];
    return c.slides.map((s) => {'title': s.title, 'body': s.body}).toList();
  }

  List<Map<String, dynamic>> get _quiz {
    final c = _content;
    if (c == null) return [
      {'question': 'What is investing?',
       'options': ['Spending money', 'Growing wealth over time', 'Saving only', 'None'],
       'correct': 1,
       'explanation': 'Investing is putting money to work to grow wealth over time.'}
    ];
    return c.quiz.map((q) => {
      'question': q.question,
      'options': q.options,
      'correct': q.correctIndex,
      'explanation': q.explanation,
    }).toList();
  }

  Color get _color => kCategoryColors[widget.lesson.category] ?? const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    if (_completed) return _buildResult();
    if (_showQuiz) return _buildQuiz();
    return _buildSlides();
  }

  Widget _buildSlides() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: Colors.white,
        title: Text(widget.lesson.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_slide + 1) / _slides.length,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _slide = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Scrollable white card content
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: const EdgeInsets.all(24),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${i + 1} of ${_slides.length}',
                                  style: TextStyle(
                                      color: _color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              const SizedBox(height: 12),
                              Text(_slides[i]['title']!, style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              Text(_slides[i]['body']!, style: const TextStyle(
                                  fontSize: 15, height: 1.7, color: Colors.black87)),
                              const SizedBox(height: 32),
                              Center(child: Text(widget.lesson.emoji,
                                  style: const TextStyle(fontSize: 56))),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_slides.length, (j) =>
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: _slide == j ? 20 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _slide == j
                                            ? _color
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Fade gradient — hints at more scrollable content below
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.92),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Cash tip for current slide
          Builder(builder: (_) {
            final tip = CashTips.getSlideTip(widget.lesson.id, _slide);
            if (tip == null) return const SizedBox.shrink();
            return CashBubble(message: tip, mood: CashMood.thinking);
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Row(
              children: [
                if (_slide > 0) ...[
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _color),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Icon(Icons.arrow_back, color: _color),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_slide == _slides.length - 1) {
                          setState(() => _showQuiz = true);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _slide == _slides.length - 1
                            ? 'Take Quiz →'
                            : 'Next →',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildQuiz() {
    final q = _quiz[_quizIndex];
    final options = q['options'] as List<String>;
    final correct = q['correct'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _color,
        foregroundColor: Colors.white,
        title: Text('Quiz · ${_quizIndex + 1}/${_quiz.length}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Scrollable quiz content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_quizIndex + 1) / _quiz.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(_color),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 24),
                  Text(q['question'] as String, style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ...options.asMap().entries.map((e) {
                    final idx = e.key;
                    Color bg = Colors.white;
                    Color border = Colors.transparent;
                    if (_answered) {
                      if (idx == correct) {
                        bg = const Color(0xFFE8F5E9);
                        border = const Color(0xFF2E7D32);
                      } else if (idx == _selectedAnswer) {
                        bg = const Color(0xFFFFEBEE);
                        border = Colors.red;
                      }
                    } else if (_selectedAnswer == idx) {
                      border = _color;
                    }
                    return GestureDetector(
                      onTap: _answered ? null : () =>
                          setState(() => _selectedAnswer = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border, width: 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.value,
                                style: const TextStyle(fontSize: 15))),
                            if (_answered && idx == correct)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF2E7D32)),
                            if (_answered && idx == _selectedAnswer && idx != correct)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_answered) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(q['explanation'] as String,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87, height: 1.5))),
                        ],
                      ),
                    ),
                  ],
                  // Cash reaction
                  const SizedBox(height: 8),
                  CashBubble(
                    message: _answered
                        ? (_selectedAnswer == correct
                            ? CashTips.getCorrectMessage(widget.lesson.id)
                            : CashTips.getWrongMessage(widget.lesson.id))
                        : CashTips.getQuizHint(widget.lesson.id, _quizIndex),
                    mood: _answered
                        ? (_selectedAnswer == correct
                            ? CashMood.excited
                            : CashMood.encouraging)
                        : CashMood.thinking,
                  ),
                ],
              ),
            ),
          ),
          // Pinned bottom button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _selectedAnswer == null ? null : () async {
                  if (!_answered) {
                    setState(() {
                      _answered = true;
                      if (_selectedAnswer == correct) _score++;
                    });
                  } else if (_quizIndex < _quiz.length - 1) {
                    setState(() {
                      _quizIndex++;
                      _selectedAnswer = null;
                      _answered = false;
                    });
                  } else {
                    // Save progress before showing result
                    final passed = _score >= (_quiz.length * 0.6).ceil();
                    await LessonService.saveProgress(
                      lessonId: widget.lesson.id,
                      score: _score,
                      totalQuestions: _quiz.length,
                      xpEarned: passed ? widget.lesson.xpReward : 0,
                    );
                    if (passed) {
                      // Lesson completion notification
                      await NotificationService.addForLessonComplete(
                        lessonId: widget.lesson.id,
                        lessonTitle: widget.lesson.title,
                        xp: widget.lesson.xpReward,
                      );
                      // Badge milestone notifications
                      final count = await LessonService.getCompletedCount();
                      if (count == 1) {
                        await NotificationService.addForBadge(
                          badgeId: 'first_steps', badgeEmoji: '🌱',
                          badgeTitle: 'First Steps',
                          description: 'Complete 1 lesson',
                        );
                      } else if (count == 5) {
                        await NotificationService.addForBadge(
                          badgeId: 'bookworm', badgeEmoji: '📚',
                          badgeTitle: 'Bookworm',
                          description: 'Complete 5 lessons',
                        );
                      } else if (count == 10) {
                        await NotificationService.addForBadge(
                          badgeId: 'graduate', badgeEmoji: '🎓',
                          badgeTitle: 'Graduate',
                          description: 'Complete 10 lessons',
                        );
                      } else if (count >= 26) {
                        await NotificationService.addForBadge(
                          badgeId: 'master', badgeEmoji: '🏆',
                          badgeTitle: 'Master',
                          description: 'Complete all lessons',
                        );
                      }
                    }
                    setState(() => _completed = true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  !_answered
                      ? 'Check Answer'
                      : _quizIndex < _quiz.length - 1
                      ? 'Next Question →'
                      : 'See Results',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final passed = _score >= (_quiz.length * 0.6).ceil();
    return Scaffold(
      backgroundColor: _color,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SvgPicture.asset(
                passed
                    ? 'assets/images/cash/cash_excited.svg'
                    : 'assets/images/cash/cash_encouraging.svg',
                height: 120,
              ),
              const SizedBox(height: 12),
              Text(passed ? 'Lesson Complete!' : 'Keep Studying!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('You scored $_score/${_quiz.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18)),
              if (passed) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Text('+${widget.lesson.xpReward} XP earned!',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Cash completion message
              CashBubble(
                message: CashTips.getCompletionMessage(widget.lesson.id),
                mood: passed ? CashMood.excited : CashMood.encouraging,
                darkBackground: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _color,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Back to Lessons',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              if (!passed) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _showQuiz = false;
                    _slide = 0;
                    _quizIndex = 0;
                    _selectedAnswer = null;
                    _answered = false;
                    _score = 0;
                    _completed = false;
                  }),
                  child: const Text('Try Again',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
