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
            
            let jogging = Task()
            jogging.name = "Бег"
            jogging.note = "5км"
            
            let twisting = Task(value: ["Русские скручивания", "10 + 10", Date(), true])
            let apples = Task(value: ["name": "Подъем ног", "note": "12"])
            
            let strengthTraining = TaskList()
            strengthTraining.name = "Треня на руки"
            
            let barbellBench = Task(value: ["Жим штанги", "5 + 5", Date(), true])
            let anotherFilm = Task(value: ["name": "Подтягивания", "note": "10"])
            
            cardioTraining.tasks.append(jogging)
            cardioTraining.tasks.insert(contentsOf: [twisting, apples], at: 1)
            strengthTraining.tasks.insert(contentsOf: [barbellBench, anotherFilm], at: 0)
            
            DispatchQueue.main.async {
                StorageManager.shared.save(taskLists: [cardioTraining, strengthTraining])
                completion()
                
            }
        }
        
    }
}
