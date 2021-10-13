//
//  TaskListViewController.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift

class TaskListTVC: UITableViewController {

    private var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        createTestData()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        //content.text = taskList.name
        return cell
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(taskList: taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: taskList) {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        
        editAction.backgroundColor = .orange
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksTVC else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList
    }
    

    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
            ? taskLists.sorted(byKeyPath: "name")
            : taskLists.sorted(byKeyPath: "date")
        tableView.reloadData()
    }
    
    private func createTestData() {
        DataManager.shared.createTempData {
            self.tableView.reloadData()
        }
    }
    
}

extension TaskListTVC {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Изменить программу" : "Новая программа"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Укажите название тренировки")
        
        alert.action(with: taskList) { newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, newValue: newValue)
                completion()
            } else {
                self.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskList: String) {
        let taskList = TaskList(value: [taskList])
        StorageManager.shared.save(taskList: taskList)
        let rowIndex = IndexPath(row: taskLists.count - 1, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
}
