import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_components/mdc_lk_components.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ConferenceRoom extends StatefulWidget {
  final bool isChatView;
  final String remoteParticipantName;
  final void Function() onDisconnectCallback;
  final void Function()? onNameTapCallback;
  final Future<bool> Function(String, bool) onMessageSendCallback;
  final Future<bool> Function(String) onFileDownload;
  final Future<String> Function(XFile) onFileUpload;
  const ConferenceRoom(
      {required this.isChatView,
      required this.remoteParticipantName,
      required this.onDisconnectCallback,
      required this.onMessageSendCallback,
      required this.onFileUpload,
      required this.onFileDownload,
      this.onNameTapCallback,
      super.key});

  @override
  State<ConferenceRoom> createState() => _ConferenceRoomState();
}

class _ConferenceRoomState extends State<ConferenceRoom> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    return Consumer<RoomContext>(
      builder: (context, roomCtx, child) {
        return deviceScreenType == DeviceScreenType.desktop
            ? _displayVideoLayoutForDesktopDevice(
                roomCtx, widget.remoteParticipantName)
            : roomCtx.isChatEnabled
                ? ChatBuilder(
                    builder: (context, enabled, chatCtx, messages) {
                      return ChatWidget(
                        onFileDownload: widget.onFileDownload,
                        onFileUpload: widget.onFileUpload,
                        onRemove: (msg) {
                          chatCtx.removeMessage(msg);
                        },
                        messages: messages,
                        onSend: (message, hasFileId, msgId) async {
                          if (message is String) {
                            final result = await widget.onMessageSendCallback
                                .call(message, hasFileId);
                            if (result) {
                              chatCtx.sendMessage(message, hasFileId, msgId);
                            }
                          } else if (message is XFile) {
                            chatCtx.sendMessage(message, false, '');
                          }
                        },
                        onClose: () {
                          chatCtx.toggleChat(false);
                        },
                      );
                    },
                  )
                : _displayVideoLayoutForHandheldDevice(
                    roomCtx, widget.remoteParticipantName);
      },
    );
  }

  Widget _displayVideoLayoutForHandheldDevice(
      RoomContext roomCtx, String remoteParticipantName) {
    return ParticipantLoop(
      showAudioTracks: false,
      showVideoTracks: true,

      /// layout builder
      layoutBuilder: ConferenceRoomLayoutBuilder(
          roomCtx, remoteParticipantName, widget.onDisconnectCallback),

      /// participant builder
      participantBuilder: (context) {
        // build participant widget for each Track
        return IsLocalIndicator(
          builder: (context, isLocal) {
            if (isLocal) {
              return Container(
                  foregroundDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: 1 == 2 //is speaking
                        ? Border.all(
                            width: 2,
                            color: Colors.deepPurple,
                          )
                        : null,
                  ),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      clipBehavior: Clip.hardEdge,
                      child: VideoTrackWidget()));
            } else {
              return Stack(
                children: [
                  const VideoTrackWidget(),
                  Align(
                    alignment: Alignment.topRight,
                    child: ParticipantStatusBar(onNameTap: widget.onNameTapCallback,),
                  )
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _displayVideoLayoutForDesktopDevice(
      RoomContext roomCtx, String remoteParticipantName) {
    return ParticipantLoop(
      showAudioTracks: false,
      showVideoTracks: true,

      /// layout builder
      layoutBuilder: ConferenceRoomLayoutBuilder(
          roomCtx, remoteParticipantName, widget.onDisconnectCallback),

      /// participant builder
      participantBuilder: (context) {
        // build participant widget for each Track
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              /// video track widget in the background

              IsSpeakingIndicator(
                builder: (context, isSpeaking) {
                  return isSpeaking != null
                      ? IsSpeakingIndicatorWidget(
                          isSpeaking: isSpeaking,
                          child: const VideoTrackWidget(),
                        )
                      : const VideoTrackWidget();
                },
              ),

              /// focus toggle button at the top right
              const Positioned(
                top: 0,
                right: 0,
                child: FocusToggle(),
              ),

              /// track stats at the top left
              const Positioned(
                top: 8,
                left: 0,
                child: TrackStatsWidget(),
              ),

              /// status bar at the bottom
              ParticipantStatusBar(onNameTap: widget.onNameTapCallback,),
            ],
          ),
        );
      },
    );
  }
}

//Mobile layout
class ConferenceRoomLayoutBuilder implements ParticipantLayoutBuilder {
  double _xPosition = 0;
  double _yPosition = 0;
  final RoomContext roomContext;
  final String remoteParticipantName;
  final Function() onDisconnectCallback;
  ConferenceRoomLayoutBuilder(
      this.roomContext, this.remoteParticipantName, this.onDisconnectCallback);

  Widget _connectingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
            radius: 64,
            backgroundColor: Colors.grey.shade100,
            foregroundImage:
                const NetworkImage('/images/img_placeholder_150x150.png')),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            remoteParticipantName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          'Your call will start soon...',
          style: TextStyle(color: Colors.white, fontSize: 10),
        )
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
    List<TrackWidget> children,
    List<String> pinnedTracks,
  ) {
    double videoPlaceWidth = MediaQuery.of(context).size.width;
    double videoPlaceHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        kBottomNavigationBarHeight;

    final localParticipant = children.firstWhereOrNull(
        (p) => p.trackIdentifier.participant is LocalParticipant);
    final remoteParticipant = children.firstWhereOrNull(
        (p) => p.trackIdentifier.participant is RemoteParticipant);

    return Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: remoteParticipant != null
                            ? remoteParticipant.widget
                            : _connectingWidget()),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ControlBar(
                          screenShare: false,
                          onDisconnect: onDisconnectCallback,
                        ))
                  ]),
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Positioned(
                    left: _xPosition,
                    top: _yPosition,
                    child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            var newX = _xPosition + details.delta.dx;
                            var newY = _yPosition + details.delta.dy;
                            if (newX > 0 && newX < videoPlaceWidth - 100) {
                              _xPosition = newX;
                            }
                            if (newY > 0 && newY < videoPlaceHeight - 100) {
                              _yPosition += details.delta.dy;
                            }
                          });
                        },
                        child: Column(
                          children: [
                            localParticipant != null
                                ? SizedBox(
                                    width: 100.0,
                                    height: 100.0,
                                    child: localParticipant.widget)
                                : const SizedBox(
                                    //color: Colors.black12,
                                    width: 100.0,
                                    height: 100.0,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.videocam_off_rounded,
                                          color: Colors.white,
                                          size: 50.0,
                                        ),
                                      ],
                                    ),
                                  )
                          ],
                        )));
              },
            )
          ],
        ));
  }
}
