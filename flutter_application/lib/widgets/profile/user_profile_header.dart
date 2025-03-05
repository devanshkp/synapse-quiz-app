import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/shared.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/colors.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userProfile = userProvider.userProfile;
        final friendCount = userProvider.friends.length;
        if (userProfile == null) {
          // Handle case when user profile is null (e.g., after logout)
          return const Center(child: Text("No user data available"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture with edit button
            Stack(
              children: [
                // Profile picture
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        width: 1.5, color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: UserAvatarImage(
                          avatarUrl: userProfile.avatarUrl, avatarRadius: 55)),
                ),

                // Edit button
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: appColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userProfile.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                text: '${userProfile.fullName} • ',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(
                    text: '$friendCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: friendCount == 1 ? ' Friend' : ' Friends',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
