package com.rakshak.app.rakshak

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges two things Rakshak needs from native Android into Flutter:
 *
 * 1. Incoming links/text — Android's "Share" intent (ACTION_SEND, e.g.
 *    sharing a URL from Chrome/WhatsApp) AND Android's URL intent
 *    (ACTION_VIEW, e.g. tapping an http/https link in another app when
 *    Rakshak is chosen as the handler). Both are surfaced to Flutter as
 *    the same "incoming link" event shape so the Link Security Gateway
 *    can treat them uniformly.
 * 2. System actions Flutter cannot do on its own: launching a URL in some
 *    OTHER app while deliberately excluding Rakshak itself from the
 *    chooser (so choosing "Open Directly"/"Open in Default Browser"
 *    never routes back into Rakshak and re-shows the gateway — the
 *    "intent loop" this feature must avoid), and deep-linking into the
 *    Android Settings screen where a user can set Rakshak as their
 *    preferred link handler.
 *
 * Deliberately hand-rolled with MethodChannel/EventChannel instead of a
 * third-party plugin: this is the entire integration surface Rakshak
 * needs from native Android for these two features.
 */
class MainActivity : FlutterActivity() {
    private val incomingLinkMethodChannel = "app.rakshak/share_intent"
    private val incomingLinkEventChannel = "app.rakshak/share_intent_stream"
    private val systemActionsChannel = "app.rakshak/system"

    private var pendingIncomingLink: Map<String, Any?>? = null
    private var incomingLinkSink: EventChannel.EventSink? = null

    /** Friendly display names for well-known apps, resolved best-effort
     * from [Activity.getReferrer]. Android does not guarantee a referrer
     * is present for ACTION_VIEW intents, so this is informational only —
     * never relied on for any security decision. */
    private val knownAppLabels = mapOf(
        "com.whatsapp" to "WhatsApp",
        "com.whatsapp.w4b" to "WhatsApp Business",
        "org.telegram.messenger" to "Telegram",
        "com.google.android.gm" to "Gmail",
        "com.facebook.katana" to "Facebook",
        "com.facebook.orca" to "Messenger",
        "com.instagram.android" to "Instagram",
        "com.google.android.apps.messaging" to "Messages",
        "com.android.mms" to "Messages",
        "com.twitter.android" to "X (Twitter)",
        "com.android.chrome" to "Chrome",
        "com.microsoft.office.outlook" to "Outlook",
        "com.linkedin.android" to "LinkedIn",
    )

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        pendingIncomingLink = extractIncomingLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val link = extractIncomingLink(intent)
        if (link != null) {
            incomingLinkSink?.success(link)
            pendingIncomingLink = link
        }
    }

    private fun extractIncomingLink(intent: Intent?): Map<String, Any?>? {
        if (intent == null) return null

        val sourceAppLabel = resolveSourceAppLabel()

        if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            val text = intent.getStringExtra(Intent.EXTRA_TEXT) ?: return null
            return mapOf("url" to text, "source" to "share", "sourceApp" to sourceAppLabel)
        }

        if (intent.action == Intent.ACTION_VIEW) {
            val data: Uri = intent.data ?: return null
            if (data.scheme != "http" && data.scheme != "https") return null
            return mapOf("url" to data.toString(), "source" to "view", "sourceApp" to sourceAppLabel)
        }

        return null
    }

    private fun resolveSourceAppLabel(): String? {
        val referrerPackage = referrer?.takeIf { it.scheme == "android-app" }?.host ?: return null
        return knownAppLabels[referrerPackage]
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, incomingLinkMethodChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSharedText" -> {
                    result.success(pendingIncomingLink)
                    pendingIncomingLink = null
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, incomingLinkEventChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                    incomingLinkSink = sink
                }

                override fun onCancel(arguments: Any?) {
                    incomingLinkSink = null
                }
            },
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, systemActionsChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "openExternalBrowser" -> {
                    val url = call.argument<String>("url")
                    if (url == null) {
                        result.error("bad_args", "Missing url", null)
                    } else {
                        result.success(openExternalBrowser(url))
                    }
                }
                "openLinkHandlerSettings" -> {
                    result.success(openLinkHandlerSettings())
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Opens [url] in some other app, never in Rakshak itself — this is
     * the anti-loop guarantee: the user chose "Open Directly" / "Open in
     * Default Browser" specifically to leave Rakshak, and must not be
     * routed straight back into it.
     */
    private fun openExternalBrowser(url: String): Boolean {
        val uri = try {
            Uri.parse(url)
        } catch (_: Exception) {
            return false
        }

        val viewIntent = Intent(Intent.ACTION_VIEW, uri)

        val defaultHandler = packageManager.resolveActivity(viewIntent, PackageManager.MATCH_DEFAULT_ONLY)
        if (defaultHandler != null && defaultHandler.activityInfo.packageName != packageName) {
            // A real default handler exists and it isn't us — hand off
            // directly with no chooser and no risk of re-entering Rakshak.
            viewIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            return try {
                startActivity(viewIntent)
                true
            } catch (_: Exception) {
                false
            }
        }

        // Either there's no single default (Android will normally show a
        // chooser) or the default resolves to Rakshak itself — either way,
        // build the chooser ourselves and explicitly exclude Rakshak so it
        // can never reappear as a choice here.
        return try {
            val chooser = Intent.createChooser(viewIntent, "Open link")
            chooser.putExtra(
                Intent.EXTRA_EXCLUDE_COMPONENTS,
                arrayOf(ComponentName(packageName, "$packageName.MainActivity")),
            )
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(chooser)
            true
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Deep-links into the Android Settings screen where the user can set
     * Rakshak as their preferred link handler. Android 12+ exposes a
     * dedicated "Open by default" screen per app; older versions fall back
     * to the general app-info screen, which still lets a user reach the
     * equivalent option on most OEM builds.
     */
    private fun openLinkHandlerSettings(): Boolean {
        val packageUri = Uri.parse("package:$packageName")

        val primary = Intent("android.settings.APP_OPEN_BY_DEFAULT_SETTINGS", packageUri)
        primary.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (primary.resolveActivity(packageManager) != null) {
            startActivity(primary)
            return true
        }

        val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri)
        fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(fallback)
            true
        } catch (_: Exception) {
            false
        }
    }
}
