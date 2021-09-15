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
        createTestData()
        //taskLists = StorageManager.shared.realm.objects(TaskList.self)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //taskLists.count
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        //let taskList = taskLists[indexPath.row]
        //var content = cell.defaultContentConfiguration()
        //content.text = taskList.name
        //content.secondaryText = "\(taskList.tasks.count)"
        //cell.contentConfiguration = content
        return cell
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList

    }
    */
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    private func createTestData() {
        let shoppingList = TaskList()
        shoppingList.name = "Силовая треня"
        
        let milk = Task()
        milk.name = "Milk"
        milk.note = "2L"
        
        let bread = Task(value: ["Bread", "", Date(), true])
        let apples = Task(value: ["name": "Apples", "note": "2Kg"])
        
        let moviesList = TaskList()
        moviesList.name = "Гантельная треня"
        
        let film = Task(value: ["The best of the best", "Must have", Date(), true])
        let anotherFilm = Task(value: ["name": "Best film ever"])
        //let moviesList = TaskList(value: ["Movies List", Date(), [["Best film ever"], ["The best of the best", "Must have", Date(), true]]])
        
        shoppingList.tasks.append(milk)
        shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
        moviesList.tasks.insert(contentsOf: [film, anotherFilm], at: 0)
        
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
