import UIKit

class BruteForce {
    
    private var isBruteForceRunning = false

    func stopBruteForce(label: UILabel, indicator: UIActivityIndicatorView) {
           isBruteForceRunning = false
           label.text = "Подбор остановлен"
           indicator.stopAnimating()
       }

    
    func startBruteForce(passwordToUnlock: String, textField: UITextField, label: UILabel, indicator: UIActivityIndicatorView) {
           isBruteForceRunning = true
           textField.isSecureTextEntry = true
           label.text = ""
           indicator.startAnimating()
        
        DispatchQueue.global().async {
            let ALLOWED_CHARACTERS = String().printable.map { String($0) }
            var password: String = ""
            
            while password != passwordToUnlock && self.isBruteForceRunning {
                password = self.generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
                DispatchQueue.main.async {
                  label.text = password
                }
            }
            
            DispatchQueue.main.async {
                if password == passwordToUnlock {
                    label.text = "Пароль взломан: \(password)"
                    textField.isSecureTextEntry = false
                } else {
                    label.text = "Пароль не взломан"
                }
                indicator.stopAnimating()
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
    
    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string
        
        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        }
        else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
            
            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }
        
        return str
    }
}

