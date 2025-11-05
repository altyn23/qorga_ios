import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Жедел көмек'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Егер сізге немесе жақындарыңызға шұғыл көмек қажет болса, осы нөмірлерге хабарласыңыз.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Шұғыл қызметтер'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildPhoneTile(
                  context,
                  icon: Icons.local_fire_department,
                  title: 'Өрт сөндіру қызметі',
                  number: '101',
                  color: Colors.red,
                ),
                _buildPhoneTile(
                  context,
                  icon: Icons.local_police,
                  title: 'Полиция',
                  number: '102',
                  color: Colors.blue,
                ),
                _buildPhoneTile(
                  context,
                  icon: Icons.medical_services,
                  title: 'Жедел жәрдем',
                  number: '103',
                  color: Colors.green,
                ),
                _buildPhoneTile(
                  context,
                  icon: Icons.crisis_alert,
                  title: 'Бірыңғай құтқару қызметі',
                  number: '112',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Сенім телефондары (Психологиялық көмек)'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildPhoneTile(
                  context,
                  icon: Icons.family_restroom_rounded,
                  title:
                      'Отбасы, әйелдер және балалар мәселелері жөніндегі қызмет',
                  number: '111',
                  color: Colors.purple,
                ),
                _buildPhoneTile(
                  context,
                  icon: Icons.child_friendly,
                  title: 'Балалар мен жастарға арналған ұлттық сенім телефоны',
                  number: '150',
                  color: Colors.teal,
                ),
                _buildPhoneTile(
                  context,
                  icon: Icons.psychology,
                  title: 'Сенім телефоны (Психологиялық көмек)',
                  number: '116111',
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPhoneTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String number,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        number,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
