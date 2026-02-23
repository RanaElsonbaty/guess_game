package com.khamni.game

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.guess_game/browser"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openBrowser" -> {
                    handleOpenBrowser(call.argument<String>("url"), result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun handleOpenBrowser(url: String?, result: MethodChannel.Result) {
        if (url.isNullOrBlank()) {
            Log.w(TAG, "Attempted to open browser with null or blank URL")
            result.error("INVALID_URL", "URL is null or empty", null)
            return
        }

        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url.trim())).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            // Check if there's an activity that can handle this intent
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                result.success(true)
                Log.i(TAG, "Successfully opened URL: $url")
            } else {
                Log.e(TAG, "No activity found to handle URL: $url")
                result.error("NO_ACTIVITY", "No application found to handle this URL", null)
            }
        } catch (e: ActivityNotFoundException) {
            Log.e(TAG, "Activity not found for URL: $url", e)
            result.error("ACTIVITY_NOT_FOUND", "No application found to handle this URL", null)
        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception when opening URL: $url", e)
            result.error("SECURITY_ERROR", "Permission denied to open URL", null)
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error when opening URL: $url", e)
            result.error("UNEXPECTED_ERROR", "Unexpected error occurred: ${e.localizedMessage}", null)
        }
    }
}
