import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PsychologyTestScreen extends StatefulWidget {
  final String baseUrl;
  final String userId;

  const PsychologyTestScreen({
    super.key,
    required this.baseUrl,
    required this.userId,
  });

  @override
  State<PsychologyTestScreen> createState() => _PsychologyTestScreenState();
}

class _PsychologyTestScreenState extends State<PsychologyTestScreen> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  List<Question> _questions = [];
  int _currentIndex = 0;

  final Map<String, int> _answers = {};

  String? _resultText;
  int? _score;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('${widget.baseUrl}/psychology/questions?count=10');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Қателік: ${response.statusCode}');
      }

      final data = json.decode(response.body) as List<dynamic>;
      final questions = data.map((e) => Question.fromJson(e)).toList();

      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _answers.clear();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Сұрақтарды жүктеу кезінде қате болды.';
      });
    }
  }

  Future<void> _sendResults() async {
    if (_questions.isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final body = {
        'userId': widget.userId,
        'answers': _answers.entries
            .map((e) => {
                  'questionId': e.key,
                  'value': e.value,
                })
            .toList(),
      };

      final uri = Uri.parse('${widget.baseUrl}/psychology/submit');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Қате: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      setState(() {
        _score = data['score'] as int?;
        _resultText = data['stateText'] as String?;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Нәтижені жіберу кезінде қате кетті.';
      });
    }
  }

  void _onAnswerSelected(int value) async {
    final q = _questions[_currentIndex];
    _answers[q.id] = value;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      await _sendResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Психологиялық тест"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4F2FF),
              Color(0xFFFDFBFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  _resultText != null
                      ? _buildResult(theme)
                      : _buildQuestion(theme),
                  if (_submitting)
                    Container(
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuestion(ThemeData theme) {
    if (_questions.isEmpty) {
      return Center(
        child: Text(
          _error ?? 'Сұрақтар табылмады.',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final total = _questions.length;
    final current = _currentIndex + 1;
    final progress = current / total;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                  label: Text(
                    'Сұрақ $current / $total',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '3–4 минут • анонимді',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(40),
              backgroundColor: Colors.white,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '🧠',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Сезіміңізге жақынырақ жауапты таңдаңыз:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        question.text,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          children: [
                            _answerButton("Мүлдем келіспеймін", 1, theme),
                            _answerButton("Көбіне келіспеймін", 2, theme),
                            _answerButton("Көбіне келісемін", 3, theme),
                            _answerButton("Толықтай келісемін", 4, theme),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerButton(String text, int value, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary.withOpacity(0.06),
      theme.colorScheme.primary.withOpacity(0.10),
      theme.colorScheme.primary.withOpacity(0.16),
      theme.colorScheme.primary.withOpacity(0.22),
    ];

    final index = (value - 1).clamp(0, 3);
    final background = colors[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _submitting ? null : () => _onAnswerSelected(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            child: Row(
              children: [
                Icon(
                  Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
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
  }

  Widget _buildResult(ThemeData theme) {
    String emoji = '🙂';
    Color circleColor = theme.colorScheme.primary.withOpacity(0.15);

    if (_score != null && _questions.isNotEmpty) {
      final maxScore = _questions.length * 4;
      final ratio = _score! / maxScore;
      if (ratio <= 0.35) {
        emoji = '🌈';
        circleColor = Colors.greenAccent.withOpacity(0.25);
      } else if (ratio <= 0.7) {
        emoji = '🙂';
        circleColor = Colors.amber.withOpacity(0.25);
      } else {
        emoji = '💜';
        circleColor = Colors.deepPurpleAccent.withOpacity(0.22);
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Қорытынды",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_score != null && _questions.isNotEmpty)
              Center(
                child: Text(
                  "Жиналған ұпай: $_score / ${_questions.length * 4}",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _resultText ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Басты бетке оралу",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _resultText = null;
                  _score = null;
                  _answers.clear();
                  _currentIndex = 0;
                });
                _loadQuestions();
              },
              child: const Text("Тестті қайта өту"),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String id;
  final String text;

  Question({
    required this.id,
    required this.text,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] as String,
      text: json['text'] as String,
    );
  }
}
