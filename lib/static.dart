import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatsScreen extends StatefulWidget {
  final String baseUrl;
  final String userId;

  const StatsScreen({
    super.key,
    required this.baseUrl,
    required this.userId,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final now = DateTime.now();
    final uri = Uri.parse('${widget.baseUrl}/mood/stats').replace(
      queryParameters: {
        'month': now.month.toString(),
        'year': now.year.toString(),
        'userId': widget.userId,
      },
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final parsed = <String, int>{};
        for (final item in data) {
          final id = item['_id']?.toString() ?? '';
          final countRaw = item['count'];
          final count =
              countRaw is int ? countRaw : int.tryParse('$countRaw') ?? 0;
          if (id.isNotEmpty) parsed[id] = count;
        }
        if (!mounted) return;
        setState(() => _stats = parsed);
      } else {
        setState(() => _error = 'Қате орын алды (${res.statusCode})');
      }
    } catch (e) {
      setState(() => _error = 'Желілік қате: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  int get _total => _stats.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final moodColors = {
      'very_happy': Colors.green,
      'happy': Colors.lightGreen,
      'neutral': Colors.grey,
      'sad': Colors.orange,
      'angry': Colors.red,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        title: const Text('Көңіл-күй статистикасы'),
        backgroundColor: const Color(0xFF6750A4),
        centerTitle: true,
        elevation: 2,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : _total == 0
                  ? const Center(
                      child: Text(
                        'Бұл айда жазба жоқ 😌',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 260,
                                  width: 260,
                                  child: CustomPaint(
                                    painter: _DonutPainter(_stats),
                                    child: Center(
                                      child: Text(
                                        '$_total күн',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildLegend(moodColors),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildMotivationalCard(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildLegend(Map<String, Color> colors) {
    Widget row(String id, String label) {
      final count = _stats[id] ?? 0;
      if (count == 0) return const SizedBox.shrink();
      final percent = ((count / _total) * 100).round();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: colors[id],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('$label — $percent% ($count)'),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row('very_happy', 'Керемет'),
        row('happy', 'Жақсы'),
        row('neutral', 'Қалыпты'),
        row('sad', 'Мұңды'),
        row('angry', 'Ашулы'),
      ],
    );
  }

  Widget _buildMotivationalCard() {
    final total = _total;
    final happy = (_stats['very_happy'] ?? 0) + (_stats['happy'] ?? 0);
    final neutral = _stats['neutral'] ?? 0;
    final sad = (_stats['sad'] ?? 0) + (_stats['angry'] ?? 0);
    final ratio = total == 0 ? 0.0 : happy / total;

    String message;
    String emoji;

    if (ratio >= 0.6) {
      message = "Керемет! 🌈 Сенің айың позитивке толы. Осы қарқынды сақта!";
      emoji = "🌞";
    } else if (neutral > total * 0.4) {
      message = "Барлығы теңдей өтті. Кейде тыныштық та маңызды 💜";
      emoji = "💫";
    } else if (sad > happy) {
      message =
          "Сәл қиын кезең болған сияқты 😔 Бірақ бәрі артта қалады. Жақсы күндер алда!";
      emoji = "🌤️";
    } else {
      message = "Бәрі жақсы бағытта! Сен күштісің 💪🏼";
      emoji = "🌼";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB39DDB), Color(0xFF7E57C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 38),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, int> stats;
  _DonutPainter(this.stats);

  static const _colors = {
    'very_happy': Colors.green,
    'happy': Colors.lightGreen,
    'neutral': Colors.grey,
    'sad': Colors.orange,
    'angry': Colors.red,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final total = stats.values.fold(0, (a, b) => a + b);
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38;

    canvas.drawCircle(center, radius - 20, bgPaint);

    if (total == 0) return;

    double startAngle = -math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 20);

    stats.forEach((id, count) {
      if (count == 0) return;
      final sweep = (count / total) * 2 * math.pi;

      final paint = Paint()
        ..color = _colors[id] ?? Colors.blueGrey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
