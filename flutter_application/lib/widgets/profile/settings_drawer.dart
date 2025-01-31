import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/profile/add_question_form.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  final AuthService _authService = AuthService();
  bool _isDeveloperMode = false;
  final TextEditingController _devModeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsItem(
            icon: Icons.logout,
            text: 'Sign Out',
            color: Colors.red,
            onTap: () async => await _authService.signOut(context),
          ),
          _buildSettingsItem(
            icon: Icons.developer_mode,
            text: 'Developer Mode',
            color: Colors.green,
            onTap: _promptDeveloperMode,
          ),
          if (_isDeveloperMode)
            _buildSettingsItem(
              icon: Icons.add,
              text: 'Add Question',
              color: Colors.blue,
              onTap: _showAddQuestionCard,
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _promptDeveloperMode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Developer Password'),
          content: TextField(
            controller: _devModeController,
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_devModeController.text == "devmode") {
                  setState(() => _isDeveloperMode = true);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showAddQuestionCard() {
    showDialog(
      context: context,
      builder: (context) {
        return AddQuestionForm(
          onQuestionAdded: () {
            floatingSnackBar(
                message: 'Question Added Successfully', context: context);
          },
        );
      },
    );
  }
}
