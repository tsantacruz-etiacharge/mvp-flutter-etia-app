import UIKit
import CoreMethods

// Ported verbatim from prueba-flutter-MP
// (ios/Runner/MercadoPagoCardViewController.swift).
class MercadoPagoCardViewController: UIViewController {

    private let coreMethods = CoreMethods()

    private let cardNumberField = CardNumberTextField()
    private let securityCodeField = SecurityCodeTextField()
    private let expirationDateField = ExpirationDateTextfield()

    private let generateButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    var onTokenGenerated: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onCancelled: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Pago con Tarjeta"
        setupNavigation()
        setupUI()
        setupFields()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped),
        )
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])

        let titleLabel = UILabel()
        titleLabel.text = "Complete los datos de su tarjeta"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)

        let cardNumberLabel = UILabel()
        cardNumberLabel.text = "Número de tarjeta"
        cardNumberLabel.font = .systemFont(ofSize: 13, weight: .semibold)

        let expiryAndCvvStack = UIStackView()
        expiryAndCvvStack.axis = .horizontal
        expiryAndCvvStack.spacing = 16

        let expiryContainer = UIStackView()
        expiryContainer.axis = .vertical
        expiryContainer.spacing = 4
        let expiryLabel = UILabel()
        expiryLabel.text = "Vencimiento"
        expiryLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        expiryContainer.addArrangedSubview(expiryLabel)
        expiryContainer.addArrangedSubview(expirationDateField)

        let cvvContainer = UIStackView()
        cvvContainer.axis = .vertical
        cvvContainer.spacing = 4
        let cvvLabel = UILabel()
        cvvLabel.text = "CVV"
        cvvLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        cvvContainer.addArrangedSubview(cvvLabel)
        cvvContainer.addArrangedSubview(securityCodeField)

        expiryAndCvvStack.addArrangedSubview(expiryContainer)
        expiryAndCvvStack.addArrangedSubview(cvvContainer)

        generateButton.setTitle("Generar Token", for: .normal)
        generateButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        generateButton.backgroundColor = .systemBlue
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 8
        generateButton.addTarget(self, action: #selector(generateTokenTapped), for: .touchUpInside)

        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(cardNumberLabel)
        stackView.addArrangedSubview(cardNumberField)
        stackView.addArrangedSubview(expiryAndCvvStack)
        stackView.addArrangedSubview(generateButton)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(statusLabel)

        NSLayoutConstraint.activate([
            generateButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupFields() {
        let style = TextFieldDefaultStyle()
            .borderColor(.systemGray3)
            .borderWidth(1)
            .cornerRadius(8)

        cardNumberField.applyStyle(style)
        securityCodeField.applyStyle(style)
        expirationDateField.applyStyle(style)

        cardNumberField.onBinChanged = { [weak self] bin in
            // BIN received
        }

        cardNumberField.onLastFourDigitsFilled = { [weak self] lastFour in
            // Last four digits filled
        }

        securityCodeField.onInputFilled = { [weak self] in
            // Security code completed
        }

        securityCodeField.onError = { [weak self] error in
            // Security code error
        }

        expirationDateField.onError = { [weak self] error in
            // Expiration date error
        }
    }

    @objc private func cancelTapped() {
        onCancelled?()
    }

    @objc private func generateTokenTapped() {
        setLoading(true)

        Task {
            do {
                let token = try await coreMethods.createToken(
                    cardNumber: cardNumberField,
                    expirationDate: expirationDateField,
                    securityCode: securityCodeField,
                )
                DispatchQueue.main.async { [weak self] in
                    self?.setLoading(false)
                    self?.onTokenGenerated?(token.token)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.setLoading(false)
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        generateButton.isEnabled = !loading
        if loading {
            activityIndicator.startAnimating()
            generateButton.setTitle("", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            generateButton.setTitle("Generar Token", for: .normal)
        }
    }
}
