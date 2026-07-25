package hib.np.com.tinker

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import com.google.android.gms.pay.Pay
import com.google.android.gms.pay.PayClient
import com.google.android.gms.pay.PayApiAvailabilityStatus

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "hib.np.gov/google_wallet"
    private lateinit var walletClient: PayClient

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        walletClient = Pay.getClient(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "savePassesJwt") {
                val jwt = call.argument<String>("jwt")
                if (jwt != null) {
                    savePassesJwt(jwt, result)
                } else {
                    result.error("INVALID_ARGUMENT", "JWT is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun savePassesJwt(jwt: String, result: MethodChannel.Result) {
        walletClient.savePassesJwt(jwt, this, 1001)
        result.success(true)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, requestCode, data)
        // Handle result of savePassesJwt if needed
    }
}
