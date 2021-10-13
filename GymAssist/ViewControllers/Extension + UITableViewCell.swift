//
//  Extension + UITableViewCell.swift
//  GymAssist
//
//  Created by Александр on 16.09.2021.
//

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let userTasks = taskList.tasks
        var content = defaultContentConfiguration()
        
        content.text = taskList.name
        
        if !userTasks.isEmpty {
            content.secondaryText = "\(userTasks.count)"
            accessoryType = .none
        } else {
            accessoryType = .none
            content.secondaryText = "0"
        }
        
        contentConfiguration = content
    }
}
