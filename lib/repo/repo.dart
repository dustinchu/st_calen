import '../common/model/company.dart';

class RepoData {
  static final Company bawp = new Company(
      name: '關於股市行事曆',
      about:
          '因前陣子的合一行事曆很有趣，所以開發了APP版本的行事曆產生器.\n'
          '如果有什麼建議 或是使用上的問題 請不要吝嗇給我反饋.\n',
      backdropPhoto: 'assets/calendar_1.jpg',
      courses: <Course>[
        new Course(
            title: '',
            thumbnail: '',
            url:
                ''),
      ],
      location: 'Stock Calendar',
      logo: 'assets/logo.png',
      president: 'Paulo Dichone');
}
