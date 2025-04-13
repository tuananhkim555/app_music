// ignore_for_file: deprecated_member_use

import 'package:app_music/pages/setting_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: theme.background,
      child: Column(
        children: [
          const SizedBox(height: 80),

          // Avatar with border + music icon
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Avatar with border
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[400],
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                bottom: -5,
                right: -1,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.inversePrimary,
                  child: Icon(
                    Icons.music_note,
                    size: 18,
                    color: theme.secondary, // ✅ đổi theo theme
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Username
          Text(
            'Anh Tuan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.inversePrimary,
            ),
          ),

          const SizedBox(height: 30),

          // Divider
          Divider(
            color: theme.inversePrimary.withOpacity(0.2),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          const SizedBox(height: 10),

          // Home
          _buildTile(
            context,
            icon: Icons.home,
            title: 'HOME',
            onTap: () => Navigator.pop(context),
          ),

          // Settings
          _buildTile(
            context,
            icon: Icons.settings,
            title: 'SETTINGS',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),

          // Logout
          _buildTile(
            context,
            icon: Icons.logout,
            title: 'LOGOUT',
            onTap: () => Navigator.pop(context),
          ),

          const Spacer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    final theme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: theme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: theme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
      ),
      horizontalTitleGap: 20,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
