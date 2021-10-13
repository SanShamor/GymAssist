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
    }
    
    @IBAction func calculateButtonTapped(_ sender: Any) {
        let weight = weightTextField.text ?? "1"
        weightValue = Double(weight) ?? 1.0
        let height = heightTextField.text ?? "1"
        heightValue = Double(height) ?? 1.0
        
        let result = getBmiResult()
        resultValueLabel.text = "Ваш BMI: \(result)"
        
        if result > 18 && result < 25 {
            resultValueLabel.textColor = .green
        } else {
            resultValueLabel.textColor = .yellow
        }
    }
    
    private func getBmiResult() -> Double {
        let height = (heightValue / 100) * (heightValue / 100)
        var result = weightValue / height
        result = round(result * 100) / 100.0
        return result
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
    
    @objc private func didTapDone() {
        view.endEditing(true)
    }
    
}
extension BodyMassIndexVC: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
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
        
        showAlert(title: "Wrong format!", message: "Please enter correct value")
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
