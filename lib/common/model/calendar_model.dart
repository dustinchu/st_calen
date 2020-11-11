class CalendarModel {
/*
{
  "frame": "#dce1e7",
  "calendar_background": "#ebebf0",
  "weekend": "#1565C0",
  "click_today": "#dce1eb",
  "click_today_text": "#000000",
  "title_text": "#1565C0",
  "weekend_row": "#FFFFFF",
  "header_text": "#000000",
  "weekday_text": "#000000",
  "border_line": "#73000000"
} 
*/

  String frame;
  String calendar_background;
  String weekend;
  String click_today;
  String click_today_text;
  String title_text;
  String weekend_row;
  String header_text;
  String weekday_text;
  String border_line;

  CalendarModel({
    this.frame,
    this.calendar_background,
    this.weekend,
    this.click_today,
    this.click_today_text,
    this.title_text,
    this.weekend_row,
    this.header_text,
    this.weekday_text,
    this.border_line,
  });
  CalendarModel.fromJson(Map<String, dynamic> json) {
    frame = json["frame"]?.toString();
    calendar_background = json["calendar_background"]?.toString();
    weekend = json["weekend"]?.toString();
    click_today = json["click_today"]?.toString();
    click_today_text = json["click_today_text"]?.toString();
    title_text = json["title_text"]?.toString();
    weekend_row = json["weekend_row"]?.toString();
    header_text = json["header_text"]?.toString();
    weekday_text = json["weekday_text"]?.toString();
    border_line = json["border_line"]?.toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["frame"] = frame;
    data["calendar_background"] = calendar_background;
    data["weekend"] = weekend;
    data["click_today"] = click_today;
    data["click_today_text"] = click_today_text;
    data["title_text"] = title_text;
    data["weekend_row"] = weekend_row;
    data["header_text"] = header_text;
    data["weekday_text"] = weekday_text;
    data["border_line"] = border_line;
    return data;
  }

  @override
  String toString() {
    return '"CalendarModel" : { "frame": $frame, "calendar_background": $calendar_background,"weekend": $weekend,"click_today":$click_today,"click_today_text":$click_today_text,"title_text":$title_text,"weekend_row":$weekend_row,"header_text",$header_text,"weekday_text":$weekday_text,"border_line":$border_line},';
  }
  
}
