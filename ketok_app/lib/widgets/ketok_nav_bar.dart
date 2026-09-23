import 'package:flutter/material.dart';

import 'ketok_colors.dart';

class KetokNavItem {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;

  const KetokNavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
  });
}

class KetokNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<KetokNavItem> items;

  static const _defaultItems = [
    KetokNavItem(
      selectedIcon: Icons.home_rounded,
      unselectedIcon: Icons.home_outlined,
      label: 'Beranda',
    ),
    KetokNavItem(
      selectedIcon: Icons.assignment_rounded,
      unselectedIcon: Icons.assignment_outlined,
      label: 'Pesanan',
    ),
    KetokNavItem(
      selectedIcon: Icons.chat_bubble_rounded,
      unselectedIcon: Icons.chat_bubble_outline_rounded,
      label: 'Chat',
    ),
    KetokNavItem(
      selectedIcon: Icons.person_rounded,
      unselectedIcon: Icons.person_outline_rounded,
      label: 'Profil',
    ),
  ];

  const KetokNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = _defaultItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KetokColors.surface,
        border: Border(
          top: BorderSide(color: KetokColors.border.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _KetokNavItem(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KetokNavItem extends StatelessWidget {
  final KetokNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _KetokNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.unselectedIcon,
              color: isSelected ? KetokColors.primary : KetokColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? KetokColors.primary : KetokColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
