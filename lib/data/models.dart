import 'dart:math';

import 'dart:ui';

class NotesModel {
  int id;
  String title;
  String content;
  bool isImportant;
  Color noteColor;
  DateTime date;

  NotesModel({this.id, this.title, this.content, this.isImportant, this.date,this.noteColor});

  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.title = map['title'];
    this.content = map['content'];
    this.date = DateTime.parse(map['date']);
    this.isImportant = map['isImportant'] == 1 ? true : false;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'title': this.title,
      'content': this.content,
      'isImportant': this.isImportant == true ? 1 : 0,
      'date': this.date.toIso8601String()
    };
  }

}
