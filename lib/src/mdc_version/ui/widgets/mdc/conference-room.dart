
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_components/mdc_lk_components.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'is-local-indicator.dart';

class ConferenceRoom extends StatefulWidget {
  final bool isChatView;
  final String providerName;
  final Function(bool) onDisconnectCallback;
  final Function()? onMessageReceivedCallback;
  //final Future<String> Function(MessageData)? onFileReadCallback;
  const ConferenceRoom(
      this.isChatView,
      this.providerName,
      this.onDisconnectCallback,
      this.onMessageReceivedCallback,
     // this.onFileReadCallback,
      {super.key});

  @override
  State<ConferenceRoom> createState() => _ConferenceRoomState();
}

class _ConferenceRoomState extends State<ConferenceRoom> {
  @override
  Widget build(BuildContext context) {
    var deviceScreenType = getDeviceType(MediaQuery.of(context).size);
    return Consumer<RoomContext>(
      builder: (context, roomCtx, child) {
        return deviceScreenType == DeviceScreenType.desktop
            ? _displayVideoLayoutForDesktopDevice(roomCtx, widget.providerName)
            : roomCtx.isChatEnabled
                ? Expanded(
                    child: ChatBuilder(
                      builder: (context, enabled, chatCtx, messages) {
                        return ChatWidget(
                          messages: messages,
                          onSend: (message) => chatCtx.sendMessage(message),
                          onClose: () {
                            chatCtx.toggleChat(false);
                          },
                        );
                      },
                    ),
                  )
                : _displayVideoLayoutForHandheldDevice(
                    roomCtx, widget.providerName);
      },
    );
  }

  Widget _displayVideoLayoutForHandheldDevice(
      RoomContext roomCtx, String providerName) {
    return ParticipantLoop(
      showAudioTracks: false,
      showVideoTracks: true,

      /// layout builder
      layoutBuilder: ConferenceRoomLayoutBuilder(roomCtx, providerName),

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
                      child: VideoTrackWidget()
                      /*
                    VideoTrackRenderer(
                      activeVideoTrack!,
                      fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )*/
                      ));
            } else {
              return const VideoTrackWidget();
            }
          },
        );

        //return const VideoTrackWidget();
        /*
        Padding(
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
              const ParticipantStatusBar(),
            ],
          ),
        );*/
      },
    );
  }

  Widget _displayVideoLayoutForDesktopDevice(
      RoomContext roomCtx, String providerName) {
    return ParticipantLoop(
      showAudioTracks: false,
      showVideoTracks: true,

      /// layout builder
      layoutBuilder: ConferenceRoomLayoutBuilder(roomCtx, providerName),

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

              /// TODO: Add AudioTrackWidget or AgentVisualizerWidget later

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
              const ParticipantStatusBar(),
            ],
          ),
        );
      },
    );
/*
    Column(
      children: [
        Row(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.only(right: 4.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(color: Colors.black12),
                  child: Row(
                    children: [
                      ControlsWidget(
                          widget.roomContext.room, widget.onDisconnectCallback),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.online_prediction_rounded,
                                color: Colors.green,
                              )),
                          Text('Dr or Patient Name Goes here'),
                        ],
                      ))
                    ],
                  ),
                )),
            const Expanded(flex: 2, child: Text('Messages')),
          ],
        ),
        Expanded(
            child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 4.0),
                      height: MediaQuery.of(context).size.height,
                      width: videoPlaceWidth,
                      decoration: const BoxDecoration(color: Colors.black26),
                      child: remoteParticipantTrack.participant != null
                          ? ParticipantWidget.widgetFor(remoteParticipantTrack,
                              showStatsLayer: false)
                          : const Center(
                              child: Text('Your call will start soon')),
                    ),
                    Positioned(
                        left: _xPosition,
                        top: _yPosition,
                        child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                var newX = _xPosition + details.delta.dx;
                                var newY = _yPosition + details.delta.dy;
                                if (newX > 0 &&
                                    newX < videoPlaceWidth * 2 / 5 - 200) {
                                  _xPosition = newX;
                                }
                                if (newY > 0 &&
                                    newY <
                                        MediaQuery.of(context).size.height -
                                            200) {
                                  _yPosition += details.delta.dy;
                                }
                              });
                            },
                            child: Column(
                              children: [
                                localParticipantTrack.participant != null
                                    ? SizedBox(
                                        width: 200.0,
                                        height: 200.0,
                                        child: ParticipantWidget.widgetFor(
                                            localParticipantTrack,
                                            showStatsLayer: false),
                                      )
                                    : Container(
                                        color: Colors.black12,
                                        width: 200.0,
                                        height: 200.0,
                                        child: const Column(
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
                            )))
                  ],
                )),
            Expanded(
                flex: 2,
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: null //ChatScreen(widget.livekit.room, _listener),
                    ))
          ],
        ))
      ],
    );*/
  }
}

//Mobile layout
class ConferenceRoomLayoutBuilder implements ParticipantLayoutBuilder {
  double _xPosition = 0;
  double _yPosition = 0;
  final RoomContext roomContext;
  final String providerName;
  ConferenceRoomLayoutBuilder(this.roomContext, this.providerName);

  Widget _connectingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
            radius: 64,
            backgroundColor: Colors.grey.shade100,
            foregroundImage:
                const NetworkImage("/images/img_placeholder_150x150.png")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            providerName,
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
                            ? remoteParticipant
                                .widget /*ParticipantWidget.widgetFor(
                                remoteParticipantTrack,
                                showStatsLayer: false)*/
                            : _connectingWidget()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ControlBar(
                        screenShare: false,
                      )
                      /*ControlsWidget(
                          widget.roomContext.room, widget.onDisconnectCallback)*/
                      ,
                    )
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
