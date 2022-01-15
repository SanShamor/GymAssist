//
//  TaskList.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift

class TaskList: Object {
    @Persisted var name = ""
    @Persisted var userHighscores = List<Highscore>()
    @Persisted var tasks = List<Task>()
}

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
}

class Highscore: Object {
    @Persisted var totalTime = ""
    @Persisted var date = Date()
}
