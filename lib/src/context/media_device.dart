import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_components/livekit_components.dart';

class MediaDevicesContext extends ChangeNotifier {
  MediaDevicesContext({required this.roomContext})
      : _audioInputs = [],
        _audioOutputs = [],
        _videoInputs = [] {
    _subscription = Hardware.instance.onDeviceChange.stream
        .listen((List<MediaDevice> devices) {
      _loadDevices(devices);
    });
    Hardware.instance.enumerateDevices().then(_loadDevices);
  }

  RoomContext roomContext;

  CameraPosition position = CameraPosition.front;

  List<MediaDevice>? _audioInputs;
  List<MediaDevice>? _audioOutputs;
  List<MediaDevice>? _videoInputs;
  StreamSubscription? _subscription;

  List<MediaDevice>? get audioInputs => _audioInputs;

  List<MediaDevice>? get audioOutputs => _audioOutputs;

  List<MediaDevice>? get videoInputs => _videoInputs;

  String? selectedVideoInputDeviceId;

  String? selectedAudioInputDeviceId;

  @override
  void dispose() {
    _subscription?.cancel();
  }

  void _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _audioOutputs = devices.where((d) => d.kind == 'audiooutput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    selectedAudioInputDeviceId ??= _audioInputs?.first.deviceId;
    selectedVideoInputDeviceId ??= _videoInputs?.first.deviceId;

    notifyListeners();
  }

  LocalVideoTrack? _localVideoTrack;

  LocalVideoTrack? get localVideoTrack => _localVideoTrack;

  bool get cameraOpened => _localVideoTrack != null;

  Future<void> setLocalVideoTrack(bool enabled) async {
    if (enabled) {
      _localVideoTrack ??= await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: position,
          deviceId: selectedVideoInputDeviceId,
        ),
      );
    } else {
      await _localVideoTrack?.stop();
      await _localVideoTrack?.dispose();
      _localVideoTrack = null;
    }
    notifyListeners();
  }

  LocalAudioTrack? _localAudioTrack;

  LocalAudioTrack? get localAudioTrack => _localAudioTrack;

  bool get microphoneOpened => _localAudioTrack != null;

  Future<void> setLocalAudioTrack(bool enabled) async {
    if (enabled) {
      _localAudioTrack ??= await LocalAudioTrack.create(
        AudioCaptureOptions(
          deviceId: selectedAudioInputDeviceId,
        ),
      );
    } else {
      await _localAudioTrack?.dispose();
      _localAudioTrack = null;
    }
    notifyListeners();
  }

  void selectAudioInput(MediaDevice device) async {
    selectedAudioInputDeviceId = device.deviceId;
    if (roomContext.connected) {
      await Hardware.instance.selectAudioInput(device);
    } else {
      await _localAudioTrack?.dispose();
      notifyListeners();
      _localAudioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(
          deviceId: device.deviceId,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> selectVideoInput(MediaDevice device) async {
    selectedVideoInputDeviceId = device.deviceId;
    if (roomContext.connected) {
      await _localVideoTrack?.switchCamera(device.deviceId);
    } else {
      await _localVideoTrack?.dispose();
      notifyListeners();
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(
          cameraPosition: position,
          deviceId: device.deviceId,
        ),
      );
    }
    notifyListeners();
  }
}
