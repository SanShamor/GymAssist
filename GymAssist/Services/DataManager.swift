//
//  DataManager.swift
//  GymAssist
//
//  Created by Александр on 16.09.2021.
//

import Foundation

class DataManager {
    
    static let shared = DataManager()
    
    private init() {}
    
    let bmiInfo = "DataManager:BMI.info".localized()
    
    let bmiCategories = """
         BMI           Соответствие
        16,00 — 18,49 Недостаточная масса
        18,50 — 24,99 Норма
        25,00 — 29,99 Предожирение
        30,00 — 34,99 Ожирение 1 степени
        35,00 — 49,99 Ожирение 2 степени
        """
    
    //Testing
    func createTest(weight: Double?, height: Double?, completion: @escaping () -> Void) {
            UserDefaults.standard.set(true, forKey: "ProfileDone")
            
            let userProfileTest = Profile()
            userProfileTest.weight = weight ?? 0
            userProfileTest.height = height ?? 0
            
            DispatchQueue.main.async {
                StorageManager.shared.saveInRealm(type: userProfileTest)
                completion()
            }
    }
    
        func createTempData(_ completion: @escaping () -> Void) {
            if !UserDefaults.standard.bool(forKey: "done") {
                
                UserDefaults.standard.set(true, forKey: "done")
                
                let cardioTraining = TaskList()
                cardioTraining.name = "DataManager:training1.name".localized()
                let headRotation = Task(value: ["name": "DataManager:1-1".localized(), "note": "10х"])
                let shoulders = Task(value: ["name": "DataManager:1-2".localized(), "note": "12х"])
                let handsUp = Task(value: ["name": "DataManager:1-3".localized(), "note": "12х"])
                let hipJoint = Task(value: ["name": "DataManager:1-4".localized(), "note": "30 sec"])
                let bendsToLegs = Task(value: ["name": "DataManager:1-5".localized(), "note": "7х"])
                let swingLegs = Task(value: ["name": "DataManager:1-6".localized(), "note": "12х"])
                let sideLunges = Task(value: ["name": "DataManager:1-7".localized(), "note": "12х"])
                
                
                let strengthTraining = TaskList()
                strengthTraining.name = "DataManager:training2.name".localized()
                let barbellBench = Task(value: ["name": "DataManager:2-1".localized(), "note": "5kg + 5kg\n12х"])
                let pullUp = Task(value: ["name": "DataManager:2-2".localized(), "note": "10х"])
                let swingKettlebell = Task(value: ["name": "DataManager:2-3".localized(), "note": "35kg\n12х"])
                let kickBacks = Task(value: ["name": "DataManager:2-4".localized(), "note": "6kg \n12х"])
                let extensionTwists = Task(value: ["name": "DataManager:2-5".localized(), "note": "6kg\n12х"])
                
                cardioTraining.tasks.insert(contentsOf: [headRotation, shoulders, handsUp, hipJoint, bendsToLegs, swingLegs, sideLunges], at: 0)
                strengthTraining.tasks.insert(contentsOf: [barbellBench, pullUp, swingKettlebell, kickBacks, extensionTwists], at: 0)
                
                DispatchQueue.main.async {
                    StorageManager.shared.saveInRealm(type: cardioTraining)
                    StorageManager.shared.saveInRealm(type: strengthTraining)
                    completion()
                }
            }
            
        }
    
}
