
import 'package:equatable/equatable.dart';
import 'package:livekit_client/livekit_client.dart';

class RTCOptions extends Equatable {
  final String url;
  final bool e2ee;
  final String? e2eeKey;
  final bool simulcast;
  final bool adaptiveStream;
  final bool dynacast;
  final String preferredCodec;
  final bool enableBackupVideoCodec;
  final VideoParameters selectedVideoParameters;
  const RTCOptions({
    required this.url,
    this.e2ee = false,
    this.e2eeKey,
    this.simulcast = true,
    this.adaptiveStream = true,
    this.dynacast = true,
    this.preferredCodec = 'VP8',
    this.enableBackupVideoCodec = true,
    this.selectedVideoParameters = VideoParametersPresets.h720_169,
  });

  RTCOptions copyWith({
    String? url,
    bool? e2ee,
    String? e2eeKey,
    bool? simulcast,
    bool? adaptiveStream,
    bool? dynacast,
    String? preferredCodec,
    bool? enableBackupVideoCodec,
    VideoParameters? selectedVideoParameters,
  }) {
    return RTCOptions(
      url: url ?? this.url,
      e2ee: e2ee ?? this.e2ee,
      e2eeKey: e2eeKey ?? this.e2eeKey,
      simulcast: simulcast ?? this.simulcast,
      adaptiveStream: adaptiveStream ?? this.adaptiveStream,
      dynacast: dynacast ?? this.dynacast,
      preferredCodec: preferredCodec ?? this.preferredCodec,
      enableBackupVideoCodec:
          enableBackupVideoCodec ?? this.enableBackupVideoCodec,
      selectedVideoParameters:
          selectedVideoParameters ?? this.selectedVideoParameters,
    );
  }

  @override
  List<Object?> get props => [
        url,
        e2ee,
        e2eeKey,
        simulcast,
        adaptiveStream,
        dynacast,
        preferredCodec,
        enableBackupVideoCodec,
        selectedVideoParameters,
      ];
}
