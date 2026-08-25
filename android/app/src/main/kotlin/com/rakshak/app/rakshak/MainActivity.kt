package com.rakshak.app.rakshak

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges Android's "Share" intent (e.g. sharing a URL from Chrome or
 * WhatsApp) into Flutter, so Rakshak's Link Checker can pick it up.
 *
 * Deliberately hand-rolled with a MethodChannel + EventChannel instead of
 * a third-party plugin: this is the entire integration surface Rakshak
 * needs from native Android for share handling.
 */
class MainActivity : FlutterActivity() {
    private val methodChannelName = "app.rakshak/share_intent"
    private val eventChannelName = "app.rakshak/share_intent_stream"

    private var pendingSharedText: String? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        pendingSharedText = extractSharedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val text = extractSharedText(intent)
        if (text != null) {
            eventSink?.success(text)
            pendingSharedText = text
        }
    }

    private fun extractSharedText(intent: Intent?): String? {
        if (intent == null) return null
        if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            return intent.getStringExtra(Intent.EXTRA_TEXT)
        }
        return null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSharedText" -> {
                    result.success(pendingSharedText)
                    pendingSharedText = null
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                    eventSink = sink
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            },
        )
    }
}
