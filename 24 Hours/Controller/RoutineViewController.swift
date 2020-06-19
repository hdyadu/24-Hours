//
//  ViewController.swift
//  24
//
//  Created by Harsimranjit Dhaliwal on 2020-04-27.
//  Copyright © 2020 Harsimranjit Dhaliwal. All rights reserved.
//

import UIKit
import RealmSwift

class Routine: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
}

class Routines: Object {
    @objc dynamic var id: Int = 0
    let routines = List<Routine>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class RoutineViewController: UITableViewController {
    
    var textField = UITextField()
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    let realm = try! Realm()
    
    var routines = RealmSwift.List<Routine>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        //Initialize database
        
        var routineData = realm.object(ofType: Routines.self, forPrimaryKey: 0)
        if routineData == nil {
            routineData = try! realm.write {
                realm.create(Routines.self, value: [])
            }
        }
        routines = routineData!.routines
    }
    //MARK: - User Input
     
    @IBAction func addRoutinePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add task", message: "", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            self.textField = UITextField
        }
        let add = UIAlertAction(title: "Add", style: .default) { (text) in
            if let text = self.textField.text {
                let trimmedText = text.trimmingCharacters(in: .whitespaces)
                if !(trimmedText.trimmingCharacters(in: .whitespaces).isEmpty) {
                    let newRoutine = Routine()
                    newRoutine.title = trimmedText
                    newRoutine.done = false
                    
                    try! self.realm.write {
                        self.routines.append(newRoutine)
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
        return routines.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routineCell", for: indexPath)
        cell.textLabel?.text = routines[indexPath.row].title
        cell.accessoryType = routines[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    //MARK: - Table Features
    // Check mark feature
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let routine = routines[indexPath.row]
        
        try! realm.write {
            routine.done = !routine.done
        }
        
        tableView.reloadData()
    }
    // Swipe left to delete feature
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            try! self.routines.realm?.write {
                self.routines.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
        })
        let delete = UISwipeActionsConfiguration(actions: [deleteAction])
        return delete
    }
    
    // LongPress to Reorder feature
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! routines.realm?.write {
            routines.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
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
