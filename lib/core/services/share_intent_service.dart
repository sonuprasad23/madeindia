import 'package:flutter/services.dart';

/// Dart side of the native Android share-intent bridge in `MainActivity.kt`.
///
/// Lets a user share a URL from Chrome/WhatsApp/etc. into Rakshak, which
/// then opens the Link Checker with that URL pre-filled. No-op (streams
/// stay empty) on platforms other than Android.
class ShareIntentService {
  ShareIntentService()
    : _methodChannel = const MethodChannel('app.rakshak/share_intent'),
      _eventChannel = const EventChannel('app.rakshak/share_intent_stream');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Future<String?> consumeInitialSharedText() async {
    try {
      final result = await _methodChannel.invokeMethod<String>(
        'getInitialSharedText',
      );
      return result;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Stream<String> get sharedTextStream {
    try {
      return _eventChannel.receiveBroadcastStream().map(
        (event) => event as String,
      );
    } catch (_) {
      return const Stream.empty();
    }
  }
}
