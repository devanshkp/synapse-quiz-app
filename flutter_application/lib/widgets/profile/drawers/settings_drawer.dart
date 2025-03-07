import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
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
            onTap: () => _showSignOutConfirmation(),
          ),
          const SizedBox(height: 12),
          CustomCard(
            icon: Icons.restore,
            text: 'Reset Encountered Questions',
            color: const Color.fromARGB(255, 255, 175, 64).withOpacity(0.8),
            onTap: _showResetEncounteredQuestionsConfirmation,
          ),
          if (userProvider.isDeveloper) ...[
            const SizedBox(height: 12),
            CustomCard(
              icon: Icons.shuffle_rounded,
              text: 'Randomize Questions',
              color: const Color.fromARGB(255, 131, 255, 114).withOpacity(0.8),
              onTap: _showRandomizeQuestionsConfirmation,
            ),
            const SizedBox(height: 12),
            CustomCard(
              icon: Icons.refresh_outlined,
              text: 'Refresh Topics',
              color: Colors.lightBlueAccent.withOpacity(0.8),
              onTap: _showRefreshTopicsMetadataConfirmation,
            ),
          ],
        ],
      ),
    );
  }

  void _showRandomizeQuestionsConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Randomize Questions',
        content: 'Regenerate random fields for all questions?',
        confirmationButtonText: 'Confirm',
        cancelButtonText: 'Cancel',
        onPressed: () => triviaProvider.addRandomFieldToQuestions(),
      ),
    );
  }

  void _showResetEncounteredQuestionsConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Reset Encountered Questions',
        content:
            "Are you sure you want to reset your encountered questions?\n\nThis will also reset your 'Total Solved Questions' count.",
        confirmationButtonText: 'Reset',
        cancelButtonText: 'Cancel',
        onPressed: () => triviaProvider.resetEncounteredQuestions(),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Sign Out',
        content: 'Are you sure you want to sign out?',
        confirmationButtonText: 'Sign Out',
        cancelButtonText: 'Cancel',
        onPressed: () async => await _authService.signOut(context),
      ),
    );
  }

  void _showRefreshTopicsMetadataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Refresh Topics',
        content: 'Refresh topics metadata?',
        confirmationButtonText: 'Confirm',
        cancelButtonText: 'Cancel', 
        onPressed: () async {
          await triviaProvider.refreshTopicsMetadata();
          if (mounted) {
            floatingSnackBar(
              message: 'Topics refreshed successfully',
              context: context,
            );
          }
        },
      ),
    );
  }
}
