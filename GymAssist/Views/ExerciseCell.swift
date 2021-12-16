//
//  ExerciseCell.swift
//  GymAssist
//
//  Created by Александр on 12.12.2021.
//

import UIKit

class ExerciseCell: UITableViewCell {

    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseNoteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureTask(with task: Task) {
        exerciseNameLabel.text = task.name
        exerciseNoteLabel.text = task.note
        exerciseNameLabel.textColor = #colorLiteral(red: 0.9989104867, green: 0.1764889061, blue: 0.1743151546, alpha: 1)
        exerciseNoteLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        exerciseNameLabel.shadowColor = #colorLiteral(red: 0.9989104867, green: 0.1764889061, blue: 0.1743151546, alpha: 1)
        exerciseNoteLabel.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
}
