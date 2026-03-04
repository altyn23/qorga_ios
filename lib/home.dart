import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';
import 'config.dart';
import 'mood.dart';
import 'login.dart';
import 'profile.dart';
import 'news.dart';
import 'help.dart';
import 'about_us.dart';
import 'psychology_test.dart';
import 'services/local_notification_service.dart';
import 'widgets/notification_helper.dart';

const Color kPrimaryColor = Color(0xFF3B82F6);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  String? _userId;
  String? _email;
  String? _name;
  String _role = 'user';
  bool _isLoading = true;
  List<String> _recentActions = const [];
  bool _checkingAlerts = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _userId = prefs.getString('userId');
      _email = prefs.getString('email');
      _name = prefs.getString('name');
      _role = (prefs.getString('role') ?? 'user').trim();
      _recentActions = prefs.getStringList('recentActions') ?? const [];
      if (_role == 'psychologist' && _tab > 1) {
        _tab = 0;
      }
      _isLoading = false;
    });

    await _checkUnreadAlerts();
  }

  Future<void> _checkUnreadAlerts() async {
    if (_userId == null || _checkingAlerts) return;
    if (_role == 'psychologist') return;

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    if (!notificationsEnabled) return;

    _checkingAlerts = true;
    try {
      final uri = Uri.parse('$apiBaseUrl/user/$_userId/alerts?unread=true');
      final res = await http.get(uri);
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? const [];
      if (items.isEmpty) return;

      for (final item in items) {
        final map = Map<String, dynamic>.from(item as Map);
        final alertId = map['id']?.toString() ?? '';
        final message = map['message']?.toString() ?? '';
        if (message.isNotEmpty && mounted) {
          NotificationHelper.showInfo(context, message);
          await LocalNotificationService.showMoodRiskNotification(message);
        }

        if (alertId.isNotEmpty) {
          await http.post(
            Uri.parse('$apiBaseUrl/user/$_userId/alerts/$alertId/read'),
          );
        }
      }
    } catch (_) {
      // Silent fail: alerts should not block home screen.
    } finally {
      _checkingAlerts = false;
    }
  }

  Future<void> _trackAction(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final items = [..._recentActions];
    items.remove(action);
    items.insert(0, action);
    final trimmed = items.take(4).toList();
    await prefs.setStringList('recentActions', trimmed);
    if (!mounted) return;
    setState(() => _recentActions = trimmed);
  }

  Future<void> _openPsychologyTest() async {
    if (_userId == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      await _loadUserData();
      if (!mounted || _userId == null) return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PsychologyTestScreen(
          baseUrl: apiBaseUrl,
          userId: _userId!,
        ),
      ),
    );
    await _trackAction('Психология тесті');
  }

  void _onTabTapped(int index) async {
    final isPsychologist = _role == 'psychologist';
    final chatTabIndex = isPsychologist ? 0 : 2;

    if (index == chatTabIndex) {
      final newIndex = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
      await _trackAction('Чат');
      await _checkUnreadAlerts();
      if (newIndex is int && newIndex != chatTabIndex) {
        setState(() {
          _tab = newIndex;
        });
      }
      return;
    }
    if (!isPsychologist && index == 1) {
      if (_userId == null) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        await _loadUserData();
        if (!mounted || _userId == null) return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MoodPage(
            baseUrl: apiBaseUrl,
            userId: _userId!,
          ),
        ),
      );
      await _trackAction('Көңіл-күй');
      await _checkUnreadAlerts();
      return;
    }

    if (!isPsychologist && index == 3) {
      await _trackAction('Мақалалар');
    }
    if (isPsychologist && index == 1) {
      await _trackAction('Профиль');
    }

    setState(() {
      _tab = index;
    });
  }

  List<Widget> _buildTabScreens() {
    if (_role == 'psychologist') {
      return [
        _buildPsychologistHomePage(),
        const ProfileScreen(),
      ];
    }

    return [
      _buildHomePageBody(),
      Container(),
      Container(),
      const NewsScreen(),
    ];
  }

  Widget _buildHomePageBody() {
    final displayName = (_name == null || _name!.trim().isEmpty)
        ? 'достым'
        : _name!.split(' ').first;

    if (_role == 'psychologist') {
      return _buildPsychologistHomePage();
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Card(
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF60A5FA),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Сәлем, $displayName 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'QORGA сені қолдайды.\nКөңіл-күйіңді бақылап, қажет кезде көмек ал.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Көңіл-күйіңді бүгін белгілеуді ұмытпа ✨',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        '💙',
                        style: TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _QuoteGeneratorWidget(),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Жылдам әрекеттер',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Чат'),
                        onPressed: () => _onTabTapped(2),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.favorite_border, size: 18),
                        label: const Text('Көңіл-күй'),
                        onPressed: () => _onTabTapped(1),
                      ),
                      ActionChip(
                        avatar:
                            const Icon(Icons.psychology_alt_outlined, size: 18),
                        label: const Text('Тест'),
                        onPressed: _openPsychologyTest,
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.newspaper_outlined, size: 18),
                        label: const Text('Мақалалар'),
                        onPressed: () => _onTabTapped(3),
                      ),
                    ],
                  ),
                  if (_recentActions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Соңғы әрекеттер: ${_recentActions.join(" · ")}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _PsychologyTestCard(onStart: _openPsychologyTest),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPsychologistHomePage() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Психолог панелі',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Сізге тек маңыздысы қалды: клиент чаты және өз профиліңіз.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _onTabTapped(0),
                      icon: const Icon(Icons.forum_outlined),
                      label: const Text('Клиенттер чаттарын ашу'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Психолог профилі'),
              subtitle: const Text('Жеке мәліметтер мен қауіпсіздік'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _tab = 1),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: _role == 'psychologist' ? null : _buildDrawer(),
      appBar: AppBar(
        title: const Text(
          'QORGA',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTabScreens()[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: _onTabTapped,
        items: _role == 'psychologist'
            ? const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline), label: 'Чаттар'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: 'Профиль'),
              ]
            : const [
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

  Drawer _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.account_circle,
                  size: 30,
                  color: kPrimaryColor,
                ),
              ),
              title: Text(
                _name ?? 'Пайдаланушы',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(_userId == null ? 'Кіру' : (_email ?? 'Профиль')),
              onTap: () async {
                Navigator.pop(context);
                if (_userId == null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                  await _loadUserData();
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  await _loadUserData();
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.call, color: kPrimaryColor),
              title: const Text('Көмек'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.menu_book_outlined, color: kPrimaryColor),
              title: const Text('Біз туралы'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _QuoteGeneratorWidget extends StatefulWidget {
  const _QuoteGeneratorWidget();

  @override
  State<_QuoteGeneratorWidget> createState() => _QuoteGeneratorWidgetState();
}

class _QuoteGeneratorWidgetState extends State<_QuoteGeneratorWidget> {
  final List<Map<String, String>> _quotes = [
    {"quote": "Ең үлкен жеңіс - өзіңді жеңу.", "author": "Платон"},
    {
      "quote": "Білімді болу жеткіліксіз, оны қолдана білу керек.",
      "author": "Иоганн Гёте"
    },
    {"quote": "Сен не ойласаң, сен солсың.", "author": "Будда"},
    {"quote": "Жақсылық жасаудан ешқашан жалықпа.", "author": "Марк Твен"},
    {
      "quote": "Ертеңгі күннің кедергісі - бүгінгі күмән.",
      "author": "Франклин Рузвельт"
    },
    {
      "quote":
          "Өзгерістің құпиясы - ескімен күресуге емес, жаңаны құруға назар аудару.",
      "author": "Сократ"
    },
    {
      "quote":
          "Жетістікке жетудің жалғыз жолы - жасап жатқан ісіңді жақсы көру.",
      "author": "Стив Джобс"
    }
  ];

  late Map<String, String> _currentQuote;

  @override
  void initState() {
    super.initState();
    _generateNewQuote();
  }

  void _generateNewQuote() {
    setState(() {
      _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _generateNewQuote,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Күннің дәйексөзі',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              Icon(
                Icons.format_quote_rounded,
                color: kPrimaryColor.withValues(alpha: 0.7),
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                _currentQuote['quote']!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "— ${_currentQuote['author']!}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PsychologyTestCard extends StatelessWidget {
  final VoidCallback onStart;

  const _PsychologyTestCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.surfaceContainerLowest,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            height: 150,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '🧠',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Психологиялық тест',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '10 сұрақ • 3–4 минут',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          'Қазіргі эмоциялық күйіңді анықтап, нәтижені сақтаймыз. '
                          'Картаны басып, қысқа тесттен өт.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Тестті бастау',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: kPrimaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
