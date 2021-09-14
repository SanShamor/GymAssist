//
//  TaskListViewController.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import RealmSwift

class TaskListViewController: UITableViewController {

    private var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()

        taskLists = StorageManager.shared.realm.objects(TaskList.self)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let taskList = taskLists[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = taskList.name
        content.secondaryText = "\(taskList.tasks.count)"
        cell.contentConfiguration = content
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    private func createTestData() {
        let shoppingList = TaskList()
        shoppingList.name = "Силовая треня"
        
        let moviesList = TaskList(value: ["Кардио треня", Date(), [["Best film ever"], ["The best of the best", "Must have", Date(), true]]])
        
        let milk = Task()
        milk.name = "Гантели"
        milk.note = "8Kg"
        
        let bread = Task(value: ["Подтягивания", "", Date(), true])
        let apples = Task(value: ["name": "Жим штанги", "note": "10Kg"])
        
        shoppingList.tasks.append(milk)
        shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
        
        DispatchQueue.main.async {
            StorageManager.shared.save(taskLists: [shoppingList, moviesList])
        }
    }
}

extension TaskListViewController {
    
    private func showAlert() {
        let alert = AlertController(title: "Новая тренировка", message: "Пожалуйста, введите данные", preferredStyle: .alert)
        
        alert.action { newValue in
            
        }
        present(alert, animated: true)
    }
    
}
