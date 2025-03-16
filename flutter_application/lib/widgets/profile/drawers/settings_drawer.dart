import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
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
  final String packageVersion = '0.9.0';

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: const BoxDecoration(
        color: backgroundPageColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _buildSettingsContent(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Account'),
          const SizedBox(height: 16),
          CustomCard(
            icon: Icons.logout,
            text: 'Sign Out',
            color: warningRed,
            onTap: () => _showSignOutConfirmation(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            trailingIcon: Icons.arrow_forward_ios_rounded,
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Trivia Data'),
          const SizedBox(height: 16),
          CustomCard(
            icon: Icons.restore,
            text: 'Reset Encountered Questions',
            subtitle: "This will also reset your 'Total Solved Questions'",
            color: const Color.fromARGB(255, 255, 175, 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: _showResetEncounteredQuestionsConfirmation,
            trailingIcon: Icons.arrow_forward_ios_rounded,
          ),
          if (userProvider.isDeveloper) ...[
            const SizedBox(height: 32),
            _buildSectionTitle('Developer Options'),
            const SizedBox(height: 16),
            CustomCard(
              icon: Icons.shuffle_rounded,
              text: 'Randomize Questions',
              color: const Color.fromARGB(255, 131, 255, 114),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: _showRandomizeQuestionsConfirmation,
              trailingIcon: Icons.arrow_forward_ios_rounded,
            ),
            const SizedBox(height: 12),
            CustomCard(
              icon: Icons.refresh_outlined,
              text: 'Refresh Topics',
              color: Colors.lightBlueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onTap: _showRefreshTopicsMetadataConfirmation,
              trailingIcon: Icons.arrow_forward_ios_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logos/synapse_no_bg.png',
            height: 15,
            width: 15,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 6),
          Text(
            'Synapse v$packageVersion',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
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
