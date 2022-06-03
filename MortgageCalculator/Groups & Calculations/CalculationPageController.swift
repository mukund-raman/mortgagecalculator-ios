//
//  CalculationPageController.swift
//  Mortgage Calculator
//
//  Created by Mukund Raman on 6/26/21.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

// MARK: - CALCULATION PAGE CONTROLLER

/// Manages the calculation details page allows for more insight into the calculations
class CalculationPageController: UIViewController, UITabBarControllerDelegate {
    
    // MARK: - DEFINITION
    
    /// The calculation cell that called this view controller
    var calculationCell: CalculationCell!
    
    /// The title of the calculation cell
    var calculationTitle: UILabel = UILabel()
    
    /// The main view that contains the elements for this view controller
    var mainView: UIView = UIView()
    
    /// The view that contains the actual contents of the calculation details page
    var contentsView: UIView = UIView()
    
    /// The edit button for the calculation title
    var editButton: UIButton!
    
    /// The back button for this page
    var backButton: UIButton!
    
    // MARK: - FUNCTIONS
    
    /// Creates the view that the controller manages
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.darkBlue1
    }
    
    /// Called when the view has fully loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        RecentsViewController.rootTabBarController.delegate = self
        
        // Customize the name of the back button according the navigation controller that called this VC
        let backButton = UIBarButtonItem()
        if let _ = CalculationCell.isTableView as? UITableView {
            backButton.title = "Recents"
            RecentsViewController.recentsViewController!.navigationBar.topItem!.backBarButtonItem = backButton
        }
        else {
            backButton.title = "Starred"
            StarredViewController.starredViewController!.navigationBar.topItem!.backBarButtonItem = backButton
        }
    }
    
    /// When the view is about to disappear, un-hides the navigation bar subviews of the parent controller
    /// - Parameter animated: If true, the disappearance of the view is being animated.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard self.isMovingFromParent else { return }
        
        if let _ = CalculationCell.isTableView as? UITableView {
            let mainViewController: RecentsViewController = RecentsViewController.recentsViewController!
            mainViewController.navigationBar.isHidden = false
            mainViewController.recentsBackButton.isHidden = true
        } else {
            let mainViewController: StarredViewController = StarredViewController.starredViewController!
            mainViewController.navigationBar.isHidden = false
            mainViewController.starredBackButton.isHidden =  true
        }
        
        updateCalculationName()
    }
    
    /// Initializer
    /// - Parameter calculationCell: The calculation cell that presented this view controller
    init(calculationCell: CalculationCell) {
        // Stores the given calculation cell
        super.init(nibName: nil, bundle: nil)
        self.calculationCell = calculationCell
        
        // Sets up the main view of the calculation page
        self.mainView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-180)
        self.mainView.frame.origin = CGPoint(x: 0, y: 90)
//        self.mainView.backgroundColor = .red.withAlphaComponent(0.2)
        self.view.addSubview(mainView)
        
        // Sets up the title of the calculation page
        self.calculationTitle.text = self.calculationCell.mainLabel.text!
        self.calculationTitle.frame.size = CGSize(width: UIScreen.main.bounds.width*0.7, height: 50)
        self.calculationTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 35)
        self.calculationTitle.frame.origin = CGPoint(x: 20, y: 0)
        self.calculationTitle.textColor = .white
        self.mainView.addSubview(self.calculationTitle)
        
        // Sets up the edit button for the calculation title
        self.editButton = UIButton()
        self.editButton.frame.size = CGSize(width: UIScreen.main.bounds.width*0.2, height: 50)
        self.editButton.frame.origin = CGPoint(x: 40 + self.calculationTitle.frame.width, y: 0)
        self.editButton.addTarget(self, action: #selector(self.addTapped(sender:)), for: .touchUpInside)
        self.mainView.addSubview(editButton)
        
        // Creates an imageView and an image that is added to the addButton, then adds the button to the bar
        let addImageView = UIImageView()
        addImageView.frame.size = CGSize(width: 30, height: 30)
        addImageView.center = CGPoint(x: self.editButton.frame.width/2, y: self.editButton.frame.height/2)
        addImageView.contentMode = .scaleAspectFit
        
        // Resizes the image to be added to the image view so that the button is the correct size required
        var addImage = UIImage(named: "Edit")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 30), false, 1.0)
        addImage?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
        addImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Adds the image to the imageview object and sets up the settings of the imageview object
        addImageView.image = addImage?.withRenderingMode(.alwaysTemplate)
        addImageView.tintColor = UIColor.lightOrange1
        self.editButton.addSubview(addImageView)
        
        // Sets up the contents view that contains the different detail views
        self.contentsView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: self.mainView.frame.height-self.editButton.frame.height)
        self.contentsView.frame.origin = CGPoint(x: 0, y: self.editButton.frame.height)
        self.contentsView.backgroundColor = .white.withAlphaComponent(0.2)
        self.mainView.addSubview(contentsView)
    }
    
    /// Updates the last altered calculation name before closing this VC
    func updateCalculationName() {
        let newCalcName: String = self.calculationTitle.text!
        DataSource.changeCalcName(newCalcName: newCalcName, calcUUID: self.calculationCell.key)
    }
    
    /// Closes the current calculation details page controller from view
    @objc func close() {
        let mainController = type(of: CalculationCell.isTableView!).description() == "UITableView" ? (RecentsViewController.recentsViewController!) : (StarredViewController.starredViewController!)
        mainController.popViewController(animated: true)
    }
    
    /// Prompts the user with an alert message to rename their calculation
    /// - Parameter sender: The calling object
    @objc func addTapped(sender: AnyObject) {
        // Defines an alert controller that is used to display a message asking for the name
        let alert = UIAlertController(title: "Change Calculation Name", message: "Enter the new name for your calculation:", preferredStyle: .alert)
        
        // Adds a textfield to store the calculation name
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Calculation Name"
        })
        
        // Adds an action called "Done" to store the calculation name into the variable
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
            if let calc_name = alert.textFields?.first?.text, calc_name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                self.calculationTitle.text = calc_name
                self.calculationCell.mainLabel.text = calc_name
            }
        }))
        
        // Presents the alert on top of the view controller
        self.present(alert, animated: true)
    }
    
    /// Required initializer
    /// - Parameter coder: An unarchiver object
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - UITABBARCONTROLLER CONFORMANCE
    
    /// Tells the delegate that the user selected an item in the tab bar
    /// - Parameters:
    ///   - tabBarController: The tab bar controller containing viewController
    ///   - viewController: The view controller that the user selected
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateCalculationName()
   }
}

// MARK: - INPUT VIEW

/// The UIView that represents the input page of the calculation details, which allows the user to change the values in their calculations
class InputView: UIView {
    /// Manages the display of calculated values that represent totals/constants useful for the big picture
    class TotalsCalculatedController: UIViewController {
        
    }
}

// MARK: - TABLE VIEW

/// The UIView that represents the table page of the calculation details, which shows the user a table of monthly payments
class TableView: UIView {
    
}

// MARK: - GRAPH VIEW

/// The UIView that represents the graph page of the calculation cells, which displays graphs and charts that provide insight from the calculation
class GraphView: UIView {
    
}
