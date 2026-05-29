/// 分享圖三種版型。enum 順序即 SharePreviewScreen SegmentedButton 顯示順序。
enum ShareTemplate {
  fullCalendar('整月行事曆'),
  singleDay('單日預測'),
  reportCard('月度報告');

  const ShareTemplate(this.displayName);

  final String displayName;
}
