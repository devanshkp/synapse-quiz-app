import 'package:flutter/material.dart';
import 'package:flutter_application/models/user_profile.dart';
import 'package:flutter_application/services/friend_services.dart';
import 'package:flutter_application/widgets/shared.dart';

class UserProfileHeader extends StatelessWidget {
  final UserProfile userProfile;
  final FriendService _friendService = FriendService();

  UserProfileHeader({super.key, required this.userProfile});

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
              child: AvatarImage(
                  avatarUrl: userProfile.avatarUrl, avatarRadius: 55)),
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
        StreamBuilder<int>(
          stream: _friendService.getFriendCountStream(userProfile.userId),
          builder: (context, snapshot) {
            final friendCount = snapshot.data ?? 0;

            return RichText(
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
            );
          },
        ),
      ],
    );
  }
}
