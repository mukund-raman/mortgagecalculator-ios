//
//  NewCalculation.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 12/26/19.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

/// Manages the display of the page asking to create a new calculation
class NewCalculation : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - DEFINITION
    
    // Miscellaneous definitions
    var calculationTitle: String = "New Calculation"
    var navBar: UINavigationBar!
    var tableView: UITableView?
    var calculationKey: String!
    
    // The variables that represent whether the calculation belongs to a group
    var belongsTo: String!
    var parentGroupCell: GroupCell?
    
    // The values to store the different data required for calculating monthly payment
    var house_cost: CGFloat? {
        didSet {
            self.paymentTextField.text = String(Float(self.monthlyPayment))
        }
    }
    var down_payment: CGFloat? {
        didSet {
            self.paymentTextField.text = String(Float(self.monthlyPayment))
        }
    }
    var interest_rate: CGFloat? {
        didSet {
            self.paymentTextField.text = String(Float(self.monthlyPayment))
        }
    }
    var loan_term: CGFloat? {
        didSet {
            self.paymentTextField.text = String(Float(self.monthlyPayment))
        }
    }
    
    // The variables used for the house cost option
    var houseView: UIView!
    var houseTextField: UITextField!
    
    // The variables used for the interest rate option
    var interestView: UIView!
    var interestTextField: UITextField!
    
    // The variables used for the down payment option
    var downView: UIView!
    var downTextField: UITextField!
    var downPercent, downDollarSign: UILabel!
    var downPaymentSwitch: Bool = false
    
    // The variables used for the monthly payment display
    var paymentView: UIView!
    var paymentTextField: UITextField!
    
    // The variables used for the favorite field display
    var favoriteView: UIView!
    var favoriteLabel: UILabel!
    var favoriteSwitch: UISwitch!
    
    // The variables used for the loan term option
    var loanView: UIView!
    var loanTextField: UITextField!
    let termOptions: [String] = ["Years", "Months", "Days"]
    var timeType: UILabel!
    var selectedOption: String = "Years"
    var loan_term_option: String {
        switch(self.selectedOption) {
            case "Days": return "0";
            case "Months": return "1";
            case "Years": return "2";
            default: return "None"
        }
    }
    
    // The lazy and computed properties that store the dictionary for the JSON to handle
    lazy var dataSource: [String] = self.termOptions
    var currentDict: [String:String] {
        return [
            "calc_title": self.calculationTitle,
            "house_cost": String(Float(self.house_cost ?? 0)),
            "down_payment": self.downPaymentSwitch ? "1:" + String(Float(self.down_payment ?? 0)) : "0:" + String(Float(self.down_payment ?? 0)),
            "interest_rate": String(Float(self.interest_rate ?? 0)),
            "loan_term": self.loan_term_option + ":" + String(Float(self.loan_term ?? 0)),
            "monthly_payment": String(Float(self.monthlyPayment)) + " monthly",
            "Date": self.currDate[0] + " " + self.currDate[1] + ", " + self.currDate[2],
            "BelongsTo": self.belongsTo,
            "isStarred": String(self.isStarred),
            "CalculationKey": self.calculationKey
        ]
    }
    
    /// The variable to store the year, month and day of when the calculation was created
    var currDate: [String] = []
    
    /// The variable to store whether or not the current calculation is a favorite
    var isStarred: Bool = false
    
    /// Create button to create the calculation
    var createButton: UIButton! = UIButton()
    
    /// Computed property to calculate the monthly payment
    var monthlyPayment: CGFloat {
        // Defines the principal amount based on down_payment
        let downPayment: Double = Double(self.down_payment ?? 0)
        let house_cost: Double = Double(self.house_cost ?? 0)
        let down_payment: Double = Double(self.downPaymentSwitch ? (downPayment/100)*house_cost : downPayment)
        let principalAmount = house_cost - down_payment
        
        // Defines and calculates the loan term based on the selected option in the uipickerview
        var loan_term: Double = 0.0
        switch(self.selectedOption) {
            case "Years": loan_term = Double((self.loan_term ?? 0)*12);
            case "Days": loan_term = Double((self.loan_term ?? 0)/(365/12));
            default: loan_term = Double(self.loan_term ?? 0);
        }
        
        // Defines the monthly_interest_rate for based on the current annual interest rate
        let monthly_interest_rate = ((self.interest_rate ?? 0)/1200)
        
        // Constants to calculate the first and second half of the equation and the final constant
        let firstHalf = Double(monthly_interest_rate) * pow(Double(1 + monthly_interest_rate), Double(loan_term))
        let secondHalf = pow(Double(1 + monthly_interest_rate), Double(loan_term))-1
        let final = principalAmount * (firstHalf / (secondHalf == 0 ? 1 : secondHalf))
        
        // Returns the full equation, which is the firstHalf divided by the secondHalf
        return CGFloat(round(final*100)/100)
    }
    
    // MARK: - FUNCTIONS
    
    /// Called when the view has fully loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBar()
    }
    
    /// Creates the view that the controller manages
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.darkBlue1
        self.setContents()
    }
    
    /// Switches the boolean value determining whether the star button is starred
    @objc func switchStarred() { self.isStarred = !self.isStarred }
    
    /// Sets up the navigation bar at the top of the new calculation page
    func setNavigationBar() {
        // Defines the constants used for setting the attributes of the navigation bar
        self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 50))
        let navItem = UINavigationItem(title: "New Calculation")
        
        // Set the appearance of the UIBarButtonItem (font) for all button items
        UIBarButtonItem.appearance()
            .setTitleTextAttributes (
                [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: CGFloat.toProp(15.0, true))!],
                for: .normal
            )
        
        // Sets the items of the navigation bar to the navigation item created above
        self.navBar.setItems([navItem], animated: false)
        
        // Sets the tints of the navigation bar and the text attributes of the navigation bar
        self.navBar.barTintColor = UIColor.darkBlue1
        self.navBar.tintColor = UIColor.lightOrange1
        self.navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: CGFloat.toProp(35, true))!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // Add edit button to Nav Bar
        let addButton: UIBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(self.addTapped(sender:)))
        
        // Creates an imageView and an image that is added to the addButton, then adds the button to the bar
        let addImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 2, height: 2))
        addImageView.contentMode = .scaleAspectFit
        
        // Resizes the image to be added to the image view so that the button is the correct size required
        var addImage = UIImage(named: "Edit")
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 22, height: 22), false, 1.0)
        addImage?.draw(in: CGRect(x: CGFloat.toProp(-2 , true), y: CGFloat.toProp(-2, false), width: 22, height: 22))
        addImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Adds the image to the imageview object and sets up the settings of the imageview object
        addImageView.image = addImage?.withRenderingMode(.alwaysTemplate)
        addImageView.tintColor = UIColor.lightOrange1
        addButton.image = addImage
        navItem.rightBarButtonItem = addButton
        
        // Creates the exit button used to exit from the new calculation page
        let exitButton: UIBarButtonItem = UIBarButtonItem(title: " ⓧ", style: .done, target: self, action: #selector(self.dismissSelf))
        exitButton.setTitleTextAttributes([.font:UIFont(name: "HelveticaNeue-Bold", size: 27)!], for: .normal)
        exitButton.tintColor = UIColor.lightOrange1
        navItem.leftBarButtonItem = exitButton

        // Sets the translucent property of the navigation bar to false
        self.navBar.isTranslucent = false
        
        // Adds the navigation bar as a subview to the current view
        self.view.addSubview(self.navBar)
    }
    
    /// Dismisses the calling object from view
    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// Switches the down payment type from percent to amount, and vice versa
    /// - Parameter Switch: A UI Control that consists of a binary value that can be switched conditionally
    @objc func switchDownPayment(_ Switch: UISwitch) {
        // If the switch is toggled on, then switch the type of down payment to percentage and remove dollar sign
        if Switch.isOn {
            self.downPaymentSwitch = true
            self.downDollarSign?.removeFromSuperview()
            self.downPercent = UILabel(frame: CGRect(x: self.downTextField.frame.maxX+CGFloat.toProp(7, true), y: (self.downView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(20, true), height: CGFloat.toProp(30, false)))
            self.downPercent.font = self.downPercent.font.withSize(CGFloat.toProp(18.5, true))
            self.downPercent.textColor = UIColor.lightOrange1
            self.downPercent.text = "%"
            self.downView.addSubview(self.downPercent)
        }
        // If the switch is toggled off, then switch the type of down payment to dollars and remove the percentage sign
        else {
            self.downPaymentSwitch = false
            self.downPercent?.removeFromSuperview()
            self.downDollarSign = UILabel(frame: CGRect(x: self.downTextField.frame.minX-CGFloat.toProp(20, true), y: (self.downView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(15, true), height: CGFloat.toProp(30, false)))
            self.downDollarSign.textColor = UIColor.lightOrange1
            self.downDollarSign.font = self.downDollarSign.font.withSize(CGFloat.toProp(18.5, true))
            self.downDollarSign.text = "$"
            self.downView.addSubview(self.downDollarSign)
        }
        self.paymentTextField.text = String(Float(self.monthlyPayment))
    }
    
    /// Determines the type of textfield, and then sets the variables accordingly
    /// - Parameter textField: The textfield to be checked
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Use the isDescendant function with the switch statement to update the data from the textfield accordingly
        switch(textField) {
        case _ where textField.isDescendant(of: self.interestView):
            guard let text = textField.text else { return }
            if let float_val = Float(text) { self.interest_rate = CGFloat(float_val) }
            else { self.interest_rate = nil }
        case _ where textField.isDescendant(of: self.houseView):
            guard let text = textField.text else { return }
            if let float_val = Float(text) { self.house_cost = CGFloat(float_val) }
            else { self.house_cost = nil }
        case _ where textField.isDescendant(of: self.downView):
            guard let text = textField.text else { return }
            if let float_val = Float(text) { self.down_payment = CGFloat(float_val) }
            else { self.down_payment = nil }
        case _ where textField.isDescendant(of: self.loanView):
            guard let text = textField.text else { return }
            if let float_val = Float(text) { self.loan_term = CGFloat(float_val) }
            else { self.loan_term = nil }
        default:
            return
        }
    }
    
    /// Closes the current subview and passes control back to the navigation page (as well as JSON)
    @objc func createCalc() {
        // If the monthly payment has not been correctly set up or is invalid for some reason, then alert the user
        if self.checkFields() || self.monthlyPayment.isZero || self.monthlyPayment.isNaN {
            let alertController: UIAlertController = UIAlertController(title: "Incomplete Values", message: "You have not entered any valid values or may have missed some values for the given fields. Please fill out the fields before creating the calculation", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay, I'll try again", style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        // Create the date and dateformatter object used to show when the calculation was created
        let date: Date = Date()
        let dateFormatter = DateFormatter()
        
        // Add the current month to the current date array
        dateFormatter.dateFormat = "LLLL"
        self.currDate.append(dateFormatter.string(from: date))
        
        // Add the current day to the current date array
        dateFormatter.dateFormat = "d"
        self.currDate.append(dateFormatter.string(from: date))
        
        // Add the current year to the current date array
        dateFormatter.dateFormat = "yyyy"
        self.currDate.append(dateFormatter.string(from: date))
        
        // Initialize a new UUID identifier for the calculation
        self.calculationKey = UUID().uuidString
        
        // Create the new JSON and upload into file, as well as reload the data in the table view
        DataSource.createJSON(fromDict: self.currentDict)
        StarredScrollViewController.starredScrollViewController?.refreshData()
        
        // Remove the current calculation from its parent view that called it
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Checks whether all of the fields have been entered correctly
    /// - Returns: A boolean value indicating whether all fields are correctly entered
    func checkFields() -> Bool {
        return self.house_cost == nil || self.down_payment == nil || self.interest_rate == nil || self.loan_term == nil
    }
    
    /// Prompts the user with an alert message to rename their calculation
    /// - Parameter sender: The calling object
    @objc func addTapped(sender: AnyObject) {
        // Defines an alert controller that is used to display a message asking for the name
        let alert = UIAlertController(title: "Change Calculation Name", message: "Enter the name for your new calculation:", preferredStyle: .alert)
        
        // Adds a textfield to store the calculation name
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Calculation Name"
        })
        
        // Adds an action called "Done" to store the calculation name into the variable
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
            if let calc_name = alert.textFields?.first?.text, calc_name.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                self.calculationTitle = calc_name
                self.navBar.items?[0].title = self.calculationTitle
            }
        }))
        
        // Presents the alert on top of the view controller
        self.present(alert, animated: true)
    }
    
    // MARK: SET CONTENTS
    
    /// Sets the contents of the new calculation page
    func setContents() {
        
        // MARK: HOUSE_COST
        
        // Creates the subview to contain the first field -- the house cost
        self.houseView = UIView(frame: CGRect(x: (self.view.frame.size.width-CGFloat.toProp(375, true))/2, y: 90, width: CGFloat.toProp(375, true), height: CGFloat.toProp(40, false)))
        self.houseView.backgroundColor = UIColor.darkBlue2
        self.houseView.layer.cornerRadius = 15
        self.houseView.layer.masksToBounds = true
        
        // Creates the UITextField associated with the above subview and adds it to the subview
        self.houseTextField = UITextField(frame: CGRect(x: self.houseView.frame.maxX-CGFloat.toProp(200, true), y: (self.houseView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(155, true), height: CGFloat.toProp(30, false)))
        self.houseTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.houseTextField.backgroundColor = UIColor.darkBlue2
        self.houseTextField.textAlignment = .center
        self.houseTextField.keyboardType = .decimalPad
        self.houseTextField.addDoneButtonToKeyboard()
        self.houseTextField.layer.cornerRadius = 10
        self.houseTextField.layer.masksToBounds = true
        self.houseTextField.layer.borderWidth = 1
        self.houseTextField.layer.borderColor = CGColor(red: 238/255.0, green: 153/255.0, blue: 65/255.0, alpha: 1)
        self.houseTextField.textColor = UIColor.lightOrange1
        self.houseView.addSubview(self.houseTextField)
        
        // Label to to describe the cost to enter (house cost)
        let houseText: UILabel = UILabel(frame: CGRect(x: self.houseView.frame.minX+CGFloat.toProp(5, true), y: (self.houseView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(200, true), height: CGFloat.toProp(30, false)))
        let dollarSign: UILabel = UILabel(frame: CGRect(x: self.houseTextField.frame.minX-CGFloat.toProp(20, true), y: (self.houseView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(12, true), height: CGFloat.toProp(30, false)))
        houseText.textColor = UIColor.lightOrange1
        dollarSign.textColor = UIColor.lightOrange1
        houseText.font = houseText.font.withSize(CGFloat.toProp(20, true))
        dollarSign.font = dollarSign.font.withSize(CGFloat.toProp(18.5, true))
        houseText.text = "House Cost"
        dollarSign.text = "$"
        self.houseView.addSubview(houseText)
        self.houseView.addSubview(dollarSign)
        
        // MARK: DOWN PAYMENT
        
        // Creates the subview to contain the second field -- the down payment
        self.downView = UIView(frame: CGRect(x: (self.view.frame.size.width-CGFloat.toProp(375, true))/2, y: self.houseView.frame.maxY+CGFloat.toProp(30, false), width: CGFloat.toProp(375, true), height: CGFloat.toProp(40, false)))
        self.downView.backgroundColor = UIColor.darkBlue2
        self.downView.layer.cornerRadius = 15
        self.downView.layer.masksToBounds = true
        
        // Creates the UITextField associated with the above subview and adds it to the subview
        self.downTextField = UITextField(frame: CGRect(x: self.downView.frame.maxX-CGFloat.toProp(140, true), y: (self.downView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(85, true), height: CGFloat.toProp(30, false)))
        self.downTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.downTextField.backgroundColor = UIColor.darkBlue2
        self.downTextField.textAlignment = .center
        self.downTextField.keyboardType = .decimalPad
        self.downTextField.addDoneButtonToKeyboard()
        self.downTextField.layer.cornerRadius = 10
        self.downTextField.layer.masksToBounds = true
        self.downTextField.layer.borderWidth = 1
        self.downTextField.layer.borderColor = CGColor(red: 238/255.0, green: 153/255.0, blue: 65/255.0, alpha: 1)
        self.downTextField.textColor = UIColor.lightOrange1
        self.downView.addSubview(self.downTextField)
        
        // Label to to describe the cost to enter (down payment)
        let downText: UILabel = UILabel(frame: CGRect(x: self.downView.frame.minX+CGFloat.toProp(5, true), y: (self.downView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(130, true), height: CGFloat.toProp(30, false)))
        let downSwitch: UISwitch = UISwitch(frame: CGRect(x: downText.frame.maxX+CGFloat.toProp(15, true), y: (self.downView.frame.size.height-CGFloat.toProp((1/CGFloat.toProp(1, false))*30, false))/2, width: CGFloat.toProp(130, true), height: CGFloat.toProp(30, false)))
        downSwitch.transform = CGAffineTransform(scaleX: CGFloat.toProp(1, true), y: CGFloat.toProp(1, false))
        downSwitch.onTintColor = UIColor.lightOrange1
        downSwitch.addTarget(self, action: #selector(self.switchDownPayment), for: UIControl.Event.valueChanged)
        downText.textColor = UIColor.lightOrange1
        downText.text = "Down Payment"
        self.downView.addSubview(downSwitch)
        self.downView.addSubview(downText)
        self.downDollarSign = UILabel(frame: CGRect(x: self.downTextField.frame.minX-CGFloat.toProp(20, true), y: (self.downView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(15, true), height: CGFloat.toProp(30, false)))
        self.downDollarSign.font = self.downDollarSign.font.withSize(CGFloat.toProp(18.5, true))
        self.downDollarSign.text = "$"
        self.downDollarSign.textColor = UIColor.lightOrange1
        self.downView.addSubview(self.downDollarSign)
        
        // MARK: INTEREST RATE
        
        // Creates the subview to contain the first field -- the house cost
        self.interestView = UIView(frame: CGRect(x: (self.view.frame.size.width-CGFloat.toProp(375, true))/2, y: self.downView.frame.maxY+CGFloat.toProp(30, false), width: CGFloat.toProp(375, true), height: CGFloat.toProp(40, false)))
        self.interestView.backgroundColor = UIColor.darkBlue2
        self.interestView.layer.cornerRadius = 15
        self.interestView.layer.masksToBounds = true
        
        // Creates the UITextField associated with the above subview and adds it to the subview
        self.interestTextField = UITextField(frame: CGRect(x: self.interestView.frame.maxX-CGFloat.toProp(160, true), y: (self.interestView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(100, true), height: CGFloat.toProp(30, false)))
        self.interestTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.interestTextField.backgroundColor = UIColor.darkBlue2
        self.interestTextField.textAlignment = .center
        self.interestTextField.keyboardType = .decimalPad
        self.interestTextField.addDoneButtonToKeyboard()
        self.interestTextField.layer.cornerRadius = 10
        self.interestTextField.layer.masksToBounds = true
        self.interestTextField.layer.borderWidth = 1
        self.interestTextField.layer.borderColor = CGColor(red: 238/255.0, green: 153/255.0, blue: 65/255.0, alpha: 1)
        self.interestTextField.textColor = UIColor.lightOrange1
        self.interestView.addSubview(self.interestTextField)
        
        // Label to to describe the cost to enter (house cost)
        let interestText: UILabel = UILabel(frame: CGRect(x: self.interestView.frame.minX+CGFloat.toProp(5, true), y: (self.interestView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(200, true), height: CGFloat.toProp(30, false)))
        let percent = UILabel(frame: CGRect(x: self.interestTextField.frame.maxX+CGFloat.toProp(5, true), y: (self.interestView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(20, true), height: CGFloat.toProp(30, false)))
        interestText.textColor = UIColor.lightOrange1
        interestText.font = interestText.font.withSize(CGFloat.toProp(20, true))
        percent.textColor = UIColor.lightOrange1
        percent.font = percent.font.withSize(CGFloat.toProp(17.5, true))
        interestText.text = "Interest Rate (Annual)"
        percent.text = "%"
        self.interestView.addSubview(interestText)
        self.interestView.addSubview(percent)
        
        // MARK: LOAN TERM
        
        // Creates the subview to contain the first field -- the house cost
        self.loanView = UIView(frame: CGRect(x: (self.view.frame.size.width-CGFloat.toProp(375, true))/2, y: self.interestView.frame.maxY+CGFloat.toProp(30, false), width: CGFloat.toProp(375, true), height: CGFloat.toProp(60, false)))
        self.loanView.backgroundColor = UIColor.darkBlue2
        self.loanView.layer.cornerRadius = 15
        self.loanView.layer.masksToBounds = true
        
        // Creates the UITextField associated with the above subview and adds it to the subview
        self.loanTextField = UITextField(frame: CGRect(x: self.loanView.frame.maxX-CGFloat.toProp(135, true), y: (self.loanView.frame.size.height-CGFloat.toProp(40, false))/2, width: CGFloat.toProp(80, true), height: CGFloat.toProp(40, false)))
        self.loanTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.loanTextField.backgroundColor = UIColor.darkBlue2
        self.loanTextField.textAlignment = .center
        self.loanTextField.keyboardType = .decimalPad
        self.loanTextField.addDoneButtonToKeyboard()
        self.loanTextField.layer.cornerRadius = 10
        self.loanTextField.layer.masksToBounds = true
        self.loanTextField.layer.borderWidth = 1
        self.loanTextField.layer.borderColor = CGColor(red: 238/255.0, green: 153/255.0, blue: 65/255.0, alpha: 1)
        self.loanTextField.textColor = UIColor.lightOrange1
        self.loanView.addSubview(self.loanTextField)
        
        // Creates the loan UILabel text displayed on the loan term section
        let loanText: UILabel = UILabel(frame: CGRect(x: self.loanView.frame.minX+CGFloat.toProp(15, true), y: (self.loanView.frame.size.height-CGFloat.toProp(50, false))/2, width: CGFloat.toProp(85, true), height: CGFloat.toProp(50, false)))
        loanText.textColor = UIColor.lightOrange1
        loanText.font = loanText.font.withSize(CGFloat.toProp(17.5, true))
        loanText.text = "Loan Term"
        self.loanView.addSubview(loanText)
        
        // Creates a single letter at end of the textfield to specify the time unit
        self.timeType = UILabel(frame: CGRect(x: self.loanTextField.frame.maxX+CGFloat.toProp(8, true), y: (self.loanView.frame.size.height-CGFloat.toProp(30, false))/2, width: CGFloat.toProp(20, true), height: CGFloat.toProp(30, false)))
        self.timeType.textColor = UIColor.lightOrange1
        self.timeType.text = "y"
        self.loanView.addSubview(self.timeType)
        
        // UIPickerView used to determine whether the loan term is in years, months, or days
        let loanUIPicker: UIPickerView = UIPickerView(frame: CGRect(x: loanText.frame.maxX+CGFloat.toProp(15, true), y: (self.loanView.frame.size.height-CGFloat.toProp(40, false))/2, width: CGFloat.toProp(100, true), height: CGFloat.toProp(40, false)))
        loanUIPicker.delegate = self as UIPickerViewDelegate
        loanUIPicker.dataSource = self as UIPickerViewDataSource
        loanUIPicker.layer.cornerRadius = 10
        loanUIPicker.layer.masksToBounds = true
        loanUIPicker.layer.borderWidth = 1
        loanUIPicker.layer.borderColor = .init(srgbRed: 1, green: 1, blue: 1, alpha: 0.3)
        loanUIPicker.backgroundColor = UIColor.darkBlue1
        self.loanView.addSubview(loanUIPicker)
        
        // MARK: MONTHLY PAYMENT
        
        // Creates the subview to contain the last field -- the montly payment
        self.paymentView = UIView(frame:
            CGRect(
                x: (self.view.frame.size.width-CGFloat.toProp(375, true))/2,
                y: self.loanView.frame.maxY+CGFloat.toProp(30, false),
                width: CGFloat.toProp(375, true),
                height: CGFloat.toProp(40, false)
            )
        )
        self.paymentView.backgroundColor = UIColor.darkBlue2
        self.paymentView.layer.cornerRadius = 15
        self.paymentView.layer.masksToBounds = true
        
        // Creates the monthly payment UILabel text displayed on the monthly payment section
        let paymentText: UILabel = UILabel(frame:
            CGRect(
                x: self.paymentView.frame.minX+CGFloat.toProp(15, true),
                y: (self.paymentView.frame.size.height-CGFloat.toProp(60, false))/2,
                width: CGFloat.toProp(160, true),
                height: CGFloat.toProp(60, false)
            )
        )
        paymentText.textColor = UIColor.lightOrange1
        paymentText.font = loanText.font.withSize(CGFloat.toProp(18, true))
        paymentText.text = "Monthly Payment"
        self.paymentView.addSubview(paymentText)
        
        // Creates the UITextField associated with the above subview and adds it to the subview
        self.paymentTextField = UITextField(frame:
            CGRect(
                x: self.paymentView.frame.maxX-CGFloat.toProp(200, true),
                y: (self.paymentView.frame.size.height-CGFloat.toProp(30, false))/2,
                width: CGFloat.toProp(150, true),
                height: CGFloat.toProp(30, false)
            )
        )
        self.paymentTextField.backgroundColor = UIColor.darkBlue2
        self.paymentTextField.textAlignment = .center
        self.paymentTextField.text = String(Float(self.monthlyPayment))
        self.paymentTextField.isUserInteractionEnabled = false
        self.paymentTextField.layer.cornerRadius = 10
        self.paymentTextField.layer.masksToBounds = true
        self.paymentTextField.layer.borderWidth = 1
        self.paymentTextField.layer.borderColor = CGColor(red: 238/255.0, green: 153/255.0, blue: 65/255.0, alpha: 1)
        self.paymentTextField.textColor = UIColor.lightOrange1
        self.paymentView.addSubview(self.paymentTextField)
        
        // MARK: ADD TO FAVORITES
        
        // Creates the subview to contain the favorite field -- determines whether the calculation is a favorite
        self.favoriteView = UIView(frame:
            CGRect(
                x: (self.view.frame.size.width-CGFloat.toProp(300, true))/2,
                y: self.paymentView.frame.maxY+CGFloat.toProp(30, false),
                width: CGFloat.toProp(300, true),
                height: CGFloat.toProp(40, false)
            )
        )
        self.favoriteView.backgroundColor = UIColor.darkBlue2
        self.favoriteView.layer.cornerRadius = 15
        self.favoriteView.layer.masksToBounds = true
        
        // Creates the favorite label to be added to the favorite field
        self.favoriteLabel = UILabel(frame:
            CGRect(
                x: self.paymentView.frame.minX+CGFloat.toProp(15, true),
                y: (self.paymentView.frame.size.height-CGFloat.toProp(60, false))/2,
                width: CGFloat.toProp(160, true),
                height: CGFloat.toProp(60, false)
            )
        )
        self.favoriteView.addSubview(self.favoriteLabel)
        self.favoriteLabel.textColor = UIColor.lightOrange1
        self.favoriteLabel.font = loanText.font.withSize(CGFloat.toProp(18, true))
        self.favoriteLabel.text = "Add To Favorites: "
        
        // Create the favorite switch to indicate whether or not the calculation is favorited
        self.favoriteSwitch = UISwitch(frame:
            CGRect(
                x: self.favoriteLabel.frame.maxX+CGFloat.toProp(15, true),
                y: (self.downView.frame.size.height-CGFloat.toProp((1/CGFloat.toProp(1, false))*30, false))/2,
                width: CGFloat.toProp(130, true),
                height: CGFloat.toProp(30, false)
            )
        )
        self.favoriteView.addSubview(self.favoriteSwitch)
        self.favoriteSwitch.isOn = self.isStarred
        self.favoriteSwitch.transform = CGAffineTransform(scaleX: CGFloat.toProp(1, true), y: CGFloat.toProp(1, false))
        self.favoriteSwitch.onTintColor = UIColor.lightOrange1
        self.favoriteSwitch.addTarget(self, action: #selector(self.switchStarred), for: UIControl.Event.valueChanged)
        
        // MARK: CREATE CALCULATION
        
        // Creates and set up the button, then adding it to the new calculation page
        self.createButton = UIButton(frame:
            CGRect(
                x: (self.view.frame.size.width-CGFloat.toProp(250, true))/2,
                y: self.favoriteView.frame.maxY+CGFloat.toProp(30, false),
                width: CGFloat.toProp(250, true),
                height: CGFloat.toProp(50, false)
            )
        )
        self.createButton.backgroundColor = UIColor.darkBlue2
        self.createButton.setTitle("Create Calculation", for: .normal)
        self.createButton.setTitleColor(UIColor.white, for: .normal)
        self.createButton.layer.cornerRadius = CGFloat.toProp(25, false)
        self.createButton.layer.masksToBounds = true
        self.createButton.layer.borderWidth = 1
        self.createButton.layer.borderColor = CGColor(red: 238/255.0, green: 153/255.0, blue: 65/255.0, alpha: 1)
        self.createButton.addTarget(nil, action: #selector(self.createCalc), for: .touchUpInside)
        
        // Adds all of the subviews
        self.view.addSubview(self.houseView)
        self.view.addSubview(self.downView)
        self.view.addSubview(self.interestView)
        self.view.addSubview(self.loanView)
        self.view.addSubview(self.paymentView)
        self.view.addSubview(self.favoriteView)
        self.view.addSubview(self.createButton)
    }
    
    // MARK: - UIPICKERVIEW CONFORMANCE
    
    /// Retrieves the number of different components in the UIPicker
    /// - Returns: The number 1 because there is only one component in the UIPicker
    func numberOfComponents(in _: UIPickerView) -> Int { return 1 }
    
    /// Returns the number of rows in the specified components
    /// - Returns: The number of data in the data source to be converted into rows
    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return self.dataSource.count
    }
    
    /// Each time a row is selected, sets the current selected option variable to the selected row string
    /// - Parameters:
    ///   - row: The index of the row that is selected by the user
    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        self.selectedOption = self.dataSource[row]
        switch(self.selectedOption) {
            case "Years": self.timeType.text = "y";
            case "Months": self.timeType.text = "m";
            case "Days": self.timeType.text = "d";
            default: self.timeType.text = "y"
        }
        self.paymentTextField.text = String(Float(self.monthlyPayment))
    }
    
    /// Sets up each row in the UIPickerView
    /// - Parameters:
    ///   - row: The index of the row to be set up
    ///   - view: The view that was previously used for this row
    /// - Returns: A view object to use as the content of the row
    func pickerView(_: UIPickerView, viewForRow row: Int, forComponent _: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "HelveticaNeue", size: CGFloat.toProp(14, true))
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = self.dataSource[row]
        pickerLabel?.textColor = UIColor.lightOrange1

        return pickerLabel!
    }
    
    /// Returns the row at the specified index in the array
    /// - Parameters:
    ///   - row: The index identifying a certain row in the array
    /// - Returns: The data in the array dataSource that corresponds with the given row index
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return self.dataSource[row]
    }
    
}
