//
//  ViewController.swift
//  24
//
//  Created by Harsimranjit Dhaliwal on 2020-04-27.
//  Copyright © 2020 Harsimranjit Dhaliwal. All rights reserved.
//

import UIKit
import CoreData

class RoutineViewController: UITableViewController {
    
    var routineArray = [RoutineTask]()
    var textField = UITextField()
    let defaults = UserDefaults.standard
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        // Switching the routine tasks from userdefaults to new array as routine task from core data entity
        // and emptying user defaults for key routineArray
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    //MARK: - User Input
     
    @IBAction func addRoutinePressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add task", message: "", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            self.textField = UITextField
        }
        let add = UIAlertAction(title: "Add", style: .default) { (text) in
            
            let newRoutineTask = RoutineTask(context: self.context)
            if let text = self.textField.text {
                let trimmedText = text.trimmingCharacters(in: .whitespaces)
                if !(trimmedText.trimmingCharacters(in: .whitespaces).isEmpty) {
                    newRoutineTask.title = trimmedText
                    newRoutineTask.done = false
                    self.routineArray.append(newRoutineTask)
                    self.saveItems()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "routineCell", for: indexPath)
        cell.textLabel?.text = routineArray[indexPath.row].title
        cell.accessoryType = routineArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    //MARK: - Table Features
    // Check mark feature
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        routineArray[indexPath.row].done = !routineArray[indexPath.row].done
        
        tableView.reloadData()
        
        
    }
    // Swipe left to delete feature
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {_,_,_ in
            self.context.delete(self.routineArray[indexPath.row])
            self.routineArray.remove(at: indexPath.row)
            self.saveItems()
        })
        let delete = UISwipeActionsConfiguration(actions: [deleteAction])
        return delete
    }
    
    // LongPress to Reorder feature
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let routine = routineArray[sourceIndexPath.row]
        routineArray.remove(at: sourceIndexPath.row)
        routineArray.insert(routine, at: destinationIndexPath.row)
        saveItems()
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        let request: NSFetchRequest<RoutineTask> = RoutineTask.fetchRequest()
        do {
            routineArray = try context.fetch(request)
        } catch {
            print("Error fetching data from the context \(error)")
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
