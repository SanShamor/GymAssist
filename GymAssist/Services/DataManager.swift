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
            cardioTraining.name = "Разминка"
            let headRotation = Task(value: ["name": "Вращения головой", "note": "10х"])
            let shoulders = Task(value: ["name": "Вращения локтями", "note": "12х"])
            let handsUp = Task(value: ["name": "Махи руками", "note": "12х"])
            let hipJoint = Task(value: ["name": "Вращение тазом", "note": "30 секунд"])
            let bendsToLegs = Task(value: ["name": "Наклоны к ногам", "note": "7х к каждой ноге"])
            let swingLegs = Task(value: ["name": "Махи ногами", "note": "12х"])
            let sideLunges = Task(value: ["name": "Боковые выпады", "note": "12х"])

            
            let strengthTraining = TaskList()
            strengthTraining.name = "Силовая тренировка"
            let barbellBench = Task(value: ["name": "Жим штанги", "note": "5кг + 5кг\n12х"])
            let pullUp = Task(value: ["name": "Подтягивания", "note": "10х"])
            let swingKettlebell = Task(value: ["name": "Махи гирей", "note": "35кг\n12х"])
            let kickBacks = Task(value: ["name": "Гантели-трицепс", "note": "6кг в руку\n12х"])
            let extensionTwists = Task(value: ["name": "Обр.хват-трицепс", "note": "6кг\n12х"])
            
            cardioTraining.tasks.insert(contentsOf: [headRotation, shoulders, handsUp, hipJoint, bendsToLegs, swingLegs, sideLunges], at: 0)
            strengthTraining.tasks.insert(contentsOf: [barbellBench, pullUp, swingKettlebell, kickBacks, extensionTwists], at: 0)
            
            DispatchQueue.main.async {
                StorageManager.shared.save(taskLists: [cardioTraining, strengthTraining])
                completion()
                
            }
        }
        
    }
}
