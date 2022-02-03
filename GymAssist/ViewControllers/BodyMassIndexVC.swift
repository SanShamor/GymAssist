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
    // MARK: - IBOuthlets
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var updateWeightButton: UIButton!
    
    @IBOutlet weak var bmiInfoTextView: UITextView!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var resultValueLabel: UILabel!
    @IBOutlet weak var bmiCategoriesLabel: UILabel!
    
    // MARK: - Properties
    private let dataManager = DataManager.shared
    private var user: Results<Profile>?
    private let lineChart = LineChartView()
    
    private var weightValue: Double = 1.0
    private var heightValue: Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weightTextField.delegate = self
        heightTextField.delegate = self
        lineChart.delegate = self
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        lineChart.frame = CGRect (x: 0,
                                  y: 0,
                                  width: chartView.frame.size.width,
                                  height: self.chartView.frame.size.height)
        chartView.addSubview(lineChart)
        
        setBMIhelpInfo()
        setThemeMode()
        loadUserProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setDataForChart()
        customizeLineChart()
    }
         
    // MARK: - IBActions
    @IBAction func updWeightButtonPressed(_ sender: Any) {
        guard let person = user?.first, user?.first?.weightHistory != nil else { return }
        showAlertUpdater(with: person) {
        }
    
    }
    
    @IBAction func calculateButtonTapped(_ sender: Any) {
        didTapDone()
        getBmiResult()
    }
    
    @objc private func didTapDone() {
        view.endEditing(true)
    }
    
    // MARK: - Methods
    private func loadUserProfile() {
        if !UserDefaults.standard.bool(forKey: "ProfileDone") {
            showAlertCreator()
        } else {
            user = StorageManager.shared.realm.objects(Profile.self)
            setDataForChart()
        }
    }
    
    private func getUserDataSet() -> LineChartDataSet {
        let person = user?.first
        var entries = [ChartDataEntry] ()
        var day = 1
        for weight in person!.weightHistory {
            let weightY = weight
            day += 1
            let dateX = Double(day)
            entries.append(ChartDataEntry(x: dateX, y: weightY))
        }
        entries.append(ChartDataEntry(x: Double(day + 1) , y: person!.weight))
        let set = LineChartDataSet(entries: entries, label: "BMI:chart.progress".localized() )
        return set
    }
    
    private func setDataForChart() {
        guard user?.first?.weightHistory != nil else { return }
        let set = getUserDataSet()
        set.setColor(#colorLiteral(red: 0.1900779605, green: 0.5983788371, blue: 0.4619213343, alpha: 1))
        set.lineWidth = 5
        set.setCircleColor(.lightGray)
        set.circleHoleColor = .red
        set.mode = .cubicBezier
        set.drawFilledEnabled = true
        set.fill = Fill(color: .lightGray)
        set.fillAlpha = 0.5
        set.valueTextColor = .red
        
        let data = LineChartData(dataSet: set)
        lineChart.data = data
    }
    
    private func customizeLineChart() {
        lineChart.noDataText = "BMI:chart.noData".localized()
        lineChart.rightAxis.enabled = false
        lineChart.backgroundColor = .darkGray
        lineChart.animate(xAxisDuration: 0.5)
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelTextColor = .darkGray
        lineChart.xAxis.axisLineColor = .red
        lineChart.xAxis.axisLineWidth = 3
        lineChart.xAxis.setLabelCount(0, force: true)
        
        let yAxis = lineChart.leftAxis
        yAxis.labelPosition = .outsideChart
        yAxis.labelFont = .boldSystemFont(ofSize: 16)
        yAxis.setLabelCount(5, force: false)
        yAxis.labelTextColor = .lightGray
        yAxis.axisLineColor = .red
        yAxis.axisLineWidth = 3
    }
    
    private func getBmiResult() {
        weightValue = Double(weightTextField.text ?? "1") ?? 1.0
        heightValue = Double(heightTextField.text ?? "1") ?? 1.0
        let height = (heightValue / 100) * (heightValue / 100)
        var result = weightValue / height
        result = round(result * 100) / 100.0
        
        guard result > 15 && result < 70 else {
            return showErrorAlert()
        }
        
        resultValueLabel.text = "BMI: \(result)"
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
        resultValueLabel.text = ""
        bmiInfoTextView.text = dataManager.bmiInfo
        bmiCategoriesLabel.text = dataManager.bmiCategories
    }
    
}
// MARK: - Keyboard Extension
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
            title:"BMI:doneButton.ready".localized(),
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

// MARK: - Alert Extensions
extension BodyMassIndexVC {
    
    private func showAlertUpdater(with profile: Profile? = nil, completion: (() -> Void)? = nil) {
        guard let person = user?.first, user?.first?.weightHistory != nil else { return }

        let title = "BMI:alert.upd".localized()
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "BMI:alert.weight".localized() )
        
        alert.action(with: person) { newValue in
            guard let newWeight = Double(newValue) else {
                return self.showErrorAlert()
            }
            StorageManager.shared.updateWeight(user: person, newWeight: newWeight)
            self.setDataForChart()
        }
        
        present(alert, animated: true)
    }
    
    private func showAlertCreator() {
        let title = "BMI:alert.charts".localized()
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "BMI:alert.weight".localized() )
        
        alert.actionCreate { h, w in
            guard h != "", w != "" else {
                return self.showAlertCreator()
            }
            guard let height = Double(h), let weight = Double(w) else {
                return self.showAlertCreator()
            }
            DataManager.shared.createTest(weight: weight, height: height) {
                self.user = StorageManager.shared.realm.objects(Profile.self)
                self.setDataForChart()
            }
        }
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let title = "BMI:alert.wrongFormat".localized()
        let message = "BMI:alert.tryAgain".localized()
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
}
