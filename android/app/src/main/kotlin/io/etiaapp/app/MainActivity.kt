package io.etiaapp.app

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "io.etiaapp.app/mercado_pago"
    private val REQUEST_CODE_MP = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "createCardToken" -> {
                    val publicKey = call.argument<String>("publicKey") ?: ""
                    val countryCode = call.argument<String>("countryCode") ?: "AR"
                    val idNumber = call.argument<String>("identificationNumber") ?: ""
                    val idType = call.argument<String>("identificationType") ?: "DNI"

                    // A second tap while the form is open would overwrite the
                    // pending result; reject it instead of leaking it.
                    if (pendingResult != null) {
                        result.error("MP_BUSY", "Card form already open", null)
                        return@setMethodCallHandler
                    }
                    pendingResult = result

                    val intent = Intent(this, MercadoPagoCardActivity::class.java).apply {
                        putExtra(MercadoPagoCardActivity.EXTRA_PUBLIC_KEY, publicKey)
                        putExtra(MercadoPagoCardActivity.EXTRA_COUNTRY_CODE, countryCode)
                        putExtra(MercadoPagoCardActivity.EXTRA_ID_NUMBER, idNumber)
                        putExtra(MercadoPagoCardActivity.EXTRA_ID_TYPE, idType)
                    }
                    @Suppress("DEPRECATION")
                    startActivityForResult(intent, REQUEST_CODE_MP)
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_MP) {
            if (resultCode == Activity.RESULT_OK) {
                val token = data?.getStringExtra(MercadoPagoCardActivity.EXTRA_TOKEN)
                if (token.isNullOrEmpty()) {
                    pendingResult?.error("MP_ERROR", "Empty token received", null)
                } else {
                    pendingResult?.success(token)
                }
            } else {
                val error = data?.getStringExtra(MercadoPagoCardActivity.EXTRA_ERROR)
                pendingResult?.error(
                    if (error == null) "MP_CANCELLED" else "MP_ERROR",
                    error ?: "Payment cancelled",
                    null,
                )
            }
            pendingResult = null
        }
    }
}
