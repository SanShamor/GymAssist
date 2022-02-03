//
//  AlertController.swift
//  GymAssist
//
//  Created by Александр on 14.09.2021.
//

import  UIKit

extension String {
    func localized(tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
      }
}

extension UIAlertController {
    
    static func createAlert(withTitle title: String, andMessage message: String) -> UIAlertController {
        UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    func action(with taskList: TaskList?, completion: @escaping (String) -> Void) {
        let doneButton = taskList == nil ? "alretExt:db.save".localized() : "alretExt:db.upd".localized()
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "alretExt:cancelButton".localized(), style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "alretExt:1.text".localized()
            textField.text = taskList?.name
        }
    }
    
    func action(with task: Task?, completion: @escaping (String, String) -> Void) {
        let title = task == nil ? "alretExt:db.save".localized() : "alretExt:db.upd".localized()
        
        let saveAction = UIAlertAction(title: title, style: .default) { _ in
            guard let newTask = self.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }
            
            if let note = self.textFields?.last?.text, !note.isEmpty {
                completion(newTask, note)
            } else {
                completion(newTask, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "alretExt:cancelButton".localized(), style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "alretExt:2.textFirst".localized()
            textField.text = task?.name
        }
        addTextField { textField in
            textField.placeholder = "alretExt:2.textSecond".localized()
            textField.text = task?.note
        }
    }
    
    func action(with user: Profile?, completion: @escaping  (String) -> Void) {
        let doneButton = "alretExt:db.upd".localized()
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "alretExt:cancelButton".localized(), style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "alretExt:1.text"
            textField.text = "\(user!.weight)"
        }
    }
    
    func actionCreate(completion: @escaping (String, String) -> Void) {
        let doneButton = "alretExt:db.save".localized()
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let height = self.textFields?.first?.text else { return }
            guard let weight = self.textFields?.last?.text else { return }
            completion(height, weight)
        }
        
        addAction(saveAction)
        addTextField { textField in
            textField.placeholder = "alretExt:3.textFirst".localized()
        }
        addTextField { textField in
            textField.placeholder = "alretExt:3.textSecond".localized()
        }
    }
    
}
