//
//  ViewController.swift
//  24
//
//  Created by Harsimranjit Dhaliwal on 2020-04-27.
//  Copyright © 2020 Harsimranjit Dhaliwal. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var tasksArray: [String] = []
    var textField = UITextField()
    let defaults = UserDefaults.standard
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = defaults.array(forKey: "tasksArray") as? [String] {
            tasksArray = items
        }
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    //MARK: - User Input
    
    @IBAction func plusButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add task", message: "", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            self.textField = UITextField
        }
        let alertAction = UIAlertAction(title: "Add", style: .default) { (text) in
            if let text = self.textField.text {
                self.tasksArray.append(text)
                self.defaults.set(self.tasksArray, forKey: "tasksArray")
                self.tableView.reloadData()
            }
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell")
        cell?.textLabel?.text = tasksArray[indexPath.row]
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
            self.defaults.set(self.tasksArray, forKey: "tasksArray")
            self.tableView.reloadData()
        })
        let delete = UISwipeActionsConfiguration(actions: [deleteAction])
        return delete
    }
    
    // LongPress to Reorder feature
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = tasksArray[sourceIndexPath.row]
        tasksArray.remove(at: sourceIndexPath.row)
        tasksArray.insert(task, at: destinationIndexPath.row)
        defaults.set(self.tasksArray, forKey: "tasksArray")
    }
}

extension ViewController: UITableViewDragDelegate {
func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension ViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
}
