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

import 'package:flutter/material.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme.dart';

class ChatToggleWidget extends StatelessWidget {
  ChatToggleWidget(
      {required this.isChatOpen,
      required this.toggleChat,
      this.showLabel = true,
      this.showNewMessageIndicator = false});

  final bool isChatOpen;
  final Function(bool enabled) toggleChat;
  final bool showLabel;
  final bool showNewMessageIndicator;

  @override
  Widget build(BuildContext context) {
    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
            isChatOpen ? LKColors.lkBlue : Colors.grey.withOpacity(0.9)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        overlayColor: WidgetStateProperty.all(
            isChatOpen ? LKColors.lkLightBlue : Colors.grey),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
        ),
        padding: WidgetStateProperty.all(
          deviceScreenType == DeviceScreenType.desktop || lkPlatformIsDesktop()
              ? const EdgeInsets.fromLTRB(10, 20, 10, 20)
              : const EdgeInsets.all(12),
        ),
      ),
      onPressed: () => toggleChat(!isChatOpen),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(Icons.chat),
              showNewMessageIndicator
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Container(),
                    )
                  : Container(),
            ],
          ),
          const SizedBox(width: 2),
          if (deviceScreenType != DeviceScreenType.mobile || showLabel)
            const Text(
              'Chat',
              style: TextStyle(fontSize: 14),
            ),
        ],
      ),
    );
  }
}
