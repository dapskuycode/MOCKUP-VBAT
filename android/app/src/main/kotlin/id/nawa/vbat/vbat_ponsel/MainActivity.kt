package id.nawa.vbat.vbat_ponsel

import android.os.Build
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "id.nawa.vbat.vbat_ponsel/security"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureMode" -> {
                    // Mencegah screenshot & screen recording (Android FLAG_SECURE)
                    try {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("FLAG_SECURE_ERROR", e.localizedMessage, null)
                    }
                }
                "disableSecureMode" -> {
                    // Mengembalikan mode normal jika keluar dari materi berbayar
                    try {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CLEAR_FLAG_ERROR", e.localizedMessage, null)
                    }
                }
                "isSecureModeSupported" -> {
                    // FLAG_SECURE didukung native oleh Android Framework
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
