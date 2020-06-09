//
//  TaskViewController.swift
//  24 Hours
//
//  Created by Harsimranjit Dhaliwal on 2020-05-21.
//  Copyright © 2020 Harsimranjit Dhaliwal. All rights reserved.
//

import UIKit
import RealmSwift

class Task: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
}

class Tasks: Object {
    @objc dynamic var id: Int = 0
    let tasks = List<Task>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class TaskViewController: UITableViewController {
    
    var textField = UITextField()
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    let realm = try! Realm()
    
    var tasks = RealmSwift.List<Task>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        //Initialize database
        
        var tasksData = realm.object(ofType: Tasks.self, forPrimaryKey: 0)
        if tasksData == nil {
            tasksData = try! realm.write {
                realm.create(Tasks.self, value: [])
            }
        }
        tasks = tasksData!.tasks
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
                    let newTask = Task()
                    newTask.title = trimmedText
                    newTask.done = false
                    
                    try! self.realm.write {
                        self.tasks.append(newTask)
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
        return tasks.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].title
        cell.accessoryType = tasks[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    //MARK: - Table Features
    // Check mark feature
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasks[indexPath.row]
        
        try! realm.write {
            task.done = !task.done
        }
        
        tableView.reloadData()
    }
    
    // Swipe left to delete feature
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            try! self.tasks.realm?.write {
                self.tasks.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
        })
        let delete = UISwipeActionsConfiguration(actions: [deleteAction])
        return delete
    }
    
    // LongPress to Reorder feature
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! tasks.realm?.write {
            tasks.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
}

extension TaskViewController: UITableViewDragDelegate {
func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}

extension TaskViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
    
}

