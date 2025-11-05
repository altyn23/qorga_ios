import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import 'chat.dart';
import 'news.dart';

const Color kSky = Color(0xFFAEC9E3);
const Color kSurface = Colors.white;
const Color kAccent = Color(0xFF2D5B89);
const Color kTile = Color(0xFFE6F0F9);

class MoodPage extends StatefulWidget {
  final String baseUrl;
  final String userId;

  const MoodPage({
    super.key,
    required this.baseUrl,
    required this.userId,
  });

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedMood;
  bool _saving = false;

  Map<String, int> _stats = {};

  OverlayEntry? _overlayEntry;

  final List<_MoodOption> moods = const [
    _MoodOption(
        id: 'very_happy',
        label: 'Керемет',
        emoji: '😁',
        color: Color(0xFFD0F2FF)),
    _MoodOption(
        id: 'happy', label: 'Жақсы', emoji: '😊', color: Color(0xFFC8FAD6)),
    _MoodOption(
        id: 'neutral', label: 'Қалыпты', emoji: '😐', color: Color(0xFFF4F1C5)),
    _MoodOption(
        id: 'sad', label: 'Мұңды', emoji: '😢', color: Color(0xFFFFE3E3)),
    _MoodOption(
        id: 'angry', label: 'Ашулы', emoji: '😡', color: Color(0xFFFFD0D0)),
  ];

  @override
  void initState() {
    super.initState();
    _loadStatsForMonth(DateTime.now());
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  bool _isFutureDay(DateTime day) {
    final today = DateTime.now();
    final d = DateTime(day.year, day.month, day.day);
    final t = DateTime(today.year, today.month, today.day);
    return d.isAfter(t);
  }

  void _showTopMessage(String text, {bool isError = false}) {
    final overlay = Overlay.of(context);

    _overlayEntry?.remove();
    _overlayEntry = null;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Positioned(
          top: topPadding + 12,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -10),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isError
                      ? Colors.redAccent.withOpacity(0.95)
                      : Colors.green.shade600.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> _save() async {
    if (_selectedMood == null) {
      _showTopMessage('Алдымен көңіл-күйді таңда', isError: true);
      return;
    }

    setState(() => _saving = true);

    final url = Uri.parse('${widget.baseUrl}/mood');
    final body = {
      'userId': widget.userId,
      'date': _selectedDay.toIso8601String(),
      'mood': _selectedMood!,
      'note': '',
    };

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        await _loadStatsForMonth(_selectedDay);
        if (mounted) {
          _showTopMessage('Көңіл-күй сақталды ✅');
        }
      } else {
        if (mounted) {
          _showTopMessage('Қате: ${res.statusCode}', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showTopMessage('Қате: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadStatsForMonth(DateTime date) async {
    final month = date.month;
    final year = date.year;

    final url = Uri.parse('${widget.baseUrl}/mood/stats').replace(
      queryParameters: {
        'month': '$month',
        'year': '$year',
        'userId': widget.userId,
      },
    );

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final Map<String, int> parsed = {};
        for (var item in data) {
          parsed[item['_id']] = item['count'] as int;
        }
        if (mounted) {
          setState(() {
            _stats = parsed;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSky,
      appBar: AppBar(
        title: const Text('Көңіл-күй'),
        backgroundColor: kSky,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Көңіл-күй күнтізбесі',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Күнді таңда, сосын көңіл-күйіңді белгіле. Осылайша біз ай сайынғы күйіңді көре аламыз 💙',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    _buildCalendar(),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Бүгінгі көңіл-күй',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _formatDate(_selectedDay),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: moods.map((m) {
                        final selected = _selectedMood == m.id;
                        return _MoodCard(
                          option: m,
                          selected: selected,
                          onTap: () {
                            setState(() => _selectedMood = m.id);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          _saving ? 'Сақталуда...' : 'Сақтау',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Айлық статистика',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildStats(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kAccent,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewsScreen(),
                ),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Басты'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Көңіл-күй'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Чат'),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper), label: 'Мақалалар'),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(2024),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      enabledDayPredicate: (day) => !_isFutureDay(day),
      onDaySelected: (selected, focused) {
        if (_isFutureDay(selected)) return;
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        _loadStatsForMonth(selected);
      },
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        leftChevronIcon: const Icon(Icons.chevron_left, size: 22),
        rightChevronIcon: const Icon(Icons.chevron_right, size: 22),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: kAccent.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: kAccent,
          shape: BoxShape.circle,
        ),
        disabledTextStyle: TextStyle(
          color: Colors.grey.shade400,
        ),
        disabledDecoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_stats.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: kTile,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: const Text('Бұл айда жазба жоқ 😌'),
      );
    }
    return Column(
      children: moods.map((m) {
        final count = _stats[m.id] ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(m.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: m.color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: count == 0
                        ? 0
                        : (count / _maxStatCount()).clamp(0.15, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: m.color,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _maxStatCount() {
    if (_stats.isEmpty) return 1;
    return _stats.values.reduce((a, b) => a > b ? a : b);
  }

  String _formatDate(DateTime d) {
    const months = [
      'қаң',
      'ақп',
      'нау',
      'сәу',
      'мам',
      'мау',
      'шіл',
      'там',
      'қыр',
      'қаз',
      'қар',
      'жел'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _MoodOption {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  const _MoodOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

class _MoodCard extends StatelessWidget {
  final _MoodOption option;
  final bool selected;
  final VoidCallback onTap;
  const _MoodCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? option.color : option.color.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: selected
                ? Border.all(color: Colors.black12, width: 1)
                : Border.all(color: Colors.transparent),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: option.color.withOpacity(0.6),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(option.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                option.label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
