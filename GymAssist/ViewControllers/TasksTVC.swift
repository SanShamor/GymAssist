//
//  TasksViewController.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift

class TasksTVC: UITableViewController {
    
    var taskList: TaskList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.tasks.count
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
       // let currentTrack = trackList.remove(at: sourceIndexPath.row)
       // trackList.insert(currentTrack, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let task = taskList.tasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = taskList.tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: task) {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailTaskVC = segue.destination as! DetailTaskVC
        detailTaskVC.usersExercises = taskList
        
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
}

extension TasksTVC {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Изменение задачи" : "Новое упражнение"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Введите данные")
        
        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task: task, name: newValue, note: note)
                completion()
            } else {
                self.saveTask(withName: newValue, andNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        StorageManager.shared.save(task: task, in: taskList)
        let rowIndex = IndexPath(row: taskList.tasks.count - 1 , section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}
