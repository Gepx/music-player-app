import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:music_player/utils/constants/colors.dart';
import 'package:music_player/data/models/user_model.dart';
import 'package:music_player/features/profile/widget/share_button.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final displayName =
        user?.displayName ?? user?.email.split('@').first ?? 'User';
    final email = user?.email ?? 'No email';
    final photoUrl = user?.photoUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: photoUrl == null ? FColors.linearGradient : null,
              image:
                  photoUrl != null
                      ? DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                photoUrl == null
                    ? const Icon(
                      Iconsax.profile_circle,
                      size: 80,
                      color: FColors.textWhite,
                    )
                    : null,
          ),
          const SizedBox(height: 24),
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: FColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: FColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ShareButton(user: user),
        ],
      ),
    );
  }
}
