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
    final initial = name.trim().isEmpty ? 'M' : name.trim()[0].toUpperCase();
    final url = photoUrl?.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: KetokColors.surfaceLow,
      backgroundImage: url == null || url.isEmpty ? null : NetworkImage(url),
      onBackgroundImageError: url == null || url.isEmpty ? null : (_, _) {},
      child: url == null || url.isEmpty
          ? Text(
              initial,
              style: TextStyle(
                color: KetokColors.darkPrimary,
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.7,
              ),
            )
          : null,
    );
  }
}
