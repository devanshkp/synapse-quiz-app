import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';

class UserProfileHeader extends StatelessWidget {
  final UserProfile userProfile;

  const UserProfileHeader({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border:
                Border.all(width: 1.5, color: Colors.white.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: userProfile.profilePicture.isNotEmpty
                      ? NetworkImage(userProfile.profilePicture)
                      : const AssetImage('assets/images/avatar.jpg')
                          as ImageProvider,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userProfile.username,
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
                text: '${userProfile.friends.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const TextSpan(
                text: ' Friends',
                style: TextStyle(
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
  }
}
