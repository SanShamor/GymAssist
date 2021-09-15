//
//  TasksViewController.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift

class TasksViewController: UITableViewController {

    //var taskList: TaskList!
    
    //private var currentTasks: Results<Task>!
    //private var completedTasks: Results<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //title = taskList.name
        //currentTasks = taskList.tasks.filter("isComplete = false")
        //completedTasks = taskList.tasks.filter("isCompleted = true")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        0
        //2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
        //section == 0 ? currentTasks.count : completedTasks.count
    }
    
    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "ТЕКУЩИЕ УПРАЖНЕНИЯ" : "ВЫПОЛНЕННЫЕ УПРАЖНЕНИЯ"
    }
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        //let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        //var content = cell.defaultContentConfiguration()
        //content.text = task.name
        //content.secondaryText = task.note
        //cell.contentConfiguration = content
        return cell
    }
    
    private func addButtonPressed() {
        showAlert()
    }

    
}

extension TasksViewController {
    
    private func showAlert() {
        
        let alert = AlertController(title: "Новое упражненик", message: "Что вы хотите добавить?", preferredStyle: .alert)
        
        alert.action { newValue, note in
            
        }
        
        present(alert, animated: true)
    }
}
