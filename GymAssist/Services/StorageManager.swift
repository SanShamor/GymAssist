//
//  StorageManager.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
    private func write(_ completion: () -> Void) {
        do {
            try realm.write { completion() }
        } catch  let error {
            print(error)
        }
    }
    
    func saveInRealm(type: Object) {
        write {
            realm.add(type)
        }
    }
    
    func deleteFromRealm(type: Object) {
        write {
            guard let object = type as? TaskList else { return realm.delete(type) }
            realm.delete(object.tasks)
            realm.delete(object.userHighscores)
            realm.delete(object)
        }
    }
    
    func edit(type: Object, name: String, note: String) {
        write {
            guard let object = type as? Task else {
                guard let taskList = type as? TaskList else { return }
                
                return taskList.name = name
            }
            
            object.name = name
            object.note = note
        }
    }
    
    func saveInTaskList(type: Object, taskList: TaskList) {
        write {
            guard let score = type as? Highscore else {
                guard let task = type as? Task else { return }
                
                return taskList.tasks.append(task)
            }
            
            taskList.userHighscores.append(score)
        }
    }
    
    func move(array: List<Task>, from: Int, to: Int) {
        write {
            array.move(from: from, to: to)
        }
    }
    
    func updateWeight(user: Profile, newWeight: Double) {
        write {
            user.weightHistory.append(user.weight)
            user.weight = newWeight
        }
    }
    
}

