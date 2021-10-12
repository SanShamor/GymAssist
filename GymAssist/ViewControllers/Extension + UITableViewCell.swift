//
//  Extension + UITableViewCell.swift
//  GymAssist
//
//  Created by Александр on 16.09.2021.
//

import UIKit

extension UITableViewCell {
    func config≠ure(with taskList: TaskList) {
        let currentTasks = taskList.tasks.filter("isComplete = false")
        let completeTasks = taskList.tasks.filter("isComplete = true")
        var content = defaultContentConfiguration()
        
        content.text = taskList.name
        
        if !currentTasks.isEmpty {
            content.secondaryText = "\(currentTasks.count)"
            accessoryType = .none
        } else if !completeTasks.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            accessoryType = .none
            content.secondaryText = "0"
        }
        
        contentConfiguration = content
    }
}
