import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Біз туралы'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qorga App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Бұл жоба – Қазақстандағы жасөспірімдерге кеңес беру және психологиялық қолдау көрсету мақсатында Astana IT College студенттерімен жасалған.',
                    style: TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Авторлар'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildProfileTile(
                  name: 'Серікқызы Алуа',
                  description: 'Astana IT College студенті',
                  phone: '+7 747 226 9006',
                  icon: Icons.person_outline_rounded,
                  color: Colors.blueAccent,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(height: 1),
                ),
                _buildProfileTile(
                  name: 'Қабыкен Алтынай',
                  description: 'Astana IT College студенті',
                  phone: '+7 775 845 4322',
                  icon: Icons.person_outline_rounded,
                  color: Colors.purpleAccent,
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

  Widget _buildProfileTile({
    required String name,
    required String description,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
      ),
      subtitle: Text(
        '$description\n$phone',
        style: const TextStyle(color: Colors.black54, height: 1.4),
      ),
      isThreeLine: true,
    );
  }
}
