import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../rutube_video.dart';

class VideoPlayerHandler {
  VideoPlayerHandler({
    required this.inAppWebViewController,
    required this.rutubeVideoController,
  }) {
    rutubeVideoController?.setMethods(
      onPause: pause,
      onPlay: play,
      onSeekTo: seekTo,
      onSeekLive: seekLive,
      onSetVolume: setVolume,
      triggerState: triggerState,
      // onMute: triggerIsMuted,
      // onUnMute: triggerIsMuted,
    );

    // Регистрируем обработчик сообщений от JavaScript
    inAppWebViewController?.addJavaScriptHandler(
      handlerName: 'rutubeMessageHandler',
      callback: (args) {
        final message = args[0] as Map<String, dynamic>;
        // log('Rutube message: $message');
        _handleRutubeMessage(message);
      },
    );
  }

  final InAppWebViewController? inAppWebViewController;
  final RutubeVideoController? rutubeVideoController;

  void _handleRutubeMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    final data = message['data'] as Map<String, dynamic>?;

    if (type == null) return;

    switch (type) {
      case 'player:playComplete':
        rutubeVideoController?.setPlayerState(PlayerStateEnum.ended);
        break;

      case 'player:currentTime':
        final time = data?['time'] as double?;
        if (time != null) {
          rutubeVideoController?.setCurrentTime(time.toInt());
          log('Current time: $time');
        }
        break;

      case 'player:durationChange':
        final duration = data?['duration'] as double?;
        if (duration != null) {
          rutubeVideoController?.setDuration(duration.toInt());
          // log('Duration: $duration');
        }
        break;

      case 'player:changeState':
        final state = data?['state'] as String?;
        if (state != null) {
          _handlePlayerStateChange(state);
        }
        break;

      case 'player:volumeChange':
        final volume = double.tryParse(data?['volume']);
        final isMuted = data?['isMuted'] as bool?;
        if (volume != null) {
          rutubeVideoController?.setVolume(volume);
        }
        if (isMuted != null) {
          rutubeVideoController?.setIsMuted(isMuted);
        }
        break;
    }
  }

  void _handlePlayerStateChange(String state) {
    PlayerStateEnum playerState;
    switch (state) {
      case 'playing':
        playerState = PlayerStateEnum.playing;
        break;
      case 'paused':
        playerState = PlayerStateEnum.paused;
        break;
      case 'ended':
        playerState = PlayerStateEnum.ended;
        break;
      case 'buffering':
        playerState = PlayerStateEnum.unidentified;
        break;
      default:
        playerState = PlayerStateEnum.uninited;
    }
    rutubeVideoController?.setPlayerState(playerState);
  }

  // Командные методы остаются без изменений
  void pause() {
    inAppWebViewController?.evaluateJavascript(source: "doCommand({type:'player:pause', data:{}});");
  }

  void play() {
    inAppWebViewController?.evaluateJavascript(source: "doCommand({type:'player:play', data:{}});");
  }

  void seekTo(Duration duration) {
    inAppWebViewController?.evaluateJavascript(
        source: "doCommand({type:'player:setCurrentTime', data:{time:${duration.inSeconds}}});");
  }

  /// Seeks to the live point in the video by calling the JavaScript method in the web view.
  void seekLive() {
    // inAppWebViewController?.evaluateJavascript(source: "player.seekLive()");
    throw UnimplementedError('seekLive() is not implemented yet.');
  }

  /// Sets the video volume by calling the JavaScript method in the web view.
  void setVolume(int volume) {
    inAppWebViewController?.evaluateJavascript(
        source: "doCommand( {type:'player:setVolume', data:{'volume':$volume} } );");
  }

  // /// Triggers and retrieves the current volume level from the web view.
  // void triggerVolume() async {
  //   // TODO: Implement logic to retrieve the current volume from the web view.
  //   // inAppWebViewController?.evaluateJavascript(
  //   rutubeVideoController?.setVolume(0.0); // Stub value
  // }

  // /// Triggers and retrieves the current playback time from the web view.
  // void triggerCurrentTime() async {
  //   // TODO: Implement logic to retrieve the current playback time from the web view.
  //   rutubeVideoController?.setCurrentTime(10); // Stub value
  // }

  // /// Triggers and retrieves the total duration of the video from the web view.
  // void triggerDuration() async {
  //   // TODO: Implement logic to retrieve the total duration of the video from the web view.
  //   rutubeVideoController?.setDuration(100); // Stub value
  // }

  // /// Triggers and retrieves the current video quality/resolution from the web view.
  // void triggerQuality() async {
  //   // TODO: Implement logic to retrieve the current video quality from the web view.
  //   rutubeVideoController?.setQuality(VideoResolutionEnum.p480); // Stub value
  // }

  // /// Triggers and retrieves whether the audio is muted from the web view.
  // void triggerIsMuted() async {
  //   // TODO: Implement logic to retrieve the muted state from the web view.
  //   rutubeVideoController?.setIsMuted(false); // Stub value
  // }

  /// Triggers and retrieves the current state of the player from the web view.
  void triggerState() async {}
}
