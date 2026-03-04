import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'login.dart';
import 'static.dart';
import 'widgets/email_validator.dart';
import 'widgets/password_validator.dart';
import 'theme/theme_controller.dart';

const Color kPrimaryColor = Color(0xFF3B82F6);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _oldPasswordFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  String? _userId;
  String _role = 'user';
  String _avatarBase64 = '';
  bool _notificationsEnabled = true;

  bool _isLoading = false;
  bool _isDataLoaded = false;
  bool _isPasswordSectionVisible = false;

  bool _isOldPasswordObscured = true;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  bool _statsLoading = false;
  Map<String, int> _moodStats = {};
  String _moodComment = '';

  @override
  void initState() {
    super.initState();

    _loadUserData();

    _nameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _oldPasswordController.dispose();
    _oldPasswordFocusNode.dispose();
    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _userId = prefs.getString('userId');
      _role = (prefs.getString('role') ?? 'user').trim();
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _avatarBase64 = prefs.getString('avatarBase64') ?? '';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _isLoading = false;
      _isDataLoaded = true;
    });

    if (_userId != null) {
      await _loadProfileFromBackend();
      if (_role != 'psychologist') {
        await _loadMoodStats();
      }
    }
  }

  Future<void> _loadProfileFromBackend() async {
    if (_userId == null) return;

    try {
      final uri = Uri.parse("$apiBaseUrl/user/$_userId");
      final res = await http.get(uri);
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['ok'] != true || data['user'] is! Map<String, dynamic>) return;

      final user = data['user'] as Map<String, dynamic>;
      final name = (user['name'] ?? '').toString();
      final email = (user['email'] ?? '').toString();
      final avatar = (user['avatarBase64'] ?? '').toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      await prefs.setString('avatarBase64', avatar);

      if (!mounted) return;
      setState(() {
        _nameController.text = name;
        _emailController.text = email;
        _avatarBase64 = avatar;
      });
    } catch (_) {}
  }

  Future<void> _loadMoodStats() async {
    if (_userId == null) {
      setState(() {
        _moodStats = {};
        _moodComment = 'Көңіл-күй статистикасын көру үшін жүйеге кіріңіз.';
      });
      return;
    }

    setState(() {
      _statsLoading = true;
    });

    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    final uri = Uri.parse("$apiBaseUrl/mood/stats").replace(
      queryParameters: {
        "month": "$month",
        "year": "$year",
        "userId": _userId!,
      },
    );

    try {
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final Map<String, int> parsed = {};

        for (final item in data) {
          final id = item['_id']?.toString() ?? '';
          final countRaw = item['count'];
          final count = countRaw is int
              ? countRaw
              : int.tryParse(countRaw.toString()) ?? 0;
          if (id.isNotEmpty) {
            parsed[id] = count;
          }
        }

        if (!mounted) return;

        setState(() {
          _moodStats = parsed;
          _moodComment = _buildMoodComment(parsed);
        });
      } else {
        if (!mounted) return;
        setState(() {
          _moodStats = {};
          _moodComment = 'Статистиканы жүктеу кезінде қате орын алды.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _moodStats = {};
        _moodComment = 'Статистиканы жүктеу мүмкін болмады.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _statsLoading = false;
        });
      }
    }
  }

  String _buildMoodComment(Map<String, int> stats) {
    if (stats.isEmpty) {
      return '''📝 Көңіл-күйіңді күнделікті белгілеп отыру сенің эмоциялық жағдайыңды жақсы түсінуге көмектеседі.

Бүгінгі көңіл-күйіңді белгілеуден бастайық!''';
    }

    final total = stats.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return '''📝 Көңіл-күйіңді күнделікті белгілеп отыру сенің эмоциялық жағдайыңды жақсы түсінуге көмектеседі.

Бүгінгі көңіл-күйіңді белгілеуден бастайық!''';
    }

    const weights = {
      'very_happy': 2,
      'happy': 1,
      'neutral': 0,
      'sad': -1,
      'angry': -2,
    };

    double sum = 0;
    stats.forEach((mood, count) {
      final w = weights[mood] ?? 0;
      sum += w * count;
    });

    final avg = sum / total;

    if (avg >= 1.2) {
      return '''✨ КЕРЕМЕТ! Сенің көңіл-күйің өте жақсы! 

💡 Осы позитивті көңіл-күйді сақтау үшін:
• Күнделікті дене жаттығуларын жасауды жалғастыр
• Достарыңмен көбірек уақыт өткіз
• Өзіңді марапаттауды ұмытпа
• Басқаларға қолдау көрсет

🎯 Жарайсың, осылай жалғастыра бер!''';
    } else if (avg >= 0.5) {
      return '''😊 Жақсы! Көңіл-күйің жалпы тұрақты.

💡 Одан да жақсы болу үшін:
• Ұйқыңа назар аудар (8 сағат)
• Таза ауада серуендеуді көбірек жаса
• Сүйікті ісіңе уақыт бөл
• Медитация жаттығуларын қолдан

💪 Сен дұрыс жолдасың!''';
    } else if (avg >= -0.5) {
      return '''📊 Көңіл-күйің аралас, бұл қалыпты жағдай!

💡 Баланс табу үшін:
• Өз сезімдеріңді қабылда
• Күнделікті режимді ұстан
• Өзіңе мейірімді бол
• Демалысқа уақыт бөл

💚 Өзіңе қамқорлық жасау маңызды!''';
    } else if (avg >= -1.2) {
      return '''🫂 Эмоциялық тұрғыдан қиын кезең өтіп жатқан сияқтысың.

💡 Өзіңе көмектесу жолдары:
• Стрессті азайту техникаларын қолдан
• Күн тәртібін ұстануға тырыс
• Дұрыс тамақтан
• Табиғатта уақыт өткіз
• Сенетін адамыңмен сөйлес

🌱 Кішкене қадамдар үлкен өзгерістерге әкеледі!''';
    } else {
      return '''💙 Қиын кезең өтіп жатқан сияқтысың. Бұл уақытша!

🆘 Көмек алу жолдары:
• Психологпен кеңесуге барудан қорықпа
• Кураторың немесе досыңмен сөйлес
• Күнделікке ойларыңды жаз
• "Чат" бөлімінде AI көмекшімен сөйлес
• Өзіңе қуаныш сыйлайтын кішкене іс жаса

🤗 Есіңде болсын: көмек сұрау - күштілік белгісі! Сен жалғыз емессің!''';
    }
  }

  String get _moodStatsSubtitle {
    if (_userId == null) {
      return 'Көңіл-күй статистикасын көру үшін жүйеге кіріңіз.';
    }
    if (_statsLoading) {
      return 'Статистика жүктелуде...';
    }
    if (_moodStats.isEmpty) {
      return 'Бұл айда көңіл-күй жазбалары жоқ';
    }

    final total = _moodStats.values.fold<int>(0, (a, b) => a + b);
    final good = (_moodStats['very_happy'] ?? 0) + (_moodStats['happy'] ?? 0);
    final percentGood =
        total == 0 ? 0 : ((good / total) * 100).round().clamp(0, 100);

    return 'Жақсы күндер: $percentGood% · $_moodComment';
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _userId == null) {
      _showSnackBar("Барлық өрістерді тексеріңіз.", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse("$apiBaseUrl/user/$_userId");
    final body = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "avatarBase64": _avatarBase64,
    };

    if (_passwordController.text.isNotEmpty) {
      body["password"] = _passwordController.text;
      body["oldPassword"] = _oldPasswordController.text;
    }

    try {
      final res = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(res.body);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', responseData['user']['name'] ?? '');
        await prefs.setString('email', responseData['user']['email'] ?? '');
        await prefs.setString(
            'avatarBase64', responseData['user']['avatarBase64'] ?? '');

        _showSnackBar("Профиль сәтті жаңартылды!", isError: false);

        _passwordController.clear();
        _oldPasswordController.clear();
        _confirmPasswordController.clear();
        FocusScope.of(context).unfocus();
        setState(() {
          _avatarBase64 =
              (responseData['user']['avatarBase64'] ?? '').toString();
          _isPasswordSectionVisible = false;
          _isPasswordObscured = true;
          _isOldPasswordObscured = true;
          _isConfirmPasswordObscured = true;
        });
      } else {
        _showSnackBar(
          responseData['message'] ?? "Жаңарту мүмкін болмады",
          isError: true,
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar("Серверге қосылу қатесі.", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('avatarBase64');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showSnackBar("Фото оқылмады", isError: true);
      return;
    }

    final ext = (picked.extension ?? '').toLowerCase();
    final mime = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => 'image/png',
    };
    final base64Data = base64Encode(bytes);
    final dataUri = 'data:$mime;base64,$base64Data';

    if (!mounted) return;
    setState(() => _avatarBase64 = dataUri);
    _showSnackBar(
      "Фото таңдалды. Өзгерісті сақтау үшін жоғарыдағы құсбелгіні басыңыз.",
      isError: false,
    );
  }

  Uint8List? _avatarBytes() {
    if (_avatarBase64.isEmpty) return null;
    final parts = _avatarBase64.split(',');
    if (parts.length < 2) return null;
    try {
      return base64Decode(parts.last);
    } catch (_) {
      return null;
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        focusNode: focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _profileCard(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: kPrimaryColor),
        title: Text(title),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _updateProfile,
                ),
        ],
      ),
      body: !_isDataLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Builder(builder: (context) {
                        final avatarBytes = _avatarBytes();
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: avatarBytes != null
                              ? MemoryImage(avatarBytes)
                              : null,
                          child: avatarBytes == null
                              ? Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 58,
                                )
                              : null,
                        );
                      }),
                      Positioned(
                        right: -6,
                        bottom: -6,
                        child: IconButton.filledTonal(
                          onPressed: _pickAvatar,
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    _nameController.text.isEmpty
                        ? 'QORGA User'
                        : _nameController.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _emailController.text.isEmpty
                        ? 'mock@qorga.app'
                        : _emailController.text,
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 26),
                if (_role != 'psychologist') ...[
                  const Text(
                    'Есеп',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _profileCard(
                    Icons.mood,
                    'Көңіл-күй статистикасы',
                    _moodStatsSubtitle,
                    onTap: _userId == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StatsScreen(
                                  baseUrl: apiBaseUrl,
                                  userId: _userId!,
                                ),
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Қолданба',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _buildSettingSwitchTile(
                  icon: Icons.notifications_none,
                  title: 'Хабарландырулар',
                  subtitle: 'Маңызды еске салуларды алу',
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
                _buildSettingSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Қараңғы режим',
                  subtitle: 'Light / Dark тақырыбы',
                  value: ThemeController.isDark,
                  onChanged: ThemeController.setDarkMode,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Баптаулар',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 4, right: 4, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ListTile(
                          leading: Icon(Icons.edit, color: kPrimaryColor),
                          title: Text('Профильді өзгерту'),
                          subtitle: Text('Атың, email'),
                        ),
                        const Divider(height: 1),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: "Аты",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Атыңызды енгізіңіз";
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                controller: _emailController,
                                label: "Email",
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (!EmailValidator.isValid(value)) {
                                    return "Дұрыс email енгізіңіз";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline,
                            color: kPrimaryColor),
                        title: const Text('Қауіпсіздік'),
                        subtitle: const Text('Құпия сөзді өзгерту'),
                        trailing: Icon(_isPasswordSectionVisible
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onTap: () {
                          setState(() {
                            _isPasswordSectionVisible =
                                !_isPasswordSectionVisible;
                          });
                          if (_isPasswordSectionVisible) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _oldPasswordFocusNode.requestFocus();
                            });
                          }
                        },
                      ),
                      if (_isPasswordSectionVisible) const Divider(height: 1),
                      if (_isPasswordSectionVisible)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _oldPasswordController,
                                label: "Ескі құпия сөз",
                                obscureText: _isOldPasswordObscured,
                                focusNode: _oldPasswordFocusNode,
                                validator: (value) {
                                  if (_passwordController.text.isNotEmpty &&
                                      (value == null || value.isEmpty)) {
                                    return "Ескі құпия сөзді енгізіңіз";
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isOldPasswordObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isOldPasswordObscured =
                                          !_isOldPasswordObscured;
                                    });
                                  },
                                ),
                              ),
                              _buildTextField(
                                controller: _passwordController,
                                label: "Жаңа құпия сөз",
                                obscureText: _isPasswordObscured,
                                focusNode: _passwordFocusNode,
                                validator: (value) {
                                  if (_oldPasswordController.text.isNotEmpty) {
                                    return PasswordValidator.validate(
                                      value,
                                      emptyMessage:
                                          "Жаңа құпия сөзді енгізіңіз",
                                    );
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordObscured =
                                          !_isPasswordObscured;
                                    });
                                  },
                                ),
                              ),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: "Жаңа құпия сөзді растаңыз",
                                obscureText: _isConfirmPasswordObscured,
                                focusNode: _confirmPasswordFocusNode,
                                validator: (value) {
                                  if (_passwordController.text.isNotEmpty) {
                                    if (value == null || value.isEmpty) {
                                      return "Құпия сөзді растаңыз";
                                    }
                                    if (value != _passwordController.text) {
                                      return "Құпия сөздер сәйкес келмейді";
                                    }
                                  }
                                  return null;
                                },
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordObscured =
                                          !_isConfirmPasswordObscured;
                                    });
                                  },
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Text(
                                  PasswordValidator.requirementsShort,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                _profileCard(
                  Icons.logout,
                  'Шығу',
                  'Тіркелгіден шығу',
                  onTap: _logout,
                ),
              ],
            ),
    );
  }
}
