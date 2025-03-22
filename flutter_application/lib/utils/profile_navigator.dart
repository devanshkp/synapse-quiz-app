import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/models/friend.dart';
import 'package:flutter_application/pages/secondary/other_profile.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileNavigator {
  /// Navigates to a friend's profile with a smooth transition (by preloading data).
  static Future<void> navigateToProfile({
    required BuildContext context,
    required Friend friend,
  }) async {
    try {
      // Fetch the profile data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profile = await userProvider.getUserProfileById(friend.userId);

      // Navigate to the profile page with the preloaded data
      if (context.mounted) {
        Navigator.push(
          context,
          slideTransitionRoute(
            OtherProfilePage(
              friend: friend,
              preloadedProfile: profile, // Pass the preloaded profile
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        floatingSnackBar(
          context: context,
          message: 'Error loading profile: $e',
        );
      }
    }
  }
}
