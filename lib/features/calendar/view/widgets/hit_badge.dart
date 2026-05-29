import 'package:flutter/material.dart';

import '../../../../app/theme/semantic_colors.dart';
import '../../viewmodel/settlement_view_model.dart';

/// 軸二：命中徽章狀態（§2）。
///
/// 與軸一（市場方向 紅/綠）完全分離：命中金、miss/unsettled 灰，未來日不上色。
enum HitBadge { hit, miss, unsettled, none }

/// 結算狀態 + 是否過去日 → 徽章決策（純函式，TDD 主體）。
///
/// hit/miss 直接對應；unsettled 僅過去日顯示空心圈，未來日（含當日尚未結算）
/// 不上任何狀態色（§2「未來日不上色」）。
HitBadge hitBadgeOf(SettleStatus status, {required bool isPast}) {
  switch (status) {
    case SettleStatus.hit:
      return HitBadge.hit;
    case SettleStatus.miss:
      return HitBadge.miss;
    case SettleStatus.unsettled:
      return isPast ? HitBadge.unsettled : HitBadge.none;
  }
}

/// cell 右上角命中徽章：金底白✓ / 灰底白✗ / 淡灰空心圈 / [HitBadge.none] 不繪。
///
/// 對齊 Stitch _6：直徑 16dp 圓形。語意色讀 [SemanticColors] extension。
class HitBadgeMarker extends StatelessWidget {
  const HitBadgeMarker({required this.badge, super.key, this.size = 16});

  final HitBadge badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (badge == HitBadge.none) return const SizedBox.shrink();
    final sem = Theme.of(context).extension<SemanticColors>() ??
        SemanticColors.dark;

    if (badge == HitBadge.unsettled) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: sem.unsettled, width: 1.5),
        ),
      );
    }

    final bg = badge == HitBadge.hit ? sem.hit : sem.miss;
    final icon = badge == HitBadge.hit ? Icons.check : Icons.close;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.7, color: Colors.white),
    );
  }
}
