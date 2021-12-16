//
//  DetailTaskViewController.swift
//  GymAssist
//
//  Created by Александр on 19.09.2021.
//

import RealmSwift

class DetailTaskVC: UIViewController {
    
    // MARK: - IBOuthlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startStopTimerButton: UIButton!
    @IBOutlet weak var resetTimerButton: UIButton!
    @IBOutlet weak var saveResultButton: UIButton!
    
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseDescriptionTextView: UITextView!
    
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var roundsCountLabel: UILabel!
    @IBOutlet weak var addRoundButton: UIButton!
    @IBOutlet weak var subRoundButton: UIButton!
    @IBOutlet weak var nextExerciseButton: UIButton!
    @IBOutlet weak var previousExerciseButton: UIButton!
    
    // MARK: - Properties
    var usersExercises: TaskList!
    private var lapsResults: [String] = []
    private var exerciseNames: [String] = []
    private var exerciseDescription: [String] = []
    private var exercisePositionInList = 0
    private var roundsCount = 1
    private var finishedRounds = 0
    
    private var timerTotal: Timer = Timer()
    private var countTimerTotal = 0
    private var countTimerForLap = 0
    private var timerTotalCountingIsWorking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseNames = getExercises(taskList: usersExercises)
        exerciseDescription = getDescriptions(taskList: usersExercises)
        setStartValue()
                
