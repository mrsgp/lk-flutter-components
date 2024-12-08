// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright 2024 LiveKit, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../debug/logger.dart';

// topic: lk-chat-topic
class ChatMessage {
  final dynamic message; //String | XFile
  final int timestamp;
  final String id;
  final bool sender;
  final bool hasFileId;
  final bool alreadyDownloaded;
  final bool alreadyUploaded;

  final Participant? participant;

  ChatMessage(
      {required this.message,
      required this.timestamp,
      required this.hasFileId,
      required this.id,
      required this.participant,
      required this.sender,
      required this.alreadyDownloaded,
      required this.alreadyUploaded});

  Map<String, dynamic> toMap() {
    return {
      'message': message as String,
      'timestamp': timestamp,
      'id': id,
      'hasFileId': hasFileId
    };
  }

  String toJson() => const JsonEncoder().convert(toMap());

  factory ChatMessage.fromJsonString(String source, Participant? participant) =>
      ChatMessage.fromMap(const JsonDecoder().convert(source), participant);

  factory ChatMessage.fromMap(
      Map<String, dynamic> map, Participant? participant) {
    return ChatMessage(
        message: map['message'],
        timestamp: map['timestamp'],
        id: map['id'],
        hasFileId: map['hasFileId'],
        participant: participant,
        sender: false,
        alreadyDownloaded: false,
        alreadyUploaded: true);
  }
  

  ChatMessage copyWith({
    dynamic message,
    int? timestamp,
    String? id,
    bool? sender,
    bool? hasFileId,
    bool? alreadyDownloaded,
    bool? alreadyUploaded,
    Participant? participant,
  }) {
    return ChatMessage(
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      hasFileId:  hasFileId ?? this.hasFileId,
      id: id ?? this.id,
      participant: participant ?? this.participant,
      sender: sender ?? this.sender,
      alreadyDownloaded: alreadyDownloaded ?? this.alreadyDownloaded,
     alreadyUploaded: alreadyUploaded ?? this.alreadyUploaded
   
    );
  }
}

mixin ChatContextMixin on ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  LocalParticipant? _localParticipant;
  EventsListener<RoomEvent>? _listener;
  bool showNewMessageIndicator = false;
  void chatContextSetup(
      EventsListener<RoomEvent>? listener, LocalParticipant? localParticipant) {
    _listener = listener;
    _localParticipant = localParticipant;
    if (listener != null) {
      _listener!.on<DataReceivedEvent>((event) {
        Debug.event('ChatContext: DataReceivedEvent');

        if (event.topic == 'lk-chat-topic') {
          if (!showNewMessageIndicator && !_chatEnabled) {
            showNewMessageIndicator = true;
          }
          addMessageFromMap(
              const Utf8Decoder().convert(event.data), event.participant);
        }
      });
    } else {
      _listener = null;
      _messages.clear();
    }
  }

  void sendMessage(dynamic message, bool hasFileId, String fileMessageId) {
    final msg = ChatMessage(
        message: message,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: true,
        hasFileId: hasFileId,
        participant: _localParticipant,
        alreadyDownloaded: false,
        alreadyUploaded: hasFileId);
    if (!hasFileId) {
      addMessage(msg);
    } else if (fileMessageId.isNotEmpty) {
      int fileMsgIndex = _messages.indexWhere((m) => m.id == fileMessageId);
          _messages[fileMsgIndex] = _messages[fileMsgIndex].copyWith(alreadyUploaded: true);
    }

    if (message is String) {
      _localParticipant?.publishData(const Utf8Encoder().convert(msg.toJson()),
          topic: 'lk-chat-topic');
    }
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void removeMessage(ChatMessage message) {
    _messages.remove(message);
    notifyListeners();
  }

  void addMessageFromMap(String buf, Participant? participant) {
    final message = ChatMessage.fromJsonString(buf, participant);
    addMessage(message);
  }

  bool _chatEnabled = false;
  bool get isChatEnabled => _chatEnabled;

  void toggleChat(bool enabled) {
    _chatEnabled = enabled;
    showNewMessageIndicator = false;
    notifyListeners();
  }
}
