import 'package:flutter/material.dart';

/// One item in a [FloatingNavBar].
class NavBarItem {
  final IconData icon;
  final String label;

  const NavBarItem({required this.icon, required this.label});
}

/// Dark, pill-shaped bottom navigation bar.
///
/// Inactive tabs render an icon only. The active tab expands into a
/// purple icon + label pill, animated via [AnimatedSize].
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  // Visual tokens — kept here so the look stays consistent.
  static const Color _barColor = Color(0xFF00897B);
  static const Color _activeColor = Colors.white; // Colors.deepPurpleAccent; --- IGNORE ---
  static const Color _iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Container(
          decoration: BoxDecoration(
            color: _barColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              return _NavItemTile(
                item: items[i],
                active: i == currentIndex,
                activeColor: Colors.white, // _activeColor, --- IGNORE ---
                iconColor: (i == currentIndex) ? Colors.teal.shade600 : Colors.white, // _iconColor, --- IGNORE ---
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  final NavBarItem item;
  final bool active;
  final Color activeColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _NavItemTile({
    required this.item,
    required this.active,
    required this.activeColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: iconColor, size: 22),
            // AnimatedSize collapses the label to width 0 when inactive,
            // so tapping a tab smoothly grows the pill.
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: active
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
