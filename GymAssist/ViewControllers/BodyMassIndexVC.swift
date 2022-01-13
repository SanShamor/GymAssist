//
//  BodyMassIndexViewController.swift
//  GymAssist
//
//  Created by Александр on 28.09.2021.
//

import UIKit
import Charts
import RealmSwift

class BodyMassIndexVC: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var updateWeightButton: UIButton!
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var bmiCategoriesLabel: UILabel!
    @IBOutlet weak var resultValueLabel: UILabel!
    @IBOutlet weak var bmiInfoTextView: UITextView!
    
    private let dataManager = DataManager.shared
    private let lineChart = LineChartView()
    private var user: Results<Profile>!
    
    private var weightValue: Double = 1.0
    private var heightValue: Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBMIhelpInfo()
        setThemeMode()
        
        // Testing:------
        user = StorageManager.shared.realm.objects(Profile.self)
        bmiInfoTextView.text = "---------------Testing-----------------\nТекущий вес: \(user.first?.weight ?? 100.500)"
        //---------------
        
        weightTextField.delegate = self
        heightTextField.delegate = self
        lineChart.delegate = self
        lineChart.frame = CGRect (x: 0,
                                  y: 0,
                                  width: chartView.frame.size.height,
                                  height: self.chartView.frame.size.height)
        chartView.addSubview(lineChart)
        setDataForChart()
        customizeLineChart()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func updWeightButtonPressed(_ sender: Any) {
        showAlert(with: user.first)
    }
    
    @IBAction func calculateButtonTapped(_ sender: Any) {
        resultValueLabel.text = ""
        didTapDone()
        getBmiResult()
    }
    
    @objc private func didTapDone() {
        view.endEditing(true)
    }
    
    private func setWeightButton() {
        updateWeightButton.layer.cornerRadius = 15
        updateWeightButton.titleLabel?.font = UIFont(name: "GillSans-Italic", size: 23)
        
    }
    
    private func setDataForChart() {
        let set = getUserDataSet()
        set.setColor(.white)
        set.circleHoleColor = .red
        set.setCircleColor(.lightGray)
        
        let data = LineChartData(dataSet: set)
        lineChart.data = data
    }
    
    private func getUserDataSet() -> LineChartDataSet { // Testing
        var entries = [ChartDataEntry] ()
        var day = 1
        for weight in user.first!.weightHistory {
                    let weightY = weight
                    day += 1
                    let dateX = Double(day)
                    entries.append(ChartDataEntry(x: dateX, y: weightY))
                }
        entries.append(ChartDataEntry(x: Double(day + 1) , y: user.first!.weight))
                let secondSet = LineChartDataSet(entries: entries, label: "Test values")
                return secondSet
    }
    
    private func getTestDataSet() -> LineChartDataSet  { //Testing
        let set = LineChartDataSet(entries: [
            ChartDataEntry(x: 1 , y: 65),
            ChartDataEntry(x: 2 , y: 63.8),
            ChartDataEntry(x: 3 , y: 63.3),
            ChartDataEntry(x: 4 , y: 64.1),
            ChartDataEntry(x: 5 , y: 63.6),
            ChartDataEntry(x: 6 , y: 62.9),
            ChartDataEntry(x: 7 , y: 63.5),
            ChartDataEntry(x: 10 , y: 64.1),
            ChartDataEntry(x: 11 , y: 64.7),
            ChartDataEntry(x: 13 , y: 65.3),
            ChartDataEntry(x: 15 , y: 65.0),
            ChartDataEntry(x: 17 , y: 65.9),
            ChartDataEntry(x: 20 , y: 65.7)
        ])
        return set
    }
    
    private func customizeLineChart() {
        lineChart.noDataText = "Добавьте данные о весе"
        lineChart.backgroundColor = .darkGray
        lineChart.rightAxis.enabled = false
        lineChart.animate(xAxisDuration: 2)
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelTextColor = .lightGray
        lineChart.xAxis.axisLineColor = .red
        
        let yAxis = lineChart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(5, force: false)
        yAxis.labelTextColor = .lightGray
        yAxis.axisLineColor = .red
        yAxis.labelPosition = .outsideChart
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
        bmiInfoTextView.text = dataManager.bmiInfo
        bmiCategoriesLabel.text = dataManager.bmiCategories
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}
extension BodyMassIndexVC: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
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

extension BodyMassIndexVC {
    private func showAlert(with profile: Profile? = nil, completion: (() -> Void)? = nil) {
        let title = "enter weight"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Укажите ...")
        
        alert.action(with: user.first) { newValue in
            let newWeight = Double(newValue)!
            StorageManager.shared.updateWeight(user: profile!, newWeight: newWeight)
        }
        
        present(alert, animated: true)
    }
    
}
