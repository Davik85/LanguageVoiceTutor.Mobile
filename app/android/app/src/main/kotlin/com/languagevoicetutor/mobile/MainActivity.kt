package com.languagevoicetutor.mobile

import android.os.Build
import android.os.CancellationSignal
import androidx.credentials.ClearCredentialStateRequest
import androidx.credentials.CreateRestoreCredentialRequest
import androidx.credentials.CreateRestoreCredentialResponse
import androidx.credentials.CredentialManager
import androidx.credentials.CredentialManagerCallback
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetRestoreCredentialOption
import androidx.credentials.RestoreCredential
import androidx.credentials.exceptions.ClearCredentialException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.NoCredentialException
import androidx.credentials.exceptions.restorecredential.E2eeUnavailableException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result -> handleRestoreCredential(call, result) }
    }

    private fun handleRestoreCredential(call: MethodCall, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.success(mapOf("status" to "unsupported"))
            return
        }
        when (call.method) {
            "createRestoreCredential" -> create(call, result)
            "getRestoreCredential" -> get(call, result)
            "clearRestoreCredential" -> clear(result)
            else -> result.notImplemented()
        }
    }

    private fun create(call: MethodCall, result: MethodChannel.Result) {
        val requestJson = call.argument<String>("requestJson")
        if (requestJson.isNullOrBlank()) {
            result.success(mapOf("status" to "invalid"))
            return
        }
        val completed = AtomicBoolean(false)
        fun complete(status: String, responseJson: String? = null) {
            if (completed.compareAndSet(false, true)) {
                result.success(buildMap {
                    put("status", status)
                    if (responseJson != null) put("responseJson", responseJson)
                })
            }
        }
        createAsync(requestJson, true, completed, ::complete)
    }

    private fun createAsync(
        requestJson: String,
        cloudBackupEnabled: Boolean,
        completed: AtomicBoolean,
        complete: (String, String?) -> Unit,
    ) {
        try {
            CredentialManager.create(this).createCredentialAsync(
                this,
                CreateRestoreCredentialRequest(requestJson, cloudBackupEnabled),
                CancellationSignal(),
                mainExecutor,
                object : CredentialManagerCallback<
                    androidx.credentials.CreateCredentialResponse,
                    CreateCredentialException,
                > {
                    override fun onResult(response: androidx.credentials.CreateCredentialResponse) {
                        if (response is CreateRestoreCredentialResponse) {
                            complete(if (cloudBackupEnabled) "success" else "localOnly", response.responseJson)
                        } else {
                            complete("failed", null)
                        }
                    }

                    override fun onError(error: CreateCredentialException) {
                        if (cloudBackupEnabled && error is E2eeUnavailableException && !completed.get()) {
                            createAsync(requestJson, false, completed, complete)
                        } else {
                            complete("unavailable", null)
                        }
                    }
                },
            )
        } catch (_: IllegalArgumentException) {
            complete("invalid", null)
        } catch (_: Exception) {
            complete("unavailable", null)
        }
    }

    private fun get(call: MethodCall, result: MethodChannel.Result) {
        val requestJson = call.argument<String>("requestJson")
        if (requestJson.isNullOrBlank()) {
            result.success(mapOf("status" to "invalid"))
            return
        }
        try {
            CredentialManager.create(this).getCredentialAsync(
                this,
                GetCredentialRequest(listOf(GetRestoreCredentialOption(requestJson))),
                CancellationSignal(), mainExecutor,
                object : CredentialManagerCallback<androidx.credentials.GetCredentialResponse, GetCredentialException> {
                    override fun onResult(response: androidx.credentials.GetCredentialResponse) {
                        val credential = response.credential
                        if (credential is RestoreCredential) {
                            result.success(mapOf("status" to "success", "responseJson" to credential.authenticationResponseJson))
                        } else result.success(mapOf("status" to "noCredential"))
                    }
                    override fun onError(error: GetCredentialException) {
                        result.success(mapOf("status" to if (error is NoCredentialException) "noCredential" else "unavailable"))
                    }
                })
        } catch (_: IllegalArgumentException) { result.success(mapOf("status" to "invalid"))
        } catch (_: Exception) { result.success(mapOf("status" to "unavailable")) }
    }

    private fun clear(result: MethodChannel.Result) {
        try {
            CredentialManager.create(this).clearCredentialStateAsync(
                ClearCredentialStateRequest(ClearCredentialStateRequest.TYPE_CLEAR_RESTORE_CREDENTIAL),
                CancellationSignal(), mainExecutor,
                object : CredentialManagerCallback<Void?, ClearCredentialException> {
                    override fun onResult(resultValue: Void?) { result.success(mapOf("status" to "success")) }
                    override fun onError(error: ClearCredentialException) { result.success(mapOf("status" to "unavailable")) }
                })
        } catch (_: Exception) { result.success(mapOf("status" to "unavailable")) }
    }

    companion object { private const val CHANNEL = "com.languagevoicetutor.mobile/restore_credentials" }
}
