import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/quiz_service.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final PreferencesService prefsService;
  final QuizService quizService;

  const HomeScreen({
    super.key,
    required this.prefsService,
    required this.quizService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    int userCoins = widget.prefsService.getCoins();
    bool isMediumUnlocked = widget.prefsService.isMediumUnlocked() || userCoins >= 500;
    bool isHardUnlocked = widget.prefsService.isHardUnlocked();

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'اردو الفاظ کوئز',
          style: TextStyle(fontFamily: 'UrduNastaliq', fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(
                    prefsService: widget.prefsService,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    prefsService: widget.prefsService,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner header card with Coins, Daily Reward, & Banner image
              _buildTopHeaderCard(userCoins),

              const SizedBox(height: 16),

              // Daily Reward Button (#8)
              _buildDailyRewardButton(),

              const SizedBox(height: 20),

              // Categories Header (#2)
              const Text(
                'کیٹیگری منتخب کریں:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'UrduNastaliq',
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 10),

              // 8 Categories Horizontal/Grid Chips
              _buildCategoryChips(),

              const SizedBox(height: 24),

              // Levels Header (#1, #7)
              const Text(
                'لیول کا انتخاب کریں:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'UrduNastaliq',
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),

              // Level 1: Easy
              _buildLevelCard(
                levelNum: 1,
                titleUrdu: 'آسان لیول (سوالات 1 - 1000)',
                titleEng: 'Easy Level',
                color: Colors.green,
                isUnlocked: true,
                onTap: () => _startQuiz(1),
              ),

              const SizedBox(height: 12),

              // Level 2: Medium
              _buildLevelCard(
                levelNum: 2,
                titleUrdu: 'درمیانہ لیول (سوالات 1001 - 2000)',
                titleEng: 'Medium Level',
                color: Colors.orange,
                isUnlocked: isMediumUnlocked,
                lockReason: 'پہلا لیول مکمل کریں یا 500 سکے حاصل کریں',
                onTap: () => _startQuiz(2),
              ),

              const SizedBox(height: 12),

              // Level 3: Hard (#7 Requirement: 1000 coins to unlock Hard level)
              _buildLevelCard(
                levelNum: 3,
                titleUrdu: 'مشکل لیول (سوالات 2001 - 3000)',
                titleEng: 'Hard Level (1000 Coins)',
                color: Colors.redAccent,
                isUnlocked: isHardUnlocked,
                lockReason: '1000 سکے جمع کریں یا درمیانہ لیول مکمل کریں',
                onTap: () => _startQuiz(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeaderCard(int coins) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'اردو کوئز، ٹرک و چیلنج',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'UrduNastaliq',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Play store banner image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Gemini_Generated_Image_drolzqdrolzqdrol.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRewardButton() {
    bool canClaim = widget.prefsService.canClaimDailyReward();
    int streak = widget.prefsService.getStreakCount();

    return InkWell(
      onTap: _showDailyRewardDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFB45309)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'اسٹریک: $streak/7 دن',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            Row(
              children: [
                Text(
                  canClaim ? '🎁 روز آؤ 20 سکہ لو!' : '✅ آج کا انعام وصول شدہ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'UrduNastaliq',
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.card_giftcard, color: Colors.amberAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyRewardDialog() async {
    Map<String, dynamic> result = await widget.prefsService.claimDailyReward();
    setState(() {});

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          result['success'] == true ? '🎁 روزانہ انعام' : 'اطلاع',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.amber, fontFamily: 'UrduNastaliq'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 50),
            const SizedBox(height: 12),
            Text(
              result['message'],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              '7 دن مسلسل کھیلنے پر 100 سکہ بونس ملتا ہے!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('شکریہ', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _buildCategoryChip('All', 'تمام سوالات'),
        ...QuizService.categoriesList.map((cat) {
          return _buildCategoryChip(cat['urdu']!, cat['urdu']!);
        }),
      ],
    );
  }

  Widget _buildCategoryChip(String categoryKey, String label) {
    bool isSelected = selectedCategory == categoryKey;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontFamily: 'UrduNastaliq',
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.amber,
      backgroundColor: const Color(0xFF1E293B),
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = selected ? categoryKey : 'All';
        });
      },
    );
  }

  Widget _buildLevelCard({
    required int levelNum,
    required String titleUrdu,
    required String titleEng,
    required Color color,
    required bool isUnlocked,
    String? lockReason,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isUnlocked
          ? onTap
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    lockReason ?? 'یہ لیول ابھی مقفل ہے!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'UrduNastaliq'),
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? color.withOpacity(0.6) : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUnlocked ? Icons.play_circle_fill : Icons.lock,
              color: isUnlocked ? color : Colors.grey,
              size: 36,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    titleUrdu,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'UrduNastaliq',
                    ),
                  ),
                  Text(
                    titleEng,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white60 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  if (!isUnlocked && lockReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lockReason,
                      style: const TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(int level) {
    var questions = widget.quizService.getQuestionsByLevel(
      level,
      category: selectedCategory == 'All' ? null : selectedCategory,
    );

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اس کیٹیگری میں کوئی سوال نہیں ملا!'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          level: level,
          categoryFilter: selectedCategory,
          questions: questions,
          prefsService: widget.prefsService,
          quizService: widget.quizService,
        ),
      ),
    ).then((_) => setState(() {}));
  }
}
