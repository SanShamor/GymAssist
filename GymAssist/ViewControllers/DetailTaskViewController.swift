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
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var roundsCountLabel: UILabel!
    @IBOutlet weak var addRoundButton: UIButton!
    @IBOutlet weak var subRoundButton: UIButton!
    @IBOutlet weak var nextExerciseButton: UIButton!
    @IBOutlet weak var previousExerciseButton: UIButton!
    
    var usersExercises: TaskList!
    var timeResultsOfTaskList: [String] = []
    private var exerciseNames: [String] = []
    private var exerciseDescription: [String] = []
    private var exerciseNumberInList = 0
    private var roundsCount = 1
    private var finishedRounds = 0
    
    private var timer: Timer = Timer()
    private var timerLap: Timer = Timer()
    private var count = 0
    private var countLap = 0
    private var timerCounting = false
    private var timerLapCounting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseNames = getExercises(taskList: usersExercises)
        exerciseDescription = getDescriptions(taskList: usersExercises)
        startingValue()
                
        startStopButton.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: .normal)
        startStopButton.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        resetButton.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
    }
    // MARK: - IBActions
    
    @IBAction func startStopTapped(_ sender: Any) {
        resetButton.isHidden = true
        
        if timerCounting {
            timerLapCounting = false
            stoppingTimer()
            resetButton.isHidden = false
        } else {
            addRoundButton.isHidden = true
            subRoundButton.isHidden = true
            nextExerciseButton.isHidden = false
            
            if exerciseNumberInList != 0 {
                previousExerciseButton.isHidden = false
            }
            
            timerCounting = true
            timerLapCounting = true
            startStopButton.setTitle("STOP", for: .normal)
            timerLabel.textColor = .black
            startStopButton.setTitleColor(UIColor.red, for: .normal)
            startStopButton.backgroundColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            //timerLap = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerLapCounter), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Reset timer?", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
            self.count = 0
            self.timer.invalidate()
            self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
            
            self.resetValues()
            
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
        calculatingRounds()
        if roundComparison() {
            changeExerciseNext(taskList: usersExercises)
        }
    }
    
    @IBAction func previousExerciseButtonTapped(_ sender: Any) {
        let previous = changeExercisePrevious(taskList: usersExercises)
        exerciseDetailLabel.text = previous
    }
    
    @IBAction func addRoundButtonTapped(_ sender: Any) {
        roundsCount += 1
        roundsCountLabel.text = String(roundsCount)
    }
    @IBAction func subRoundButtonTapped(_ sender: Any) {
        if roundsCount > 1 {
            roundsCount -= 1
            roundsCountLabel.text = String(roundsCount)
        }
    }
    
    // MARK: - Timer Methods
    @objc func timerCounter() -> Void {
        count = count + 1
        countLap = countLap + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
    }
    /*
    @objc func timerLapCounter() -> Void {
        countLap = countLap + 1
        let time = secondsToHoursMinutesSeconds(seconds: countLap)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
    }
    */
    private func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    private func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    private func stoppingTimer() {
        timerCounting = false
        timerLabel.textColor = .red
        timer.invalidate()
        startStopButton.setTitle("Resume", for: .normal )
        startStopButton.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
        startStopButton.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        
        resetButton.isHidden = false
        addRoundButton.isHidden = true
        subRoundButton.isHidden = true
        nextExerciseButton.isHidden = true
        previousExerciseButton.isHidden = true
        roundsCountLabel.isHidden = true
    }
    
    private func lapTimer() {
        timerLap.invalidate()
    }
    
    // MARK: - Methods
    private func getDescriptions(taskList: TaskList) -> [String] {
        var allDescriptionOfNotes: [String] = []
        
        for taskNote in taskList.tasks {
            allDescriptionOfNotes.append(taskNote.note)
        }
        return allDescriptionOfNotes
    }
    
    private func getExercises(taskList: TaskList) -> [String] {
        var array: [String] = []
        for task in taskList.tasks {
            array.append(task.name)
        }
        return array
    }
    
    private func calculatingRounds() {
        roundsCount = Int(String(roundsCountLabel.text ?? "1")) ?? 1
    }
    
    private func roundComparison() -> Bool {
        finishedRounds < roundsCount
    }
    
    private func changeExerciseNext(taskList: TaskList) {
       
        if exerciseNumberInList < (taskList.tasks.count - 1) {
            exerciseNumberInList += 1
            previousExerciseButton.isHidden = false
            exerciseDescriptionLabel.text = (exerciseDescription[exerciseNumberInList])
            exerciseDetailLabel.text = (exerciseNames[exerciseNumberInList])
        } else {
            exerciseNumberInList = 0
            previousExerciseButton.isHidden = true
            finishedRounds += 1
            scoreLabel.text = "Закончено раундов: \(String(finishedRounds))/\(roundsCount)"
            exerciseDescriptionLabel.text = (exerciseDescription[exerciseNumberInList])
            exerciseDetailLabel.text = (exerciseNames[exerciseNumberInList])
            
            finishTheTaskList()
            
            if roundComparison() == false {
                let result = getTimerResultValue()
                let lapsResult = showResult()
                exerciseDescriptionLabel.text = "Потрачено \n\(result) \(lapsResult)"
                stoppingTimer()
                startStopButton.isHidden = true
            }
        }
        
    }
    
    private func changeExercisePrevious(taskList: TaskList) -> String {
        if exerciseNumberInList == 0 {
            exerciseNumberInList = (taskList.tasks.count - 1)
        } else {
            exerciseNumberInList -= 1
        }
        exerciseDescriptionLabel.text = (exerciseDescription[exerciseNumberInList])
        return exerciseNames[exerciseNumberInList]
    }
    
    private func resetValues() {
        self.finishedRounds = 0
        self.scoreLabel.text = ""
        
        self.addRoundButton.isHidden = false
        self.subRoundButton.isHidden = false
        self.startStopButton.isHidden = false
        self.roundsCountLabel.isHidden = false
        self.nextExerciseButton.isHidden = true
        self.previousExerciseButton.isHidden = true
        self.resetButton.isHidden = true
        
        self.startingValue()
    }
    
    private func startingValue() {
        exerciseNumberInList = 0
        roundsCount = 1
        
        roundsCountLabel.text = String(roundsCount)
        exerciseDetailLabel.text = (exerciseNames[exerciseNumberInList])
        exerciseDescriptionLabel.text = (exerciseDescription[exerciseNumberInList])
    }
    
    private func finishTheTaskList() {
        let time = secondsToHoursMinutesSeconds(seconds: countLap)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        let roundResult = "\(finishedRounds)) \(timeString)"
        timeResultsOfTaskList.append(roundResult)
        countLap = 0
    }
    
    private func getTimerResultValue() -> String {
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        return timeString
    }
    
    private func showResult() -> String {
        var lapsInfo = ""
        for lap in timeResultsOfTaskList {
            lapsInfo += "\n\(lap)"
        }
        return lapsInfo
    }
    
    private func saveResult() {
        
    }
    
}
