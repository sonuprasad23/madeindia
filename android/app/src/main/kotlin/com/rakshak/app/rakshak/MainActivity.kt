package com.rakshak.app.rakshak

import android.app.Activity
import android.app.role.RoleManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
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
 *    "intent loop" this feature must avoid); requesting Android's
 *    "Default Browser" role directly (the mechanism that actually makes
 *    every tapped link route to Rakshak — see [requestBrowserRole]); and
 *    a fallback deep-link into Android Settings for devices/versions
 *    where that role request isn't available.
 *
 * IMPORTANT — there are two, easily-confused Android mechanisms here:
 *   - "App Links" (Settings > Apps > Rakshak > Open by default > "Open
 *     supported links") only ever lists domains an app has *cryptographically
 *     verified ownership of* via a `assetlinks.json` file hosted on that real
 *     domain. Rakshak doesn't own whatsapp.com/gmail.com/etc., so this
 *     screen will always be empty for it — that's Android's security model
 *     working as intended, not a bug.
 *   - The **Default Browser role** (`RoleManager.ROLE_BROWSER`) is what
 *     actually routes every generic http/https link to an app, and does
 *     NOT require owning any domain — only that the app declares a plain
 *     "can open any web link" intent filter, which Rakshak's manifest
 *     already does. [requestBrowserRole] is the correct, working
 *     mechanism for "make Rakshak open every link".
 *
 * Deliberately hand-rolled with MethodChannel/EventChannel instead of a
 * third-party plugin: this is the entire integration surface Rakshak
 * needs from native Android for these features.
 */
class MainActivity : FlutterActivity() {
    private val incomingLinkMethodChannel = "app.rakshak/share_intent"
    private val incomingLinkEventChannel = "app.rakshak/share_intent_stream"
    private val systemActionsChannel = "app.rakshak/system"
    private val requestBrowserRoleCode = 5001

    private var pendingIncomingLink: Map<String, Any?>? = null
    private var incomingLinkSink: EventChannel.EventSink? = null
    private var pendingBrowserRoleResult: MethodChannel.Result? = null

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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == requestBrowserRoleCode) {
            val granted = resultCode == Activity.RESULT_OK
            pendingBrowserRoleResult?.success(if (granted) "granted" else "declined")
            pendingBrowserRoleResult = null
        }
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
                "requestBrowserRole" -> requestBrowserRole(result)
                "isDefaultBrowser" -> result.success(isDefaultBrowser())
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

    /**
     * The mechanism that actually makes every tapped http/https link route
     * to Rakshak, with no domain ownership required: requests Android's
     * "Default Browser" role via [RoleManager] (API 29+), which shows the
     * user a direct system dialog ("Set Rakshak as your Browser app?").
     * Rakshak qualifies because its manifest declares a plain, unrestricted
     * "can open any web link" `ACTION_VIEW`/`BROWSABLE` intent filter — the
     * same requirement any real browser meets.
     *
     * Resolves to one of: "granted", "declined", "already_default",
     * "unavailable" (API < 29, or the device/OEM doesn't expose the role —
     * falls back to the "Open by default" Settings screen instead).
     */
    private fun requestBrowserRole(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            openLinkHandlerSettings()
            result.success("unavailable")
            return
        }

        val roleManager = getSystemService(RoleManager::class.java)
        if (roleManager == null || !roleManager.isRoleAvailable(RoleManager.ROLE_BROWSER)) {
            openLinkHandlerSettings()
            result.success("unavailable")
            return
        }

        if (roleManager.isRoleHeld(RoleManager.ROLE_BROWSER)) {
            result.success("already_default")
            return
        }

        pendingBrowserRoleResult = result
        val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_BROWSER)
        try {
            startActivityForResult(intent, requestBrowserRoleCode)
        } catch (_: Exception) {
            pendingBrowserRoleResult = null
            openLinkHandlerSettings()
            result.success("unavailable")
        }
    }

    /**
     * Reports whether Rakshak currently holds the Default Browser role —
     * a pure status check with no side effects and no system dialog, used
     * to show "Rakshak is your default browser" in Settings without
     * asking again. False (never throws) below API 29 or if the role
     * isn't exposed on this device.
     */
    private fun isDefaultBrowser(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return false
        val roleManager = getSystemService(RoleManager::class.java) ?: return false
        if (!roleManager.isRoleAvailable(RoleManager.ROLE_BROWSER)) return false
        return roleManager.isRoleHeld(RoleManager.ROLE_BROWSER)
    }
}
