//
//  TasksViewController.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift
import UIKit

class TasksTVC: UITableViewController {
    
    var taskList: TaskList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitleAndButton()
        setCustomFooter()
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath) as! ExerciseCell
        let task = taskList.tasks[indexPath.row]
        
        cell.configureTask(with: task)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        StorageManager.shared.move(array: taskList.tasks, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    // MARK: - TableView Delegate
    
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    // MARK: - AnotherMethods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailTaskVC = segue.destination as! DetailTaskVC
        detailTaskVC.usersExercises = taskList
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    @objc func goToDetailScreen() {
        guard !taskList.tasks.isEmpty else { return }
        performSegue(withIdentifier: "goStartTrainingSegue", sender: nil)
    }
    
    private func setNavigationTitleAndButton() {
        title = taskList.name
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(#colorLiteral(red: 0.6431372762, green: 0.6431372762, blue: 0.6431372762, alpha: 1))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(#colorLiteral(red: 0.6431373358, green: 0.6431372762, blue: 0.6431373358, alpha: 1))]
        appearance.backgroundColor = #colorLiteral(red: 0.1677677035, green: 0.1727086902, blue: 0.1726246774, alpha: 1)
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    private func setCustomFooter() {
        let superViewWidth = view.frame.size.width
        let footer = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: superViewWidth,
                                          height: superViewWidth / 5 ))
        let button = UIButton(frame: CGRect(x: superViewWidth / 4,
                                            y: 0,
                                            width: superViewWidth / 2,
                                            height: footer.frame.height))
        button.addTarget(self, action: #selector(goToDetailScreen), for: .touchUpInside)
        button.setTitle("Let's start to ROCK!", for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = #colorLiteral(red: 0.1890899241, green: 0.6003474593, blue: 0.4615892172, alpha: 1)
        footer.backgroundColor = #colorLiteral(red: 0.1677677035, green: 0.1727086902, blue: 0.1726246774, alpha: 1)
        footer.addSubview(button)
        
        tableView.tableFooterView = footer
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
