import 'package:flutter/material.dart';
import 'ketok_colors.dart';

/// Model data untuk satu item di bottom navigation bar.
class KetokNavItem {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;
  final String? badge;

  const KetokNavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    this.badge,
  });
}

/// Bottom navigation bar standar Ketok Mitra.
///
/// Gunakan [currentIndex] untuk tab yang aktif dan [onTap] untuk
/// menangani perpindahan tab dari halaman induk.
///
/// Contoh pemakaian:
/// ```dart
/// KetokNavBar(
///   currentIndex: _tabIndex,
///   onTap: (i) => setState(() => _tabIndex = i),
/// )
/// ```
class KetokNavBar extends StatelessWidget {
  /// Indeks tab yang sedang aktif (0 = Beranda, 1 = Pesanan, 2 = Chat).
  final int currentIndex;

  /// Callback saat salah satu item ditekan, menerima indeks item.
  final ValueChanged<int> onTap;

  /// Daftar item navigasi. Default sudah disediakan (Beranda, Pesanan, Chat).
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
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: KetokColors.borderColor.withValues(alpha: 0.8),
          ),
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
              (i) => _NavItem(
                item: items[i],
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Item tunggal dalam [KetokNavBar].
class _NavItem extends StatelessWidget {
  final KetokNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.unselectedIcon,
                  color: isSelected
                      ? KetokColors.darkPrimary
                      : KetokColors.onSurfaceVariant,
                  size: 24,
                ),
                if (item.badge != null && item.badge!.isNotEmpty && item.badge != '0')
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? KetokColors.darkPrimary
                    : KetokColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
