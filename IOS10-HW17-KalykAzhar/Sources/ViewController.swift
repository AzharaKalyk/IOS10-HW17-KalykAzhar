import UIKit

class ViewController: UIViewController {
    
    // MARK: - Elements
    
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
    
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var isBruteForceRunning = false
    
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
        view.addSubview(textField)
        view.addSubview(label)
        view.addSubview(button)
        view.addSubview(indicator)
    }
    
    private func setupLayout() {
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 450),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -350),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 350),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -80),
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -450),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 250),
            label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -450),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 120),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            indicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 395),
            indicator.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -80),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -405),
            indicator.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80),
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
            startBruteForce(passwordToUnlock: passwordToUnlock)
        }
    }
    
    private func alert(message: String) {
        let mistake = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        mistake.addAction(okAction)
        present(mistake, animated: true, completion: nil)
    }
    
    private func stopBruteForce() {
        isBruteForceRunning = false
        label.text = "Подбор остановлен"
        indicator.stopAnimating()
    }
    
    private func startBruteForce(passwordToUnlock: String) {
        isBruteForceRunning = true
        textField.isSecureTextEntry = true
        label.text = ""
        indicator.startAnimating()
        
        DispatchQueue.global().async {
            let ALLOWED_CHARACTERS = String().printable.map { String($0) }
            var password: String = ""
            
            while password != passwordToUnlock && self.isBruteForceRunning {
                password = self.generateBruteForce(password, fromArray: ALLOWED_CHARACTERS, length: 4)
                DispatchQueue.main.async {
                    self.label.text = password
                }
            }
            
            DispatchQueue.main.async {
                if password == passwordToUnlock {
                    self.label.text = "Пароль взломан: \(password)"
                    self.textField.isSecureTextEntry = false
                } else {
                    self.label.text = "Пароль не взломан"
                }
                self.indicator.stopAnimating()
                self.isBruteForceRunning = false
            }
        }
    }
    
    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character)) ?? 0
    }
    
    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
        : Character("")
    }
    
    func generateBruteForce(_ string: String, fromArray array: [String], length: Int) -> String {
        var str: String = string
        
        if str.count < length {
            str.append(characterAt(index: 0, array))
        } else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
            
            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array, length: length - 1)) + String(str.last!)
            }
        }
        return str
    }
}

