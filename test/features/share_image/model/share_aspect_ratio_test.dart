import 'package:flutter_test/flutter_test.dart';
import 'package:stock_calendar/features/share_image/model/share_aspect_ratio.dart';

void main() {
  group('ShareAspectRatio', () {
    test('story916 = 1080x1920 (9:16)', () {
      expect(ShareAspectRatio.story916.width, 1080);
      expect(ShareAspectRatio.story916.height, 1920);
      expect(ShareAspectRatio.story916.width / ShareAspectRatio.story916.height,
          closeTo(9 / 16, 1e-9));
    });

    test('square11 = 1080x1080 (1:1)', () {
      expect(ShareAspectRatio.square11.width, 1080);
      expect(ShareAspectRatio.square11.height, 1080);
      expect(ShareAspectRatio.square11.width / ShareAspectRatio.square11.height,
          1.0);
    });

    test('portrait45 = 1080x1350 (4:5)', () {
      expect(ShareAspectRatio.portrait45.width, 1080);
      expect(ShareAspectRatio.portrait45.height, 1350);
      expect(
          ShareAspectRatio.portrait45.width /
              ShareAspectRatio.portrait45.height,
          closeTo(4 / 5, 1e-9));
    });
  });
}
