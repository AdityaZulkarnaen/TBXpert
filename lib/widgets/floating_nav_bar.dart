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
  static const Color _barColor = Colors.white;
  static const Color _activeColor = Color(0xFF1a434e); // Colors.deepPurpleAccent; --- IGNORE ---
  static const Color _iconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _barColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(8, 16, 8, 8 + bottomInset),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (i) {
          return _NavItemTile(
            item: items[i],
            active: i == currentIndex,
            activeColor: Color(0xFF1a434e), // _activeColor, --- IGNORE ---
            iconColor: (i == currentIndex) ?  Colors.white : Color(0xFF1a434e), // _iconColor, --- IGNORE ---
            onTap: () => onTap(i),
          );
        }),
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
            Icon(item.icon, color: iconColor, size: 26),
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
                            fontSize: 16,
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
