// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class SavedChatMessage extends Equatable {
  DateTime noteDateTime;
  String content;
  bool isFromPatient;
  String contentType;
  SavedChatMessage({
    required this.noteDateTime,
    required this.content,
    required this.isFromPatient,
    required this.contentType,
  });
  

  @override
  List<Object> get props => [noteDateTime, content, isFromPatient, contentType];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'noteDateTime': noteDateTime.millisecondsSinceEpoch,
      'content': content,
      'isFromPatient': isFromPatient,
      'contentType': contentType,
    };
  }

  factory SavedChatMessage.fromMap(Map<String, dynamic> map) {
    return SavedChatMessage(
      noteDateTime: DateTime.parse(map['noteDateTime']),
      content: map['content'] as String,
      isFromPatient: map['isFromPatient'] as bool,
      contentType: map['contentType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedChatMessage.fromJson(String source) => SavedChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
