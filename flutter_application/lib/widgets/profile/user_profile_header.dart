import 'package:flutter/material.dart';
import 'package:flutter_application/pages/secondary/edit_profile.dart';
import 'package:flutter_application/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/user_provider.dart';
import 'package:flutter_application/constants.dart';

class UserProfileHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const UserProfileHeader({super.key, required this.scaffoldKey});

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
                        width: 1.5, color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: UserAvatar(
                        avatarUrl: userProfile.avatarUrl,
                        avatarRadius: 55,
                      )),
                ),

                // Edit button
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          slideTransitionRoute(const EditProfilePage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: appColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${userProfile.fullName} • ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                  child: RichText(
                      text: TextSpan(
                          style: const TextStyle(fontFamily: 'Poppins'),
                          children: [
                        TextSpan(
                            text: '$friendCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        TextSpan(
                            text: friendCount == 1 ? ' Friend' : ' Friends',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                letterSpacing: 0.4))
                      ])),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
