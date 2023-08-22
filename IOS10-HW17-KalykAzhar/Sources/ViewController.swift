import UIKit

class ViewController: UIViewController {
    
    // MARK: - Elements
    private var bruteForceQueue: DispatchQueue?
    private var isBruteForceRunning = false
    private var isBackgroundDark = false
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00)
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.placeholder = "Password"
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 15
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tap", for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor(red: 0.75, green: 0.85, blue: 0.86, alpha: 1.00)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonFindPasswordStarted), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonRandomPassword: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Random Password", for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor(red: 0.75, green: 0.85, blue: 0.86, alpha: 1.00)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonRandomPasswordTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonBackground: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Color", for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor(red: 0.75, green: 0.85, blue: 0.86, alpha: 1.00)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToggleBackgroundTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
    }
    
    //MARK: - Setups
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 0.76, green: 0.88, blue: 0.77, alpha: 1.00)
    }
    
    private func setupHierarchy() {
        
        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(indicator)
        view.addSubview(button)
        view.addSubview(buttonRandomPassword)
        view.addSubview(buttonBackground)
    }
    
    private func setupLayout() {
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalToConstant: 200),
            label.heightAnchor.constraint(equalToConstant: 50),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: 200),
            textField.heightAnchor.constraint(equalToConstant: 50),
            
            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50),
            
            buttonRandomPassword.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20),
            buttonRandomPassword.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonRandomPassword.widthAnchor.constraint(equalToConstant: 200),
            buttonRandomPassword.heightAnchor.constraint(equalToConstant: 50),
            
            buttonBackground.topAnchor.constraint(equalTo: buttonRandomPassword.bottomAnchor, constant: 70),
            buttonBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonBackground.widthAnchor.constraint(equalToConstant: 200),
            buttonBackground.heightAnchor.constraint(equalToConstant: 50),
            
            indicator.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK:  - Actions
    
    @objc private func buttonFindPasswordStarted() {
        if isBruteForceRunning {
            stopBruteForce()
        } else {
            let passwordToUnlock = textField.text ?? ""
            if passwordToUnlock.isEmpty {
                alert(message: "Введите пароль")
                return
            }
            if let currentQueue = bruteForceQueue {
                currentQueue.async {
                    self.stopBruteForce()
                }
            }
            startBruteForce(passwordToUnlock: passwordToUnlock)
        }
    }
    
    @objc private func buttonRandomPasswordTapped() {
        let randomPassword = generateRandomPassword(length: 1)
        textField.text = randomPassword
    }
    
    @objc private func buttonToggleBackgroundTapped() {
        isBackgroundDark.toggle()
        view.backgroundColor = isBackgroundDark ? UIColor(red: 0.68, green: 0.69, blue: 0.72, alpha: 1.00) : UIColor(red: 0.76, green: 0.88, blue: 0.77, alpha: 1.00)
    }
    
    // MARK: - FancActions
    
    private func generateRandomPassword(length: Int) -> String {
        let allowedCharacters = String().printable
        let randomPassword = String((0..<length).map { _ in allowedCharacters.randomElement() ?? " " })
        return randomPassword
    }
    
    private func alert(message: String) {
        let mistake = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        mistake.addAction(okAction)
        present(mistake, animated: true, completion: nil)
    }
    
    private func stopBruteForce() {
        isBruteForceRunning = false
        textField.isSecureTextEntry = false
        indicator.stopAnimating()
        bruteForceQueue = nil
    }
    
    private func startBruteForce(passwordToUnlock: String) {
        stopBruteForce()
        isBruteForceRunning = true
        textField.isSecureTextEntry = true
        label.text = ""
        indicator.startAnimating()
        
        bruteForceQueue = DispatchQueue(label: "com.myapp.bruteforce", qos: .background)
        bruteForceQueue?.async { [weak self] in
            guard let self = self else { return }
            
            let ALLOWED_CHARACTERS = String().printable.map { String($0) }
            let passwordLength = passwordToUnlock.count
            
            while self.isBruteForceRunning {
                for length in 1...passwordLength {
                    self.recursiveBruteForce(passwordToUnlock: passwordToUnlock, allowedCharacters: ALLOWED_CHARACTERS, currentPassword: "", targetLength: length)
                }
            }
            
            DispatchQueue.main.async {
                self.stopBruteForce()
                self.label.text = "Пароль не взломан"
            }
        }
    }
        
    private func recursiveBruteForce(passwordToUnlock: String, allowedCharacters: [String], currentPassword: String, targetLength: Int) {
        if isBruteForceRunning {
            if currentPassword.count == targetLength {
                if currentPassword == passwordToUnlock {
                    DispatchQueue.main.async {
                        self.stopBruteForce()
                        self.label.text = "Пароль взломан: \(currentPassword)"
                        self.textField.isSecureTextEntry = false
                    }
                }
            } else {
                for character in allowedCharacters {
                    let newPassword = currentPassword + character
                    
                    DispatchQueue.main.async {
                        self.label.text = "\(newPassword)"
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        self.recursiveBruteForce(passwordToUnlock: passwordToUnlock, allowedCharacters: allowedCharacters, currentPassword: newPassword, targetLength: targetLength)
                    }
                }
            }
        }
    }
}
