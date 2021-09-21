//
//  DetailTaskViewController.swift
//  GymAssist
//
//  Created by Александр on 19.09.2021.
//

import RealmSwift

class DetailTaskViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var exerciseDetailLabel: UILabel!
    @IBOutlet weak var exerciseDescriptionLabel: UILabel!
    
    var usersExercises: TaskList!
    
    var timer: Timer = Timer()
    var count: Int = 0
    var timerCounting: Bool = false
    
    var names: [String] = []
    var descriptions: [String] = []
    var countExercise = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        names = getExercises(taskList: usersExercises)
        exerciseDetailLabel.text = "\n\(names[countExercise])"
        descriptions = getDescriptions(taskList: usersExercises)
        exerciseDescriptionLabel.text = "\(descriptions[countExercise])"
        
        startStopButton.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: .normal)
        startStopButton.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        resetButton.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
    }
    
    func getDescriptions(taskList: TaskList) -> [String] {
        var array: [String] = []
        for taskNote in taskList.tasks {
            array.append(taskNote.note)
        }
        return array
    }
    
    func getExercises(taskList: TaskList) -> [String] {
        var array: [String] = []
        for task in taskList.tasks {
            array.append(task.name)
        }
        return array
    }
    
    func changeExerciseNext(taskList: TaskList) -> String {
        if countExercise < (taskList.tasks.count - 1) {
            countExercise += 1
        } else {
            countExercise = 0
        }
        exerciseDescriptionLabel.text = "\(descriptions[countExercise])"
        return "\(names[countExercise])"
    }
    func changeExercisePrevious(taskList: TaskList) -> String {
        if countExercise == 0 {
            countExercise = (taskList.tasks.count - 1)
        } else {
            countExercise -= 1
        }
        exerciseDescriptionLabel.text = "\(descriptions[countExercise])"
        return "\(names[countExercise])"
    }
    
    @IBAction func startStopTapped(_ sender: Any) {
        if timerCounting {
            timerCounting = false
            timerLabel.textColor = .red
            timer.invalidate()
            startStopButton.setTitle("START", for: .normal )
            startStopButton.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
            startStopButton.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        } else {
            timerCounting = true
            startStopButton.setTitle("STOP", for: .normal)
            timerLabel.textColor = .black
            startStopButton.setTitleColor(UIColor.red, for: .normal)
            startStopButton.backgroundColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Reset timer?", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
            self.count = 0
            self.timer.invalidate()
            self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
            self.timerLabel.textColor = .black
            self.startStopButton.setTitle("START", for: .normal )
            self.startStopButton.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
            self.startStopButton.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (_) in
            // do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func nextExerciseButtonTapped(_ sender: Any) {
        let next = changeExerciseNext(taskList: usersExercises)
        exerciseDetailLabel.text = "\n\(next)"
    }
    
    @IBAction func previousExerciseButtonTapped(_ sender: Any) {
        let previous = changeExercisePrevious(taskList: usersExercises)
        exerciseDetailLabel.text = "\n\(previous)"
    }
    
    @objc func timerCounter() -> Void {
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
}
