//
//  ViewController.swift
//  24
//
//  Created by Harsimranjit Dhaliwal on 2020-04-27.
//  Copyright © 2020 Harsimranjit Dhaliwal. All rights reserved.
//

import UIKit

class RoutineViewController: UITableViewController {
    
    var routineArray: [String] = []
    var textField = UITextField()
    let defaults = UserDefaults.standard
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = defaults.array(forKey: "routineArray") as? [String] {
            routineArray = items
        }
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    //MARK: - User Input
    
    @IBAction func addTaskPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add task", message: "", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            self.textField = UITextField
        }
        let add = UIAlertAction(title: "Add", style: .default) { (text) in
            if let text = self.textField.text {
                let trimmedText = text.trimmingCharacters(in: .whitespaces)
                if !(trimmedText.trimmingCharacters(in: .whitespaces).isEmpty) {
                    self.routineArray.append(trimmedText)
                    self.defaults.set(self.routineArray, forKey: "routineArray")
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
        return routineArray.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routineCell")
        cell?.textLabel?.text = routineArray[indexPath.row]
        return cell!
    }
    
    //MARK: - Table Features
    // Check mark feature
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    // Swipe left to delete feature
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            self.tasksArray.remove(at: indexPath.row)
            self.defaults.set(self.routineArray, forKey: "routineArray")
            self.tableView.reloadData()
        })
        let delete = UISwipeActionsConfiguration(actions: [deleteAction])
        return delete
    }
    
    // LongPress to Reorder feature
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let routine = routineArray[sourceIndexPath.row]
        routineArray.remove(at: sourceIndexPath.row)
        routineArray.insert(routine, at: destinationIndexPath.row)
        defaults.set(self.routineArray, forKey: "routineArray")
    }
}

extension RoutineViewController: UITableViewDragDelegate {
func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension RoutineViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
    
}
