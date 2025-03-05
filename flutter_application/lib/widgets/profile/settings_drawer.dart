import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/colors.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:provider/provider.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  final AuthService _authService = AuthService();
  late UserProvider userProvider;
  late TriviaProvider triviaProvider;
  final TextEditingController _devModeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: backgroundPageColor),
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
          CustomCard(
            icon: Icons.logout,
            text: 'Sign Out',
            color: warningRed,
            onTap: () async => await _authService.signOut(context),
          ),
          if (!userProvider.isDeveloper) ...[
            const SizedBox(height: 12),
            CustomCard(
              icon: Icons.developer_mode,
              text: 'Developer Mode',
              color: Colors.green.withOpacity(0.8),
              onTap: _promptDeveloperMode,
            ),
          ],
          if (userProvider.isDeveloper) ...[
            const SizedBox(height: 12),
            CustomCard(
              icon: Icons.shuffle_rounded,
              text: 'Randomize Questions',
              color: Colors.orangeAccent.withOpacity(0.8),
              onTap: triviaProvider.addRandomFieldToQuestions,
            ),
            const SizedBox(height: 12),
            CustomCard(
              icon: Icons.refresh_rounded,
              text: 'Refresh Topics',
              color: Colors.lightBlueAccent.withOpacity(0.8),
              onTap: () async {
                try {
                  await triviaProvider.refreshTopicsMetadata();
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
                if (_devModeController.text == "devmode1567110808") {
                  setState(() => userProvider.isDeveloper = true);
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
}
