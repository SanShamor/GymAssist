//
//  TaskListCell.swift
//  GymAssist
//
//  Created by Александр on 13.12.2021.
//

import UIKit

class TaskListCell: UITableViewCell {

    @IBOutlet weak var nameTaskListLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureTaskList(with taskList: TaskList) {
        let userTasks = taskList.tasks
        nameTaskListLabel.text = taskList.name
        nameTaskListLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        if !userTasks.isEmpty {
            infoLabel.text = "\(userTasks.count)"
            infoLabel.textColor = #colorLiteral(red: 0.190195173, green: 0.5983567834, blue: 0.4619839787, alpha: 1)
        } else {
            infoLabel.text = "0"
            infoLabel.textColor = #colorLiteral(red: 0.9989104867, green: 0.1764889061, blue: 0.1743151546, alpha: 1)
        }
    }
    
}
