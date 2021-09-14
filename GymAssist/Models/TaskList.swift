//
//  TaskList.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift

class TaskList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    let tasks = List<Task>()
}

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
