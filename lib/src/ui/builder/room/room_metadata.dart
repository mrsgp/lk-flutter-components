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

import 'package:provider/provider.dart';

import '../../../context/participant_context.dart';
import '../../../context/room_context.dart';
import '../../../debug/logger.dart';

class RoomMetadata extends StatelessWidget {
  const RoomMetadata({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, String? metadata) builder;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(builder: (context, roomCtx, child) {
      Debug.log('====>        RoomMetadata for ${roomCtx.roomMetadata}');
      return Selector<ParticipantContext, String?>(
        selector: (context, metadata) => roomCtx.roomMetadata,
        builder: (context, metadata, child) {
          return builder(context, metadata);
        },
      );
    });
  }
}
