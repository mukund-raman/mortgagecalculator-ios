//
//  RecentsViewController.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 12/25/19.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

/// Manages the recent screen of the application and the table view that displays the different calculations made
class RecentsViewController : UINavigationController {
    
    // MARK: - DEFINITION
    
    // The view controller instances
    static var recentsViewController: RecentsViewController? = nil
    let tableViewController = RecentsTableViewController()
    lazy var tableView = tableViewController.tableView
    
    // The variables used to set the group to which a calculation belongs in
    var startingGroup: String!
    var startingGroupCell: GroupCell?
    
    /// The variable used to check if the group being created is starred or not
    var isGroupStarred: Bool = false
    
    /// The constant to store the storyboard that is going to be activated
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    /// A plus button to allow the creation of a new calculation
    let plus: UIButton = UIButton(type: UIButton.ButtonType.system)
    
    /// The custom alert controller used for the creation of a new calculation or group
    var customAlertController: SelectionAlertController!
    
    /// The custom back button that closes the calculation details page
    var recentsBackButton: UIButton = UIButton()
    
    /// The root tab bar controller for this application
    static var rootTabBarController: UITabBarController!
    
    // MARK: - FUNCTIONS
    
    /// Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        RecentsViewController.rootTabBarController = self.tabBarController!
    }
    
    /// Creates the view that the controller manages
    override func loadView() {
        // Loads the view and sets the colors of the navigation bar
        RecentsViewController.recentsViewController = self
        super.loadView()
        self.navigationBar.tintColor = UIColor.lightOrange1
        self.navigationBar.barTintColor = UIColor.darkBlue1
        DataSource.tableView = self.tableView
        
        // Sets up the custom back button
        self.recentsBackButton.frame.origin = CGPoint(x: 0, y: 46)
        self.recentsBackButton.frame.size = CGSize(width: 94, height: 44)
        
        // Sets up the label for the custom back button
        let backButtonLabel: UILabel = UILabel()
        backButtonLabel.frame.size = CGSize(width: 64.6667, height: 21.3333)
        backButtonLabel.frame.origin = CGPoint(x: 29.3333, y: self.recentsBackButton.frame.height-backButtonLabel.frame.height)
        backButtonLabel.text = "Recents"
        backButtonLabel.textColor = .lightOrange2
        self.recentsBackButton.addSubview(backButtonLabel)
        
        // Sets up the arrow imageview for the custom back button
        let backButtonImageView: UIImageView = UIImageView(image: UIImage(named: "backButtonImage")?.withTintColor(.lightOrange2))
        backButtonImageView.frame.size = CGSize(width: 15.3333, height: 21)
        backButtonImageView.frame.origin = CGPoint(x: 8, y: self.recentsBackButton.frame.height-backButtonImageView.frame.height)
        self.recentsBackButton.addSubview(backButtonImageView)
        
        // Create a label that holds the navigation title of the recents page
        let label = UILabel()
        label.text = "Recents"
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 35)
        label.frame = CGRect (
            x: CGFloat.toProp(50, true),
            y: 0, width: CGFloat.toProp(200, true),
            height: CGFloat.toProp(100, false)
        )
        self.navigationBar.addSubview(label)
        
        // Create constraints for the navigation title in the recents page
        let labelTrailingConstraint = NSLayoutConstraint (
            item: label,
            attribute: .trailingMargin,
            relatedBy: .equal,
            toItem: self.navigationBar,
            attribute: .trailingMargin,
            multiplier: 1.0,
            constant: -16
        )
        let labelXConstraint = NSLayoutConstraint (
            item: label,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self.navigationBar,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0
        )
        let labelBottomConstraint = NSLayoutConstraint (
            item: label,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.navigationBar,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -10
        )
        
        // Sets auto resizing mask to false and activates the layout constraint for the plus button
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Creates a plus button and tints the image of that button to the light color specified, then finally adding the plus button to the navigation bar as a subview
        let tintedImage = UIImageView(image: UIImage(named: "Plus")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate))
        tintedImage.tintColor = UIColor.lightOrange1
        self.plus.setImage(tintedImage.image, for: .normal)
        self.navigationBar.addSubview(self.plus)
        
        // Sets the frame of the plus button as well as adding a target for the button
        self.plus.frame = CGRect(x: self.view.frame.width, y: 0, width: 250, height: 250)
        self.plus.addTarget(self, action: #selector(self.presentActionSheet), for: .touchUpInside)
        
        // Create constraints for the plus button in the navigation bar of the recents page
        let buttonTrailingConstraint = NSLayoutConstraint (
            item: self.plus,
            attribute: .trailingMargin,
            relatedBy: .equal,
            toItem: self.navigationBar,
            attribute: .trailingMargin,
            multiplier: 1.0,
            constant: -16
        )
        let buttonBottomConstraint = NSLayoutConstraint (
            item: self.plus,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self.navigationBar,
            attribute: .bottom,
            multiplier: 1.0,
            constant: -16
        )
        
        // Sets auto resizing mask to false and activates the layout constraint for the plus button
        self.plus.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelTrailingConstraint,
            labelXConstraint,
            labelBottomConstraint,
            buttonBottomConstraint,
            buttonTrailingConstraint
        ])
        
        // Pushes the tableViewController onto the navigation controller recents page
        self.pushViewController(self.tableViewController, animated: true)
    }
    
    /// Presents a custom action sheet to prompt the user to create a new group or calculation
    @objc func presentActionSheet() {
        // Create the custom alert controller and setup the basic parts
        self.customAlertController = SelectionAlertController(numberOfRows: 3)
        self.customAlertController.isModalInPresentation = true
        self.customAlertController.firstIsCancel = true
        
        // Reset the starting group to nil
        self.startingGroup = "null"
        self.startingGroupCell = nil
        
        // Setup the basic background color and tex† color for each row
        for row in self.customAlertController.rows {
            row.tint = 0.1
            if let text = row.mainLabel.text, text == "Cancel" {
                row.mainLabel.textColor = UIColor.lightOrange1
            } else { row.mainLabel.textColor = UIColor.lightOrange2 }
            row.background_color = UIColor.darkBlue1.withAlphaComponent(0.75)
        }
        
        // Configure the second and third rows to allow for the creation of a calculation and a group
        let secondRow = self.customAlertController.rows[1]
        let thirdRow = self.customAlertController.rows[2]
        thirdRow.mainLabel.text = "New Group"
        secondRow.mainLabel.text = "New Calculation"
        thirdRow.contentButton.addTarget(self, action: #selector(self.createNewGroup), for: .touchUpInside)
        secondRow.contentButton.addTarget(self, action: #selector(self.openCalc), for: .touchUpInside)
        
        // Present the alert controller
        self.present(self.customAlertController, animated: true)
    }
    
    /// Opens the new calculation page when the plus button is clicked
    @objc func openCalc() {
        // Pop the current view controllers on the screen
        self.popViewController(animated: true)
        self.customAlertController?.dismiss(animated: true)
        
        // Create the next controller to be presented and present it
        let nextController = NewCalculation()
        nextController.tableView = self.tableView
        nextController.belongsTo = self.startingGroup ?? ""
        nextController.parentGroupCell = self.startingGroupCell
        self.present(nextController, animated: true)
    }
    
    /// Creates a new group and passes it to the function that writes to the JSON file
    @objc func createNewGroup() {
        // Pop the current view controllers on the screen
        self.popViewController(animated: true)
        self.customAlertController.dismiss(animated: true, completion: nil)
        
        // Present the alert on top of the view controller
        self.isGroupStarred = false
        self.present(NewGroup.createGroupAlertController(isRecentsViewCtr: true), animated: true)
    }
    
    /// Switches the group being created from unstarred to starred and vice versa
    @objc func switchStarredGroup() {
        self.isGroupStarred = !self.isGroupStarred
    }
    
    /// Renames the group when the edit button is clicked
    /// - Parameter index: The index of the group data in the data source
    func renameGroup(forIndex index: Int) {
        // Pop the current view controllers on the screen and present the alert
        self.popViewController(animated: true)
        self.present(NewGroup.renameGroupController(index, self), animated: true)
    }
}
