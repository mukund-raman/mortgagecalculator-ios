//
//  NewGroup.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 6/19/21.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

/// Manages the display of a dialog prompt asking the user to fill in the details of their new group
class NewGroup {
    
    // MARK: - FUNCTIONS
    
    /// Creates and initializes the attributes and properties of a UIAlertController for use as a group creation dialog message
    /// - Parameter isRecentsViewCtr: A boolean value indicating whether the view controller provided is part of the recents or starred screen
    /// - Returns: The group alert controller that contains the group alert message
    static func createGroupAlertController(isRecentsViewCtr: Bool) -> UIAlertController {
        // Creates the alert controller required for the display of the new group dialog prompt
        let groupAlertController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        var recCtr: RecentsViewController? = nil, starCtr: StarredViewController? = nil
        if isRecentsViewCtr { recCtr = RecentsViewController.recentsViewController! }
        else { starCtr = StarredViewController.starredViewController! }
        
        print("tableView subviews count from NewGroup:", RecentsTableViewController.staticTableView.subviews.filter({ view in
            if let _ = view as? UITableViewCell { return true }
            else { return false }
        }).count)
        
        // Creates the title and the message string for the dialog prompt
        let titleString = NSAttributedString(string: "Create Group", attributes: [
            .foregroundColor : UIColor.lightOrange1
        ])
        let messageString = NSAttributedString(string: "Enter a name for your new group", attributes: [
            .foregroundColor : UIColor.lightOrange1,
            .font : UIFont(name: "HelveticaNeue", size: 13)!
        ])
        groupAlertController.setValue(titleString, forKey: "attributedTitle")
        groupAlertController.setValue(messageString, forKey: "attributedMessage")
        
        // Clears the background color of the alert controller and sets the tint colors of the alert actions
        UIView.clearBackgroundColor(of: groupAlertController.view)
        let subview = (groupAlertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor(red: 15, green: 15, blue: 15)
        groupAlertController.view.layer.borderWidth = 1
        groupAlertController.view.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        // Adds a textfield to store the group name
        groupAlertController.addTextField(configurationHandler: { textField in
            let attributedPlaceHolder = NSAttributedString(string: "Enter Group Name", attributes: [
                .foregroundColor : UIColor.lightOrange1.withAlphaComponent(0.5)
            ])
            textField.attributedPlaceholder = attributedPlaceHolder
            textField.textColor = UIColor.lightOrange1
            textField.addDoneButtonToKeyboard()
            textField.backgroundColor = .clear
        })
        
        // Add empty textfield to the dialog message
        groupAlertController.addTextField(configurationHandler: { t in
            t.isEnabled = false
            t.text = "Add to Favorites: "
            t.textColor = UIColor.lightOrange1
            t.font = UIFont(name: "HelveticaNeue", size: 15)
        })
        
        // Iterate through each textfield in the UIAlertController and make it transparent
        for textfield in groupAlertController.textFields! {
            let container: UIView = textfield.superview!
            let effectView: UIView = container.superview!.subviews[0]
            if let _ = textfield.placeholder {
                container.backgroundColor = UIColor(red: 15, green: 15, blue: 15).withAlphaComponent(0.5)
            }
            else { container.backgroundColor = UIColor.clear }
            effectView.removeFromSuperview()
        }
        
        // Creates a starred switch used if the user wants to specify if the group is favorited
        let starredSwitch = UISwitch(frame: CGRect(x: 195, y: 112, width: 40, height: 40))
        starredSwitch.transform = CGAffineTransform (
            scaleX: CGFloat.toProp(0.85, true),
            y: CGFloat.toProp(0.85, false)
        )
        starredSwitch.isOn = !isRecentsViewCtr
        starredSwitch.onTintColor = UIColor.lightOrange1
        starredSwitch.tintColor = UIColor(red: 15, green: 15, blue: 15).withAlphaComponent(0.5)
        if isRecentsViewCtr {
            starredSwitch.addTarget(recCtr, action: #selector(recCtr!.switchStarredGroup), for: .touchUpInside)
        } else {
            starredSwitch.addTarget(starCtr, action: #selector(starCtr!.switchStarredGroup), for: .touchUpInside)
        }
        groupAlertController.view.addSubview(starredSwitch)
        
        
        // Adds an action called "Cancel" to cancel the operation of creating a new group
        groupAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        
        // Adds an action called "Create" to pass the group name into the writeGroupToJSON function
        groupAlertController.addAction(UIAlertAction(title: "Create", style: .default) { action in
            if let group_name = groupAlertController.textFields?.first?.text,
            group_name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                if isRecentsViewCtr {
                    DataSource.writeGroupToJSON(withName: group_name, isStarred: recCtr!.isGroupStarred, groupKey: UUID().uuidString)
                } else {
                    DataSource.writeGroupToJSON(withName: group_name, isStarred: starCtr!.isGroupStarred, groupKey: UUID().uuidString)
                    StarredScrollViewController.starredScrollViewController?.refreshData()
                }
            }
        })
        
        return groupAlertController
    }
    
    /// Creates and initializes the attributes and properties of a UIAlertController for use as a group renaming dialog message
    /// - Parameters:
    ///   - index: The index of the data for a certain group in the data source array
    ///   - recCtr: The recents view controller that manages the views in the recents screen
    /// - Returns: The group renaming alert controller that contains the dialog prompt
    static func renameGroupController(_ index: Int, _ recCtr: RecentsViewController? = nil) -> UIAlertController {
        // Condition to check the index to make sure that it is valid
        guard index >= 0, index < DataSource.dataSource.count else { fatalError("WRONG INDEX") }
        
        // Creates the alert controller required for the display of the rename group dialog prompt
        let groupRenameController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        // Create the title and message string with the attributes required
        let titleString = NSAttributedString(string: "Rename Group", attributes: [
            .foregroundColor : UIColor.lightOrange1
        ])
        let messageString = NSAttributedString(string: "Enter a new name for your group", attributes: [
            .foregroundColor : UIColor.lightOrange1,
            .font : UIFont(name: "HelveticaNeue", size: 13)!
        ])
        groupRenameController.setValue(titleString, forKey: "attributedTitle")
        groupRenameController.setValue(messageString, forKey: "attributedMessage")
        groupRenameController.view.layer.borderWidth = 1
        groupRenameController.view.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        
        // Clears the background color of the alert controller and sets the tint colors of the alert actions
        UIView.clearBackgroundColor(of: groupRenameController.view)
        let subview = (groupRenameController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor(red: 15, green: 15, blue: 15)
        
        // Adds a textfield to store the group name
        groupRenameController.addTextField(configurationHandler: { textField in
            let attributedPlaceHolder = NSAttributedString(string: "Enter Group Name", attributes: [
                .foregroundColor : UIColor.lightOrange1.withAlphaComponent(0.5)
            ])
            textField.attributedPlaceholder = attributedPlaceHolder
            textField.textColor = UIColor.lightOrange1
            textField.addDoneButtonToKeyboard()
            textField.backgroundColor = .clear
        })
        
        // Make the textfield background transparent and then change the background color
        let container: UIView = groupRenameController.textFields![0].superview!
        container.backgroundColor = UIColor(red: 15, green: 15, blue: 15).withAlphaComponent(0.5)
        container.superview!.subviews[0].removeFromSuperview()
        
        // Adds an action called "Cancel" to cancel the operation of creating a new group
        groupRenameController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Adds an action called "Rename" to write the group name into the JSON file
        groupRenameController.addAction(UIAlertAction(title: "Rename", style: .default, handler: { action in
            if let group_name = groupRenameController.textFields?.first?.text,
            group_name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                DataSource.updateBelongsTo(index: index, newName: group_name)
                DataSource.dataSource[index]["group_name"] = group_name
                DataSource.writeJSON()
                recCtr?.tableView.reloadData()
                recCtr?.startingGroupCell?.refreshScrollView()
                StarredScrollViewController.starredScrollViewController?.refreshData()
            }
        }))
        
        return groupRenameController
    }
}
