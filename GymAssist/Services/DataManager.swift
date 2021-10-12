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
    
    func createTempData(_ completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            
            UserDefaults.standard.set(true, forKey: "done")
            
            let cardioTraining = TaskList()
            cardioTraining.name = "Кардио + пресс"
            let jogging = Task(value: ["name": "Бег", "note": "5км"])
            let twisting = Task(value: ["name": "Русские скручивания", "note": "10 + 10"])
            let legsUp = Task(value: ["name": "Подъем ног", "note": "12х"])
            let burpee = Task(value: ["name": "Бёрпи", "note": "12х"])
            
            let strengthTraining = TaskList()
            strengthTraining.name = "Силовая тренировка"
            let barbellBench = Task(value: ["name": "Жим штанги", "note": "5 + 5 12х"])
            let pullUp = Task(value: ["name": "Подтягивания", "note": "10х"])
            let swingKettlebell = Task(value: ["name": "Махи гирей", "note": "35кг 12х"])
            let kickBacks = Task(value: ["name": "Гантели-трицепс", "note": "8кг 12х"])
            let extensionTwists = Task(value: ["name": "Обр.хват-трицепс", "note": "6кг 12х"])
            
            cardioTraining.tasks.insert(contentsOf: [jogging, twisting, legsUp, burpee], at: 0)
            strengthTraining.tasks.insert(contentsOf: [barbellBench, pullUp, swingKettlebell, kickBacks, extensionTwists], at: 0)
            
            DispatchQueue.main.async {
                StorageManager.shared.save(taskLists: [cardioTraining, strengthTraining])
                completion()
                
            }
        }
        
    }
}
