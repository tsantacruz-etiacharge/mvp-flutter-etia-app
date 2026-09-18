package io.etiaapp.app

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.mercadopago.sdk.android.coremethods.domain.interactor.CoreMethods
import com.mercadopago.sdk.android.coremethods.domain.interactor.coreMethods
import com.mercadopago.sdk.android.coremethods.domain.model.BuyerIdentification
import com.mercadopago.sdk.android.coremethods.domain.model.ResultError
import com.mercadopago.sdk.android.coremethods.domain.utils.Result
import com.mercadopago.sdk.android.coremethods.ui.components.textfield.cardnumber.CardNumberTextField
import com.mercadopago.sdk.android.coremethods.ui.components.textfield.expirationdate.ExpirationDateTextField
import com.mercadopago.sdk.android.coremethods.ui.components.textfield.securitycode.SecurityCodeTextField
import com.mercadopago.sdk.android.coremethods.ui.components.textfield.pcitextfield.PCIFieldState
import com.mercadopago.sdk.android.domain.model.CountryCode
import com.mercadopago.sdk.android.initializer.MercadoPagoSDK
import kotlinx.coroutines.launch

// Ported from prueba-flutter-MP (same file, package renamed). The buyer
// identification now arrives via intent extras (real user DNI from Dart)
// instead of the PoC's hardcoded APRO/12345678 test values.
class MercadoPagoCardActivity : ComponentActivity() {

    companion object {
        const val EXTRA_PUBLIC_KEY = "extra_public_key"
        const val EXTRA_COUNTRY_CODE = "extra_country_code"
        const val EXTRA_ID_NUMBER = "extra_id_number"
        const val EXTRA_ID_TYPE = "extra_id_type"
        const val EXTRA_TOKEN = "extra_token"
        const val EXTRA_ERROR = "extra_error"
    }

    private val coreMethods: CoreMethods by lazy {
        MercadoPagoSDK.getInstance().coreMethods
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val publicKey = intent.getStringExtra(EXTRA_PUBLIC_KEY) ?: ""
        val countryCodeStr = intent.getStringExtra(EXTRA_COUNTRY_CODE) ?: "AR"
        val idNumber = intent.getStringExtra(EXTRA_ID_NUMBER).orEmpty()
        val idType = intent.getStringExtra(EXTRA_ID_TYPE).orEmpty()
            .ifEmpty { "DNI" }

        val countryCode = try {
            CountryCode.valueOf(countryCodeStr)
        } catch (_: Exception) {
            CountryCode.ARG
        }

        MercadoPagoSDK.initialize(
            context = applicationContext,
            publicKey = publicKey,
            countryCode = countryCode,
        )

        setContent {
            MaterialTheme {
                CardTokenScreen(
                    coreMethods = coreMethods,
                    idNumber = idNumber,
                    idType = idType,
                    onTokenGenerated = { token ->
                        setResult(RESULT_OK, Intent().apply {
                            putExtra(EXTRA_TOKEN, token)
                        })
                        finish()
                    },
                    onError = { error ->
                        setResult(RESULT_CANCELED, Intent().apply {
                            putExtra(EXTRA_ERROR, error)
                        })
                        finish()
                    },
                    onCancel = {
                        setResult(RESULT_CANCELED)
                        finish()
                    },
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardTokenScreen(
    coreMethods: CoreMethods,
    idNumber: String,
    idType: String,
    onTokenGenerated: (String) -> Unit,
    onError: (String) -> Unit,
    onCancel: () -> Unit,
) {
    val scope = rememberCoroutineScope()
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    val cardNumberState = remember { PCIFieldState.create() }
    val expirationDateState = remember { PCIFieldState.create() }
    val securityCodeState = remember { PCIFieldState.create() }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Pago con Tarjeta") },
                navigationIcon = {
                    TextButton(onClick = onCancel) {
                        Text("Cancelar")
                    }
                },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .padding(16.dp)
                .fillMaxSize()
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Text(
                text = "Complete los datos de su tarjeta",
                style = MaterialTheme.typography.bodyLarge,
            )

            Text("Número de tarjeta", style = MaterialTheme.typography.labelLarge)

            CardNumberTextField(
                state = cardNumberState,
                onEvent = { },
                modifier = Modifier.fillMaxWidth(),
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.fillMaxWidth(),
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text("Vencimiento", style = MaterialTheme.typography.labelLarge)
                    ExpirationDateTextField(
                        state = expirationDateState,
                        onEvent = { },
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text("CVV", style = MaterialTheme.typography.labelLarge)
                    SecurityCodeTextField(
                        state = securityCodeState,
                        onEvent = { },
                        modifier = Modifier.fillMaxWidth(),
                    )
                }
            }

            if (errorMessage != null) {
                Text(
                    text = errorMessage!!,
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.bodySmall,
                )
            }

            Button(
                onClick = {
                    isLoading = true
                    errorMessage = null
                    scope.launch {
                        try {
                            val result = coreMethods.generateCardToken(
                                cardNumberState = cardNumberState,
                                expirationDateState = expirationDateState,
                                securityCodeState = securityCodeState,
                                buyerIdentification = BuyerIdentification(
                                    name = "APRO",
                                    number = idNumber.ifEmpty { "12345678" },
                                    type = idType,
                                ),
                            )
                            when (result) {
                                is Result.Success -> {
                                    onTokenGenerated(result.data.token)
                                }
                                is Result.Error -> {
                                    val msg = when (val err = result.error) {
                                        is ResultError.Request -> "Error de red: ${err.message}"
                                        is ResultError.Validation -> "Validación: ${err.message}"
                                        else -> "Error desconocido"
                                    }
                                    errorMessage = msg
                                    isLoading = false
                                }
                            }
                        } catch (e: Exception) {
                            errorMessage = "Error: ${e.message}"
                            isLoading = false
                        }
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isLoading,
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.height(20.dp).width(20.dp),
                        strokeWidth = 2.dp,
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                }
                Text("Generar Token")
            }
        }
    }
}
