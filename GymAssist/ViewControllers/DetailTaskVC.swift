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
    var currentTaskList: TaskList!
    private var exerciseNames: [String] = []
    private var exerciseDescription: [String] = []
    private var lapsResults: [String] = []
    private var exercisePositionInList = 0
    private var roundsCount = 1
    private var finishedRounds = 0
    
    private var startTime: Date?
    private var stopTime: Date?
    private var lapStartTime = Date()
    private var lapStopTime = Date()
    
    private let userDefaults = UserDefaults.standard
    private let START_TIME_KEY = "startTime"
    private let STOP_TIME_KEY = "stopTime"
    private let COUNTING_KEY = "countingKey"
    private var timerCounting: Bool = false
    private var scheduledTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerCounting = userDefaults.bool(forKey: COUNTING_KEY)
        
        setStartValues()
        setDefaultUI()
        
        if timerCounting {
            startTimer()
        } else {
            //если таймер был уже запущен, но остановлен
            stopTimer()
            guard let start = startTime else { return }
            guard let stop = stopTime else { return }
            let time = calcRestartTime(start: start, stop: stop)
            let diff = Date().timeIntervalSince(time)
            setTimerLabel(Int(diff))
        }
        
    }
    
    // MARK: - IBActions
    @IBAction func startStopButtonTapped(_ sender: Any) {
        
        if timerCounting {
            setStopTime(date: Date())
            lapStopTime = Date()
            stopTimer()
            setUIWhenTimerStop()
        } else {
            //Продолжить таймер после паузы
            if let stop = stopTime {
                let restartTime = calcRestartTime(start: startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
                let restartLapTime = calcRestartTime(start: lapStartTime, stop: lapStopTime)
                lapStartTime = restartLapTime
            } else {
                //Запустить таймер с нуля
                setStartTime(date: Date())
                lapStartTime = startTime ?? Date()
            }
            
            startTimer()
        }
    }
    
    @IBAction func saveHighscoreButtonPressed(_ sender: Any) {
        let time = getTimerResultValue()
        saveHighscore(withTime: time)
        saveResultButton.isHidden = true
        
        let alert = UIAlertController(title: "Saved successfully", message: "You can find it at results-screen", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            // do nothing
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Reset timer?", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
            self.setStopTime(date: nil)
            self.setStartTime(date: nil)
            self.stopTimer()
            self.setDefaultUI()
            self.setStartValues()
            self.resetTimerButton.isHidden = true
            
            self.timerLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            self.startStopTimerButton.backgroundColor = #colorLiteral(red: 0.1900779605, green: 0.5983788371, blue: 0.4619213343, alpha: 1)
            self.startStopTimerButton.setTitle("START", for: .normal )
            self.timerLabel.text = self.makeTimeString(hour: 0, min: 0, sec: 0)
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
            changeExerciseNext(taskList: currentTaskList)
        }
    }
    
    @IBAction func previousExerciseButtonTapped(_ sender: Any) {
        changeExercisePrevious(taskList: currentTaskList)
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
    
    // MARK: Methods for Timer
    @objc func refreshValue() {
        if let start = startTime {
            let diff = Date().timeIntervalSince(start)
            setTimerLabel(Int(diff))
        } else {
            stopTimer()
            setTimerLabel(0)
        }
    }
    
    func startTimer() {
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimerCounting(true)
        setUIWhenTimerRun()
    }
    
    func stopTimer() {
        if scheduledTimer != nil {
            scheduledTimer.invalidate()
        }
        setTimerCounting(false)
    }
    
    func setTimerLabel(_ val: Int) {
        let time = secondsToHoursMinutesSeconds(val)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        timerLabel.text = timeString
    }
    
    func secondsToHoursMinutesSeconds(_ ms: Int) -> (Int, Int, Int) {
        let hour = ms / 3600
        let min = (ms % 3600) / 60
        let sec = (ms % 3600) % 60
        return (hour, min, sec)
    }
    
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hour)
        timeString += " : "
        timeString += String(format: "%02d", min)
        timeString += " : "
        timeString += String(format: "%02d", sec)
        return timeString
    }
    
    func calcRestartTime(start: Date, stop: Date) -> Date {
        let diff = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(diff)
    }
    
    func setStartTime(date: Date?) {
        startTime = date
        userDefaults.set(date, forKey: START_TIME_KEY)
    }
    
    func setStopTime(date: Date?) {
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
    }
    
    func setTimerCounting(_ val: Bool) {
        timerCounting = val
        userDefaults.set(timerCounting, forKey: COUNTING_KEY)
    }
    
    private func getTimerResultValue() -> String {
        guard let start = startTime else { return "Time-Eror" }
        guard let stop = stopTime else { return "Time-Eror" }
        let time = calcRestartTime(start: start, stop: stop)
        let diff = Date().timeIntervalSince(time)
        let detailTime = secondsToHoursMinutesSeconds(Int(diff))
        let timeInString = makeTimeString(hour: detailTime.0, min: detailTime.1, sec: detailTime.2)
        
        return timeInString
    }
    
    private func saveLapTime() {
        let time = calcRestartTime(start: lapStartTime, stop: stopTime ?? Date())
        let diff = Date().timeIntervalSince(time)
        let detailTime = secondsToHoursMinutesSeconds(Int(diff))
        
        let msAll = Int(diff * (Double(1000)))
        let msRemain = (msAll % 1000) / 10
        let timeInString = makeTimeString(hour: detailTime.0, min: detailTime.1, sec: detailTime.2)
        let roundResult = "\(finishedRounds)) \(timeInString).\(String(format: "%02d", msRemain))"
        
        lapsResults.append(roundResult)
        lapStartTime = Date()
    }
    
    // MARK: Methods for UI
    private func setUIWhenTimerStop() {
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
    
    private func setUIWhenTimerRun() {
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
    
    private func setDefaultUI() {
        saveResultButton.isHidden = true
        nextExerciseButton.isHidden = true
        previousExerciseButton.isHidden = true
        timerLabel.isHidden = false
        startStopTimerButton.isHidden = false
        addRoundButton.isHidden = false
        subRoundButton.isHidden = false
        roundsCountLabel.isHidden = false
        userScoreLabel.isHidden = false
        
        exerciseNameLabel.isHidden = false
        exerciseDescriptionTextView.isHidden = false
        resetTimerButton.isHidden = false
        startStopTimerButton.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: .normal)
        startStopTimerButton.backgroundColor = #colorLiteral(red: 0.1900779605, green: 0.5983788371, blue: 0.4619213343, alpha: 1)
        resetTimerButton.backgroundColor = #colorLiteral(red: 0.9988579154, green: 0.1766675115, blue: 0.1742589176, alpha: 1)
    }
    
    // MARK: Methods
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
    
    private func calculatingRounds() {
        roundsCount = Int(String(roundsCountLabel.text ?? "1")) ?? 1
    }
    
    private func roundComparison() -> Bool {
        finishedRounds < roundsCount
    }
    
    private func setStartValues() {
        exerciseNames = getExercises(taskList: currentTaskList)
        exerciseDescription = getDescriptions(taskList: currentTaskList)
        exerciseNameLabel.text = (exerciseNames[exercisePositionInList])
        exerciseDescriptionTextView.text = (exerciseDescription[exercisePositionInList])
        
        exercisePositionInList = 0
        roundsCount = 1
        lapsResults = []
        finishedRounds = 0
        userScoreLabel.text = "Rounds:"
        roundsCountLabel.text = String(roundsCount)
    }
    
    private func getExercises(taskList: TaskList) -> [String] {
        var array: [String] = []
        for task in taskList.tasks {
            array.append(task.name)
        }
        return array
    }
    
    private func getDescriptions(taskList: TaskList) -> [String] {
        var allDescriptionOfNotes: [String] = []
        
        for taskNote in taskList.tasks {
            allDescriptionOfNotes.append(taskNote.note)
        }
        return allDescriptionOfNotes
    }
    
    private func getLapResults() -> String {
        var lapsInfo = ""
        for lap in lapsResults {
            lapsInfo += "\n\(lap)"
        }
        return lapsInfo
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
        setStopTime(date: lapStartTime)
        let timeString = getTimerResultValue()
        exerciseNameLabel.text = "Тренировка окончена\n\(timeString)"
        let lapsResult = getLapResults()
        exerciseDescriptionTextView.text = "\(lapsResult)"
        saveResultButton.isHidden = false
        startStopTimerButton.isHidden = true
        timerLabel.isHidden = true
        resetTimerButton.isHidden = true
        userScoreLabel.isHidden = true
        
        stopTimer()
        setUIWhenTimerStop()
    }
    
}
// MARK: Extension
extension DetailTaskVC {
    private func saveHighscore(withTime timeResult: String) {
        let result = Highscore()
        result.totalTime = timeResult
        StorageManager.shared.saveInTaskList(type: result, taskList: currentTaskList)
    }
}
