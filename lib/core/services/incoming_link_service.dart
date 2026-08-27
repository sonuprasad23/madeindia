import 'package:flutter/services.dart';

/// How an [IncomingLinkEvent] reached Rakshak.
enum IncomingLinkSource {
  /// The user tapped an http/https link in another app and selected (or
  /// had set as default) Rakshak as the handler — Android `ACTION_VIEW`.
  tappedLink,

  /// The user used Android's "Share" action to send a URL/text into
  /// Rakshak — Android `ACTION_SEND`.
  shared,
}

/// A URL (or shared text) Rakshak received from outside the app.
class IncomingLinkEvent {
  const IncomingLinkEvent({
    required this.url,
    required this.source,
    this.sourceAppLabel,
  });

  final String url;
  final IncomingLinkSource source;

  /// Best-effort friendly name of the app the link came from (e.g.
  /// "WhatsApp"), resolved natively from `Activity.getReferrer()`. Android
  /// does not guarantee this is present — null means unknown, never a
  /// security signal.
  final String? sourceAppLabel;

  factory IncomingLinkEvent.fromMap(Map<Object?, Object?> map) {
    return IncomingLinkEvent(
      url: map['url'] as String,
      source: (map['source'] as String?) == 'view'
          ? IncomingLinkSource.tappedLink
          : IncomingLinkSource.shared,
      sourceAppLabel: map['sourceApp'] as String?,
    );
  }
}

/// Dart side of the native Android incoming-link bridge in
/// `MainActivity.kt`. Covers both Android's "Share" intent and Android's
/// URL intent (`ACTION_VIEW`, used when Rakshak is chosen as an http/https
/// handler) — both surface here as the same [IncomingLinkEvent] shape.
///
/// No-op (streams stay empty) on platforms other than Android.
class IncomingLinkService {
  IncomingLinkService()
    : _methodChannel = const MethodChannel('app.rakshak/share_intent'),
      _eventChannel = const EventChannel('app.rakshak/share_intent_stream');

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Future<IncomingLinkEvent?> consumeInitialLink() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
        'getInitialSharedText',
      );
      if (result == null) return null;
      return IncomingLinkEvent.fromMap(result);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Stream<IncomingLinkEvent> get incomingLinkStream {
    try {
      return _eventChannel.receiveBroadcastStream().map(
        (event) => IncomingLinkEvent.fromMap(event as Map<Object?, Object?>),
      );
    } catch (_) {
      return const Stream.empty();
    }
  }
}
