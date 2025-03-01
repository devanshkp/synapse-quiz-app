import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/profile/add_question_form.dart';
import 'package:provider/provider.dart';

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
    return Container(
      decoration: const BoxDecoration(color: drawerColor),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildSettingsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingsCard(
            icon: Icons.logout,
            text: 'Sign Out',
            color: Colors.red.withOpacity(0.8),
            onTap: () async => await _authService.signOut(context),
          ),
          const SizedBox(height: 12),
          _buildSettingsCard(
            icon: Icons.developer_mode,
            text: 'Developer Mode',
            color: Colors.green.withOpacity(0.8),
            onTap: _promptDeveloperMode,
          ),
          if (_isDeveloperMode) ...[
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.add,
              text: 'Add Question',
              color: Colors.blue.withOpacity(0.8),
              onTap: _showAddQuestionCard,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.shuffle_rounded,
              text: 'Randomize Questions',
              color: Colors.orangeAccent.withOpacity(0.8),
              onTap: Provider.of<TriviaProvider>(context, listen: false)
                  .addRandomFieldToQuestions,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              icon: Icons.refresh_rounded,
              text: 'Refresh Topics',
              color: Colors.green.withOpacity(0.8),
              onTap: () async {
                try {
                  await Provider.of<TriviaProvider>(context, listen: false)
                      .refreshTopicsMetadata();
                  if (mounted) {
                    floatingSnackBar(
                      message: 'Topics refreshed successfully',
                      context: context,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to refresh topics: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black45,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.085),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptDeveloperMode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Enter Developer Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: _devModeController,
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            style: const TextStyle(color: Colors.white),
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
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.blue),
              ),
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
              message: 'Question Added Successfully',
              context: context,
            );
          },
        );
      },
    );
  }
}
