import 'package:flutter/material.dart';
import '../sysquest_theme.dart';
import 'pixel_icon.dart';

/// Barra de navegación inferior con estética pixel art de 16 bits.
/// Dispone de 3 pestañas principales: MAZMORRA, CÓDICE y PERFIL.
class RetroBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RetroBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_RetroNavItem> _items = [
    _RetroNavItem(
      label: 'MAZMORRA',
      spriteFile: 'doors_leaf_open.png',
    ),
    _RetroNavItem(
      label: 'CÓDICE',
      spriteFile: 'chest_full_open_anim_f0.png',
    ),
    _RetroNavItem(
      label: 'PERFIL',
      spriteFile: 'knight_m_idle_anim_f0.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: SysQuestColors.stonePanel,
        border: Border(
          top: BorderSide(
            color: SysQuestColors.borderBlack,
            width: 4,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Row(
        children: List.generate(_items.length, (index) {
          final isSelected = index == currentIndex;
          final item = _items[index];

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isSelected
                          ? SysQuestColors.gold
                          : SysQuestColors.stoneHighlight,
                      width: 3,
                    ),
                  ),
                  color: isSelected
                      ? SysQuestColors.dungeonVoid.withValues(alpha: 0.6)
                      : Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PixelIcon(
                      fileName: item.spriteFile,
                      size: 24,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.label,
                      style: SysQuestTypography.caption.copyWith(
                        fontSize: 8.5,
                        color: isSelected
                            ? SysQuestColors.gold
                            : SysQuestColors.disabledGray,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RetroNavItem {
  final String label;
  final String spriteFile;

  const _RetroNavItem({
    required this.label,
    required this.spriteFile,
  });
}

