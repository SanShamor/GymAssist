//
//  TaskListViewController.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift
import UIKit

class TaskListTVC: UITableViewController {
    
    private var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle()
        createTestData()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath) as! TaskListCell
        let taskList = taskLists[indexPath.row]
        cell.configureTaskList(with: taskList)
        
        return cell
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.4,
            delay: 0.3 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
            })
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.deleteFromRealm(type: taskList)
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
    
    // MARK: - IBAction & AnotherMethods
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    private func setNavigationTitle() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(#colorLiteral(red: 1, green: 0.1745384336, blue: 0.1752099395, alpha: 1))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(#colorLiteral(red: 1, green: 0.1745384336, blue: 0.1752099395, alpha: 1))]
        appearance.backgroundColor = #colorLiteral(red: 0.1677677035, green: 0.1727086902, blue: 0.1726246774, alpha: 1)
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
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
                StorageManager.shared.edit(type: taskList, name: newValue, note: "")
                completion()
            } else {
                self.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskList: String) {
        let taskList = TaskList(value: [taskList])
        StorageManager.shared.saveInRealm(type: taskList)
        let rowIndex = IndexPath(row: taskLists.count - 1, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }
    
}
