import 'package:flutter/material.dart';
import 'package:flutter_application/pages/secondary/edit_profile.dart';
import 'package:flutter_application/providers/trivia_provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/constants.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  final AuthService _authService = AuthService();
  late UserProvider userProvider;
  late TriviaProvider triviaProvider;
  final String packageVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    triviaProvider = Provider.of<TriviaProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final double drawerWidth;
    if (screenWidth < 700) {
      drawerWidth = screenWidth * 0.8;
    } else if (screenWidth < 850) {
      drawerWidth = screenWidth * 0.65;
    } else if (screenWidth < 1000) {
      drawerWidth = screenWidth * .6;
    } else {
      drawerWidth = screenWidth * .4;
    }
    return Container(
      color: const Color.fromARGB(255, 20, 20, 20),
      width: isTablet ? drawerWidth : screenWidth,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(context),
                    const SizedBox(height: 24),
                    _buildSettingsContent(context),
                    const SizedBox(height: 24),
                    _buildAccountSection(context),
                    if (userProvider.isDeveloper) ...[
                      const SizedBox(height: 24),
                      _buildDeveloperSection(context),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Profile'),
          const SizedBox(height: 8),
          CustomCard(
            icon: Icons.person_outline,
            text: 'Edit Profile',
            color: Colors.blue[200]!,
            onTap: () {
              Navigator.push(
                context,
                slideTransitionRoute(
                    const EditProfilePage()), // Use the custom slide transition
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quiz'),
          const SizedBox(height: 8),
          CustomCard(
            icon: Icons.refresh,
            text: 'Reset Encountered Questions',
            color: Colors.purple[200]!,
            onTap: _showResetConfirmation,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Account'),
          const SizedBox(height: 8),
          CustomCard(
            icon: Icons.logout,
            text: 'Sign Out',
            color: Colors.orange[300]!,
            onTap: _showSignOutConfirmation,
          ),
          const SizedBox(height: 8),
          CustomCard(
            icon: Icons.delete_forever_outlined,
            text: 'Delete Account',
            color: Colors.red[300]!,
            onTap: _showDeleteAccountConfirmation,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Developer Options'),
          const SizedBox(height: 8),
          CustomCard(
            icon: Icons.shuffle_rounded,
            text: 'Randomize Questions',
            color: const Color.fromARGB(255, 131, 255, 114),
            onTap: _showRandomizeQuestionsConfirmation,
          ),
          const SizedBox(height: 8),
          CustomCard(
            icon: Icons.refresh_outlined,
            text: 'Refresh Topics',
            color: Colors.lightBlueAccent,
            onTap: _showRefreshTopicsMetadataConfirmation,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/logos/app_foreground.png',
            height: 15,
            width: 15,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            'Synapse v$packageVersion',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
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
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Reset Questions',
        content:
            'Are you sure you want to reset all encountered questions? This action cannot be undone.',
        confirmationButtonText: 'Reset',
        cancelButtonText: 'Cancel',
        onPressed: () {
          triviaProvider.resetEncounteredQuestions();
          Navigator.pop(context);
        },
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

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteAccountDialog(
        onConfirm: () async {
          try {
            await _authService.deleteAccount(context);
          } catch (e) {
            if (mounted) {
              debugPrint('Error deleting account: ${e.toString()}');
            }
          }
        },
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
          debugPrint('Topics refreshed successfully');
        },
      ),
    );
  }
}
