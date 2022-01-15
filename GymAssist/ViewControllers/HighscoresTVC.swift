//
//  HighscoresTVC.swift
//  GymAssist
//
//  Created by Александр on 30.09.2021.
//

import RealmSwift

class HighscoresTVC: UITableViewController {
    
    var taskLists: Results<TaskList>!
    typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Мои результаты"
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        navigationItem.rightBarButtonItems = [editButtonItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists[section].userHighscores.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highscoreCell", for: indexPath)
        let highscore = taskLists[indexPath.section].userHighscores[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = highscore.totalTime
        
        let formatter = DateFormatter()
        //formatter.timeStyle = .medium
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        let dateTimeString = formatter.string(from: highscore.date)
        
        content.secondaryText = String(dateTimeString)
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        taskLists[section].name
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let highscore = taskLists[indexPath.section].userHighscores[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.deleteFromRealm(type: highscore)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.3,
            delay: 0.3 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
    
}
