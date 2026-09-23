import 'package:flutter/material.dart';

import 'ketok_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    final initial = trimmedName.isEmpty ? 'K' : trimmedName[0].toUpperCase();
    final url = photoUrl?.trim();
    final hasPhoto = url != null && url.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: KetokColors.surfaceLow,
      backgroundImage: hasPhoto ? NetworkImage(url) : null,
      onBackgroundImageError: hasPhoto ? (_, _) {} : null,
      child: hasPhoto
          ? null
          : Text(
              initial,
              style: TextStyle(
                color: KetokColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.7,
              ),
            ),
    );
  }
}
