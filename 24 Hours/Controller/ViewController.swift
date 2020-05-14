//
//  ViewController.swift
//  24
//
//  Created by Harsimranjit Dhaliwal on 2020-04-27.
//  Copyright © 2020 Harsimranjit Dhaliwal. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIGestureRecognizerDelegate {

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
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture))
        longPress.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPress)
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
    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
      let locationInView = sender.location(in: tableView)
      let indexPath = tableView.indexPathForRow(at: locationInView)

      if sender.state == .began {
        if indexPath != nil {
          dragInitialIndexPath = indexPath
          let cell = tableView.cellForRow(at: indexPath!)
          dragCellSnapshot = snapshotOfCell(inputView: cell!)
          var center = cell?.center
          dragCellSnapshot?.center = center!
          dragCellSnapshot?.alpha = 0.0
          tableView.addSubview(dragCellSnapshot!)

          UIView.animate(withDuration: 0.25, animations: { () -> Void in
            center?.y = locationInView.y
            self.dragCellSnapshot?.center = center!
            self.dragCellSnapshot?.transform = (self.dragCellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
            self.dragCellSnapshot?.alpha = 0.99
            cell?.alpha = 0.0
          }, completion: { (finished) -> Void in
            if finished {
              cell?.isHidden = true
            }
          })
        }
      } else if sender.state == .changed && dragInitialIndexPath != nil {
        var center = dragCellSnapshot?.center
        center?.y = locationInView.y
        dragCellSnapshot?.center = center!

        // to lock dragging to same section add: "&& indexPath?.section == dragInitialIndexPath?.section" to the if below
        if indexPath != nil && indexPath != dragInitialIndexPath {
          // update your data model
          let taskToMove = tasksArray[dragInitialIndexPath!.row]
          tasksArray.remove(at: dragInitialIndexPath!.row)
          tasksArray.insert(taskToMove, at: indexPath!.row)

          tableView.moveRow(at: dragInitialIndexPath!, to: indexPath!)
          dragInitialIndexPath = indexPath
        }
      } else if sender.state == .ended && dragInitialIndexPath != nil {
        let cell = tableView.cellForRow(at: dragInitialIndexPath!)
        cell?.isHidden = false
        cell?.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
          self.dragCellSnapshot?.center = (cell?.center)!
          self.dragCellSnapshot?.transform = CGAffineTransform.identity
          self.dragCellSnapshot?.alpha = 0.0
          cell?.alpha = 1.0
        }, completion: { (finished) -> Void in
          if finished {
            self.dragInitialIndexPath = nil
            self.dragCellSnapshot?.removeFromSuperview()
            self.dragCellSnapshot = nil
          }
        })
      }
    }

    func snapshotOfCell(inputView: UIView) -> UIView {
      UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
      inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      let cellSnapshot = UIImageView(image: image)
      cellSnapshot.layer.masksToBounds = false
      cellSnapshot.layer.cornerRadius = 0.0
      cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
      cellSnapshot.layer.shadowRadius = 5.0
      cellSnapshot.layer.shadowOpacity = 0.4
      return cellSnapshot
    }
    
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true // Yes, the table view can be reordered
    }

    func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
        // update the item in my data source by first removing at the from index, then inserting at the to index.
        let item = tasksArray[fromIndexPath.row]
        tasksArray.remove(at: fromIndexPath.row)
        tasksArray.insert(item, at: toIndexPath.row)
        print(tasksArray)
    }
}
