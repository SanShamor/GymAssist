//
//  BodyMassIndexViewController.swift
//  GymAssist
//
//  Created by Александр on 28.09.2021.
//

import UIKit

class BodyMassIndexVC: UIViewController {
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var bmiCategoriesLabel: UILabel!
    @IBOutlet weak var resultValueLabel: UILabel!
    @IBOutlet weak var bmiInfoTextView: UITextView!
    
    private var weightValue: Double = 1.0
    private var heightValue: Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBMIhelpInfo()
        setThemeMode()
        
        weightTextField.delegate = self
        heightTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func calculateButtonTapped(_ sender: Any) {
        resultValueLabel.text = ""
        didTapDone()
        getBmiResult()
    }
    
    @objc private func didTapDone() {
        view.endEditing(true)
    }
    
    private func getBmiResult() {
        weightValue = Double(weightTextField.text ?? "1") ?? 1.0
        heightValue = Double(heightTextField.text ?? "1") ?? 1.0
        let height = (heightValue / 100) * (heightValue / 100)
        var result = weightValue / height
        result = round(result * 100) / 100.0
        
        guard result > 15 && result < 70 else {
            return showAlert(title: "Wrong format!", message: "Please enter correct value")
        }
        
        resultValueLabel.text = "Ваш BMI: \(result)"
        if result > 18 && result < 25 {
            resultValueLabel.textColor = .green
        } else {
            resultValueLabel.textColor = .yellow
        }
        
    }
    
    private func setThemeMode() {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            weightTextField.textColor = #colorLiteral(red: 0.1890899241, green: 0.6003474593, blue: 0.4615892172, alpha: 1)
            weightTextField.backgroundColor = #colorLiteral(red: 0.1677677035, green: 0.1727086902, blue: 0.1726246774, alpha: 1)
            heightTextField.textColor = #colorLiteral(red: 0.1890899241, green: 0.6003474593, blue: 0.4615892172, alpha: 1)
            heightTextField.backgroundColor = #colorLiteral(red: 0.1677677035, green: 0.1727086902, blue: 0.1726246774, alpha: 1)
        default:
            weightTextField.textColor = .darkGray
            weightTextField.backgroundColor = .white
            heightTextField.textColor = .darkGray
            heightTextField.backgroundColor = .white
        }
    }
    
    private func setBMIhelpInfo() {
        bmiInfoTextView.text =
        """
        Индекс массы тела (BMI) — величина, позволяющая оценить степень соответствия массы человека и его роста и тем самым косвенно судить о том, является ли масса недостаточной, нормальной или избыточной.
        ИМТ важен при определении показаний для лечения.
        """
        bmiCategoriesLabel.text =
        """
         BMI           Соответствие
        16,00 — 18,49 Недостаточная масса
        18,50 — 24,99 Норма
        25,00 — 29,99 Предожирение
        30,00 — 34,99 Ожирение 1 степени
        35,00 — 49,99 Ожирение 2 степени
        """
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}
extension BodyMassIndexVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if let currentValue = Double(text) {
            switch textField {
            case weightTextField:
                weightValue = currentValue
            default:
                heightValue = currentValue
            }
            return
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let keyboardToolbar = UIToolbar()
        textField.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title:"Done",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )
        
        let flexBarButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        keyboardToolbar.items = [flexBarButton, doneButton]
    }
    
}

