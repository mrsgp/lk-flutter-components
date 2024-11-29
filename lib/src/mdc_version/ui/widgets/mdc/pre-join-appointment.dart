
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../mdc_lk_components.dart';

class PreJoinAppointment extends StatelessWidget {
    final String remoteParticipantName;
  final Function(RoomContext roomCtx)? onJoinPressed;
  const PreJoinAppointment({required this.remoteParticipantName, this.onJoinPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomContext>(
      builder: (context, roomCtx, child) => !roomCtx.connected &&
              !roomCtx.connecting
          ? Center(
              child: SizedBox(
                width: 480,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Connect with $remoteParticipantName'),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: CameraPreview(
                              builder: (context, videoTrack) =>
                                  CameraPreviewWidget(track: videoTrack),
                            ),
                          ),
                          SizedBox(
                            width: 360,
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    MicrophoneSelectButton(
                                      showLabels: true,
                                    ),
                                    CameraSelectButton(
                                      showLabels: true,
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(
                            width: 360,
                            height: 64,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: JoinButton(
                                builder: (context, roomCtx, connected) =>
                                    JoinButtonWidget(
                                  roomCtx: roomCtx,
                                  connected: connected,
                                  onPressed: () => onJoinPressed?.call(roomCtx),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(width: 0, height: 0),
    );
  }
}