        startStopTimerButton.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: .normal)
        startStopTimerButton.backgroundColor = #colorLiteral(red: 0.1900779605, green: 0.5983788371, blue: 0.4619213343, alpha: 1)
        resetTimerButton.backgroundColor = #colorLiteral(red: 0.9988579154, green: 0.1766675115, blue: 0.1742589176, alpha: 1)
    }
    
    // MARK: - IBActions
    @IBAction func startStopButtonTapped(_ sender: Any) {
        
        if timerTotalCountingIsWorking {
            stoppingTimer()
            setInterfaceWhenTimerStop()
            timerTotalCountingIsWorking = false
        } else {
            timerTotalCountingIsWorking = true
            setInterfaceWhenTimerRun()
            timerTotal = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true
            )
        }
    }
    
    @IBAction func saveHighscoreButtonPressed(_ sender: Any) {
        let time = getTimerResultValue()
        saveHighscore(withTime: time)
        saveResultButton.isHidden = true
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Reset timer?", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
            self.timerTotal.invalidate()
            self.resetValues()
            self.countTimerTotal = 0
            
            self.timerLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            self.startStopTimerButton.backgroundColor = #colorLiteral(red: 0.1900779605, green: 0.5983788371, blue: 0.4619213343, alpha: 1)
            self.startStopTimerButton.setTitle("START", for: .normal )
            self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
            self.startStopTimerButton.setTitleColor(
                #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: { (_) in
            // nothing
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
        changeExercisePrevious(taskList: usersExercises)
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
    
    // MARK: - Timer's Methods
    @objc func timerCounter() -> Void {
        countTimerTotal = countTimerTotal + 1
        countTimerForLap = countTimerForLap + 1
        let time = secondsToHoursMinutesSeconds(seconds: countTimerTotal)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
    }
    
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
        timerTotal.invalidate()
    }
    
    private func setInterfaceWhenTimerStop() {
        resetTimerButton.isHidden = false
        addRoundButton.isHidden = true
        subRoundButton.isHidden = true
        nextExerciseButton.isHidden = true
        previousExerciseButton.isHidden = true
        roundsCountLabel.isHidden = true
        
        timerLabel.textColor = .red
        startStopTimerButton.backgroundColor = #colorLiteral(red: 0.1900779605, green: 0.5983788371, blue: 0.4619213343, alpha: 1)
        startStopTimerButton.setTitle("Resume", for: .normal )
        startStopTimerButton.setTitleColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), for: .normal)
    }
    
    private func setInterfaceWhenTimerRun() {
        addRoundButton.isHidden = true
        subRoundButton.isHidden = true
        resetTimerButton.isHidden = true
        nextExerciseButton.isHidden = false
        userScoreLabel.isHidden = false
        roundsCountLabel.isHidden = true
        
        timerLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        startStopTimerButton.backgroundColor = #colorLiteral(red: 1, green: 0.1745384336, blue: 0.1752099395, alpha: 1)
        startStopTimerButton.setTitle("STOP", for: .normal)
        startStopTimerButton.setTitleColor(#colorLiteral(red: 0.3180879951, green: 0.07594271749, blue: 0.02917674743, alpha: 1), for: .normal)
        userScoreLabel.text = "Закончено раундов: \(String(finishedRounds))/\(roundsCount)"
        
        if exercisePositionInList != 0 {
            previousExerciseButton.isHidden = false
        }
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
        if exercisePositionInList < (taskList.tasks.count - 1) {
            exercisePositionInList += 1
            previousExerciseButton.isHidden = false
            exerciseDescriptionTextView.text = (exerciseDescription[exercisePositionInList])
            exerciseNameLabel.text = (exerciseNames[exercisePositionInList])
        } else {
            finishRound()
            saveLapTime()
            if !roundComparison() {
                finishWorkout()
            }
        }
        
    }
    
    private func changeExercisePrevious(taskList: TaskList) {
        exercisePositionInList -= 1
        exerciseNameLabel.text = (exerciseNames[exercisePositionInList])
        exerciseDescriptionTextView.text = (exerciseDescription[exercisePositionInList])
        if exercisePositionInList == 0 {
            previousExerciseButton.isHidden = true
        }
    }
    
    private func setStartValue() {
        exercisePositionInList = 0
        roundsCount = 1
        lapsResults = []
        roundsCountLabel.text = String(roundsCount)
        exerciseNameLabel.text = (exerciseNames[exercisePositionInList])
        exerciseDescriptionTextView.text = (exerciseDescription[exercisePositionInList])
    }
    
    private func resetValues() {
        setStartValue()
        finishedRounds = 0
        userScoreLabel.text = ""
        
        timerLabel.isHidden = false
        saveResultButton.isHidden = true
        nextExerciseButton.isHidden = true
        previousExerciseButton.isHidden = true
        resetTimerButton.isHidden = true
        startStopTimerButton.isHidden = false
        addRoundButton.isHidden = false
        subRoundButton.isHidden = false
        roundsCountLabel.isHidden = false
    }
    
    private func finishRound() {
        finishedRounds += 1
        exercisePositionInList = 0
        previousExerciseButton.isHidden = true
        exerciseNameLabel.text = (exerciseNames[exercisePositionInList])
        exerciseDescriptionTextView.text = (exerciseDescription[exercisePositionInList])
        userScoreLabel.text = "Закончено раундов: \(String(finishedRounds))/\(roundsCount)"
    }
    
    private func finishWorkout() {
        let totalWorkoutTime = getTimerResultValue()
        let lapsResult = showTimeResultInLabel()
        exerciseNameLabel.text = "Тренировка окончена\n\(totalWorkoutTime)"
        exerciseDescriptionTextView.text = "\(lapsResult)"
        saveResultButton.isHidden = false
        timerTotalCountingIsWorking = false
        startStopTimerButton.isHidden = true
        timerLabel.isHidden = true
        resetTimerButton.isHidden = true
        userScoreLabel.isHidden = true
        
        stoppingTimer()
        setInterfaceWhenTimerStop()
    }
    
    private func saveLapTime() {
        let time = secondsToHoursMinutesSeconds(seconds: countTimerForLap)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        let roundResult = "\(finishedRounds)) \(timeString)"
        lapsResults.append(roundResult)
        countTimerForLap = 0
    }
    
    private func getTimerResultValue() -> String {
        let time = secondsToHoursMinutesSeconds(seconds: countTimerTotal)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        return timeString
    }
    
    private func showTimeResultInLabel() -> String {
        var lapsInfo = ""
        for lap in lapsResults {
            lapsInfo += "\n\(lap)"
        }
        return lapsInfo
    }
    
}

extension DetailTaskVC {
    private func saveHighscore(withTime timeResult: String) {
        let result = Highscore()
        result.totalTime = timeResult
        StorageManager.shared.save(highscore: result, in: usersExercises)
    }
}
