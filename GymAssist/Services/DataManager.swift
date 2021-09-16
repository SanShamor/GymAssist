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
            
            let shoppingList = TaskList()
            shoppingList.name = "Силовая треня"
            
            let milk = Task()
            milk.name = "Milk"
            milk.note = "2L"
            
            let bread = Task(value: ["Bread", "", Date(), true])
            let apples = Task(value: ["name": "Apples", "note": "2Kg"])
            
            let moviesList = TaskList()
            moviesList.name = "Гантельная треня"
            
            let film = Task(value: ["The best of the best", "Must have", Date(), true])
            let anotherFilm = Task(value: ["name": "Best film ever"])
            
            shoppingList.tasks.append(milk)
            shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
            moviesList.tasks.insert(contentsOf: [film, anotherFilm], at: 0)
            
            DispatchQueue.main.async {
                StorageManager.shared.save(taskLists: [shoppingList, moviesList])
                completion()
                
            }
        }
        
    }
}
