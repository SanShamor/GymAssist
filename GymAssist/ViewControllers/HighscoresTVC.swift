//
//  HighscoresTVC.swift
//  GymAssist
//
//  Created by Александр on 30.09.2021.
//

import RealmSwift

class HighscoresTVC: UITableViewController {
    
    var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        title = "Мои результаты"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists[section].userHighscores.count
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        taskLists[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highscoreCell", for: indexPath)
        let highscore = taskLists[indexPath.section].userHighscores[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = highscore.totalTime
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let dateTimeString = formatter.string(from: highscore.date)
        
        content.secondaryText = String(dateTimeString)
        cell.contentConfiguration = content
        return cell
    }
    
}
