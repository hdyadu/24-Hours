//
//  GoalViewController.swift
//  24 Hours
//
//  Created by Harsimranjit Dhaliwal on 2020-05-15.
//  Copyright © 2020 Harsimranjit Dhaliwal. All rights reserved.
//

import UIKit
import RealmSwift

class Goal: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
}

class Goals: Object {
    @objc dynamic var id: Int = 0
    let goals = List<Goal>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class GoalViewController: UITableViewController {
    
    var textField = UITextField()
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    let realm = try! Realm()
    
    var goals = RealmSwift.List<Goal>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        //Initialize database
        
        var goalsData = realm.object(ofType: Goals.self, forPrimaryKey: 0)
        if goalsData == nil {
            goalsData = try! realm.write { realm.create(Goals.self, value: []) }
        }
        goals = goalsData!.goals
    }
    //MARK: - User Input
    
    @IBAction func addGoalPressed(_ sender: UIBarButtonItem) {
        
            let alert = UIAlertController(title: "Add goal", message: "", preferredStyle: .alert)
            alert.addTextField { (UITextField) in
                self.textField = UITextField
            }
            let add = UIAlertAction(title: "Add", style: .default) { (text) in
                if let text = self.textField.text {
                    let trimmedText = text.trimmingCharacters(in: .whitespaces)
                    if !(trimmedText.trimmingCharacters(in: .whitespaces).isEmpty) {
                        let newGoal = Goal()
                        newGoal.title = trimmedText
                        newGoal.done = false
                        
                        try! self.realm.write {
                            self.goals.append(newGoal)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            alert.addAction(add)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
        
    }

    //MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell", for: indexPath)
        cell.textLabel?.text = goals[indexPath.row].title
        cell.accessoryType = goals[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    //MARK: - Table Features
    // Check mark feature
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let goal = goals[indexPath.row]
        
        try! realm.write {
            goal.done = !goal.done
        }
        
        tableView.reloadData()
    }
    
    // Swipe left to delete feature
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            try! self.goals.realm?.write {
                self.goals.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
        })
        let delete = UISwipeActionsConfiguration(actions: [deleteAction])
        return delete
    }
    
    // LongPress to Reorder feature
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! goals.realm?.write {
            goals.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }

}

extension GoalViewController: UITableViewDragDelegate {
func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension GoalViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
    
}
