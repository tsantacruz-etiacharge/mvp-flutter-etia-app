import Flutter
import UIKit
import GoogleMaps
import CoreMethods

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private var mercadoPagoChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Key injected via Secrets.xcconfig -> Info.plist (GMSApiKey).
    // Skipped when Secrets.xcconfig is missing (value stays $(...) literal).
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !apiKey.isEmpty, !apiKey.hasPrefix("$(") {
      GMSServices.provideAPIKey(apiKey)
    }
    initializeMercadoPago()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    mercadoPagoChannel = FlutterMethodChannel(
      name: "io.etiaapp.app/mercado_pago",
      binaryMessenger: engineBridge.binaryMessenger,
    )
    mercadoPagoChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleMercadoPagoCall(call, result: result)
    }
  }

  // MARK: - Mercado Pago (ported from prueba-flutter-MP AppDelegate)

  private func initializeMercadoPago() {
    let publicKey =
      Bundle.main.object(forInfoDictionaryKey: "MercadoPagoPublicKey") as? String ?? ""
    guard !publicKey.isEmpty, !publicKey.hasPrefix("$(") else { return }
    let config = MercadoPagoSDK.Configuration(
      publicKey: publicKey,
      country: .ARG,
    )
    MercadoPagoSDK.shared.initialize(config)
  }

  private func handleMercadoPagoCall(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    switch call.method {
    case "createCardToken":
      guard let args = call.arguments as? [String: Any],
            let publicKey = args["publicKey"] as? String, !publicKey.isEmpty
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing publicKey", details: nil))
        return
      }
      presentCardForm(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func presentCardForm(result: @escaping FlutterResult) {
    guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
      result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller", details: nil))
      return
    }

    let cardVC = MercadoPagoCardViewController()
    let navController = UINavigationController(rootViewController: cardVC)

    cardVC.onTokenGenerated = { token in
      navController.dismiss(animated: true) {
        result(token)
      }
    }

    cardVC.onError = { error in
      navController.dismiss(animated: true) {
        result(FlutterError(code: "MP_TOKEN_ERROR", message: error, details: nil))
      }
    }

    cardVC.onCancelled = {
      navController.dismiss(animated: true) {
        result(FlutterError(code: "MP_CANCELLED", message: "Payment form cancelled", details: nil))
      }
    }

    rootVC.present(navController, animated: true)
  }
}
