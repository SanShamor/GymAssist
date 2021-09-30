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
    
    // MARK: - Work with Task Lists
    func save(taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func save(taskList: TaskList) {
        write {
            realm.add(taskList)
        }
    }
    
    func edit(taskList: TaskList, newValue: String) {
        write {
            taskList.name = newValue
        }
    }
    
    func delete(taskList: TaskList) {
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
        }
    }
    
    func done(taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    // MARK: - Work with tasks
    func save(task: Task, in taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func delete(task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func edit(task: Task, name: String, note: String) {
        write {
            task.name = name
            task.note = note
        }
    }
    
    func done(task: Task) {
        write {
            task.isComplete.toggle()
        }
    }
    
    private func write(_ completion: () -> Void) {
        do {
            try realm.write { completion() }
        } catch  let error {
            print(error)
        }
    }
    // MARK: - Work with Highscores
    func save(highscore: Highscore, in taskList: TaskList) {
        write {
            taskList.userHighscores.append(highscore)
        }
    }
    
    func edit(highscore: Highscore){
        write {
            realm.delete(highscore)
        }
    }
    
}

