//
//  Extensions.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 3/29/20.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit


// MARK: - CLEAR BG COLORS

extension UIView {
    /// Clears all of the background colors of a view and its subviews
    /// - Parameter view: The view whose background colors should be cleared of
    class func clearBackgroundColor(of view: UIView) {
        // If the current view is an effect view, then remove it from superview and return
        if let effectsView = view as? UIVisualEffectView {
            effectsView.removeFromSuperview()
            return
        }
        
        // Set the view to become transparent and iterate recursively through each of its own subviews
        view.layer.cornerRadius = 15
        view.tintColor = UIColor.lightOrange1
        if let textView = view as? UILabel { textView.backgroundColor = .clear }
        else { view.backgroundColor = UIColor.white.withAlphaComponent(0.02) }
        view.subviews.forEach { (subview) in
            self.clearBackgroundColor(of: subview)
        }
    }
}

// MARK: - VIEW BORDER

extension UIView {
    /// Adds a border to the sides of the UIView
    /// - Parameters:
    ///   - side: The side of the UIView to add the border
    ///   - color: The color of the border
    ///   - thickness: The thickness of the border
    func addBorder(side: UIRectEdge, color: UIColor, thickness: CGFloat) {
        // Create a UIView to store the border for the main view
        let border = UIView()

        // Switch statement to set up the frame based on the side of the view with the border
        switch side {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }

        // Set the background color of the border and add it to the main view
        border.backgroundColor = color;
        self.addSubview(border)
    }
}

// MARK: - ADD DONE TO KEYBOARD

extension UITextField {
    /// Creates a toolbar and adds it to the keyboard
    func addDoneButtonToKeyboard() {
        // Create a toolbar item to store the done button to be added
        let doneToolBar: UIToolbar = UIToolbar(frame:
            CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 50
            )
        )
        
        // Filler element to add space to allow the done button to be indented to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Done button to be added as an item to the keyboard to the right of the flexible space
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.resignFromView))
        
        // Set the items of the done tool bar and add it as an accessory view to the textfields
        doneToolBar.items = [flexibleSpace, doneButton]
        self.inputAccessoryView = doneToolBar
    }
    
    /// Resigns the keyboard and toolbar from view
    @objc func resignFromView() {
        self.resignFirstResponder()
    }
}

// MARK: - PARENT VIEW CONTROLLER

extension UIView {
    /// Retrieves the hierarchically highest view controller of a certain type T
    /// - Parameter viewController: The type of the view controller to be found
    /// - Returns: The view controller of type T if found, nil otherwise
    func superViewController<T: UIViewController>(ofType viewController: T.Type) -> T? {
        var superResponder: UIResponder? = self
        while superResponder != nil {
            superResponder = superResponder?.next
            if let viewController = superResponder as? T { return viewController }
        }
        return nil
    }
}

// MARK: - EQUATABLE

extension CalculationCell {
    /// Compares the New Calculation Cell data to its JSON equivalent
    /// - Parameter data: The JSON data to be compared against
    /// - Returns: A boolean value that represents whether the New Calculation Cell data is equal to the JSON data
    func isEqualTo(data: [String:String]) -> Bool {
        guard self.mainLabel.text == data["calc_title"] else { return false }
        guard self.dateLabel.text == data["Date"] else { return false }
        guard self.monthlyPaymentLabel.text == data["monthly_payment"] else { return false }
        return true
    }
}

extension GroupCell {
    /// Compares the New Group Cell data to its JSON equivalent
    /// - Parameter data: The JSON data to be compared against
    /// - Returns: A boolean value that represents whether the New Group Cell data is equal to the JSON data
    func isEqualTo(data: [String:String]) -> Bool {
        guard self.mainLabel.text == data["group_name"] else { return false }
        guard self.dateLabel.text == data["Date"] else { return false }
        return true
    }
}

// MARK: - COPYABLE

extension UIView {
    /// Makes a copy of the calling object
    /// - Throws: An error if the object is unable to be encoded or properly decoded
    /// - Returns: A copy of the calling object
    func copyView<T: UIView>() throws -> T {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! T
    }
}

extension GroupCell {
    /// Makes a copy of the calling group cell
    /// - Returns: A copy of the calling group cell
    func copyCell() -> GroupCell {
        let cloneCell = GroupCell(style: .default, reuseIdentifier: "groupCell")
        cloneCell.index = self.index
        cloneCell.key = self.key
        cloneCell.getStarred()
        cloneCell.switchStarredView()
        cloneCell.mainLabel.text = self.mainLabel.text!
        cloneCell.dateLabel.text = self.dateLabel.text!
        cloneCell.frame.size = CGSize(width: UIScreen.main.bounds.width, height: cloneCell.mainView.frame.height)
        cloneCell.mainView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: cloneCell.mainView.center.y)
        return cloneCell
    }
}

extension CalculationCell {
    /// Makes a copy of the calling calculation cell
    /// - Returns: A copy of the calling calculation cell
    func copyCell() -> CalculationCell {
        let cloneCell = CalculationCell(style: .default, reuseIdentifier: "calcCell")
        cloneCell.index = self.index
        cloneCell.key = self.key
        cloneCell.groupKey = self.groupKey
        cloneCell.groupCell = self.groupCell
        cloneCell.getStarred()
        cloneCell.switchStarredView()
        cloneCell.mainLabel.text = self.mainLabel.text!
        cloneCell.dateLabel.text = self.dateLabel.text!
        cloneCell.monthlyPaymentLabel.text = self.monthlyPaymentLabel.text!
        cloneCell.frame.size = CGSize(width: UIScreen.main.bounds.width, height: cloneCell.mainView.frame.height)
        cloneCell.mainView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: cloneCell.mainView.center.y)
        return cloneCell
    }
}

// MARK: - RECENTS TABLE VIEW

extension RecentsTableViewController : UITableViewDataSource {
    
    /// Asks the data source to verify that the given row is editable
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information
    ///   - indexPath: An index path locating a row in tableView
    /// - Returns: true if the row indicated by indexPath is editable; otherwise, false
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        print("isEditable tableview function run")
        return true
    }

    /// Asks the data source to commit the insertion or deletion of a specified row in the receiver
    /// - Parameters:
    ///   - tableView: The table-view object requesting the insertion or deletion
    ///   - editingStyle: The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath
    ///   - indexPath: An index path locating the row in tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("delete tableview function run")
        DataSource.readJSON()
        if (editingStyle == .delete) {
            DataSource.deleteDict(index: indexPath.section)
        }
    }
    
    /// Determines the number of sections in the table view cell
    /// - Parameter tableView: The table view that contains the cells
    /// - Returns: The number of sections in the table view, which is the number of data in the data source array
    func numberOfSections(in tableView: UITableView) -> Int {
        DataSource.readJSON()
        print("numOfSections tableview function run - DataSource count:", RecentsTableViewController.tableViewDataSource.count)
        return RecentsTableViewController.tableViewDataSource.count
    }
    
    /// Determines the number of rows in the table view cell
    /// - Parameters:
    ///   - tableView: The table view that contains the cells
    ///   - section: A certain section in the table view
    /// - Returns: The number 1 because there is only 1 row in the table view cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numOfRowsInSection tableview function run")
        return 1
    }
    
    /// Makes an empty UIView to provide as a separator between each section
    /// - Parameters:
    ///   - tableView: The table view that contains the cells
    ///   - section: A certain section in the table view
    /// - Returns: A newly created UIView
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("viewForHeaderInSection tableview function run")
        return UIView()
    }
    
    /// Determines the height of each row in each section for each calculation
    /// - Parameters:
    ///   - tableView: The table view that contains the cells
    ///   - indexPath: The index path that locates a row in the table view
    /// - Returns: The height of the rows in each section of the table view
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("heightForRowAt tableView function run")
        DataSource.readJSON()
        if let name = RecentsTableViewController.tableViewDataSource[indexPath.section]["group_name"] {
            var groupHeight: Int = GroupCell.heightList[name] ?? 0
            if groupHeight > 3 { groupHeight = 3 }
            return CGFloat(135 + (70*groupHeight))
        }
        else {
            return 80
        }
    }

    /// Creates a cell for the certain row and returns the cell
    /// - Parameters:
    ///   - tableView: The table view that contains the cells
    ///   - indexPath: The index path that locates a row in the table view
    /// - Returns: The newly created cell to be placed in the table view for a certain row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("tableViewCellForRowAt tableview function run")
        
        // Read from the JSON file in order to update any new information that might have been added
        DataSource.readJSON()
        let dataSource = RecentsTableViewController.tableViewDataSource
        
        print("Value at index", indexPath.section, ":", DataSource.dataSource[indexPath.section])

        /* If the current dictionary used from the data source is a group, then store the group name as well as
           any other values needed to show the app user about their recent calculations */
        if let text = dataSource[indexPath.section]["group_name"] {
            // Set up the rest of the labels to be used
            let groupCell: GroupCell = tableView
                .dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
            groupCell.index = DataSource.dataSource.firstIndex(of: dataSource[indexPath.section])!
            groupCell.key = dataSource[indexPath.section]["GroupKey"]
            groupCell.mainLabel.text = text
            groupCell.dateLabel.text = dataSource[indexPath.section]["Date"]
            groupCell.refreshScrollView()
            groupCell.frame.size = CGSize(width: UIScreen.main.bounds.width, height: groupCell.frame.height)
            groupCell.mainView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: groupCell.mainView.center.y)
            
            // Change the height of the main view to match that of the group cell's
            let mainViewHeight: CGFloat = 135.0+CGFloat((groupCell.subviewCount > 3 ? 3 : groupCell.subviewCount)*70)
            groupCell.mainView.frame.size = CGSize(width: groupCell.mainView.frame.width, height: mainViewHeight)
            groupCell.changeFrames(false)
            
            // Add the height of the scrollview to the height list
            let heightList = GroupCell.heightList
            if heightList[text] == nil {
                GroupCell.heightList[text] = groupCell.subviewCount
            }
            
            // Check the JSON array and switch the starred view if needed
            groupCell.getStarred()
            groupCell.switchStarredView()
            
            // Setup the view that is shown when a row is selected (transparent/clear)
            let selectedView: UIView = UIView()
            selectedView.backgroundColor = .clear
            groupCell.selectedBackgroundView = selectedView
            return groupCell
        }
        // If not, then show the information needed for a calculation made separate of a group
        else {
            // Set the texts of the rest of the information
            let calcCell: CalculationCell = tableView
                .dequeueReusableCell(withIdentifier: "calcCell", for: indexPath) as! CalculationCell
            calcCell.index = DataSource.dataSource.firstIndex(of: dataSource[indexPath.section])!
            calcCell.key = dataSource[indexPath.section]["CalculationKey"]
            calcCell.groupKey = dataSource[indexPath.section]["BelongsTo"]
            calcCell.mainLabel.text = dataSource[indexPath.section]["calc_title"]
            calcCell.dateLabel.text = dataSource[indexPath.section]["Date"]
            calcCell.monthlyPaymentLabel.text = dataSource[indexPath.section]["monthly_payment"]
            calcCell.frame.size = CGSize(width: UIScreen.main.bounds.width, height: calcCell.frame.height)
            calcCell.mainView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: calcCell.mainView.center.y)
            
            // Check the JSON array and switch the starred view if needed
            calcCell.getStarred()
            calcCell.switchStarredView()
            
            // Setup the view that is shown when a row is selected
            let selectedView: UIView = UIView()
            selectedView.backgroundColor = UIColor.lightOrange1
            calcCell.selectedBackgroundView = selectedView
            return calcCell
        }
    }
}

// MARK: - UICOLOR CONVENIENCE

extension UIColor {
    
    /// Convenience initializer to provide an easier method to initalize UIColors
    /// - Parameters:
    ///   - r: The red value of the UIColor
    ///   - g: The green value of the UIColor
    ///   - b: The blue value of the UIColor
    ///   - a: The alpha/transparency value of the UIColor, in percentage
    convenience init(red r: Int, green g: Int, blue b: Int, alphaPercent a: Int = 100) {
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/100)
    }
}

// MARK: - UICOLOR THEME COLORS

extension UIColor {
    // The theme colors used throughout the application
    static let darkBlue1: UIColor = UIColor(red: 4, green: 7, blue: 47)
    static let darkBlue2: UIColor = UIColor(red: 25, green: 28, blue: 47)
    static let darkBlue3: UIColor = UIColor(red: 0, green: 24, blue: 198)
    static let lightOrange1: UIColor = UIColor(red: 238, green: 153, blue: 65)
    static let lightOrange2: UIColor = UIColor(red: 253, green: 184, blue: 104)
}

// MARK: - TO PROPORTION

extension CGFloat {
    
    /// Converts a number to its proportionate version
    /// - Parameters:
    ///   - Number: The number to be converted
    ///   - isWidth: A boolean value determing whether this value is a width or height value
    /// - Returns: The proportionally adjusted value with respect to the screen size
    static func toProp(_ Number: CGFloat, _ isWidth: Bool) -> CGFloat {
        if isWidth { return (Number*UIScreen.main.bounds.width)/414 }
//        print("width:", UIScreen.main.bounds.width, "; height:", UIScreen.main.bounds.height)
        return (Number*UIScreen.main.bounds.height)/896
    }
}

// MARK: - REFRESH TO STARRED

extension GroupCell {
    
    /// Adds only the starrred elements to the group cell; used in the starred scroll view to show only the starred cells
    func addStarredElements() {
        var yVal: Int = 0
        for i in 0..<DataSource.dataSource.count {
            let data = DataSource.dataSource[i]
            guard data["BelongsTo"] == self.key, data["isStarred"] == "true" else { continue }
            
            let cell = CalculationCell(style: .default, reuseIdentifier: "calcCell")
            cell.index = i
            cell.key = data["CalculationKey"]
            cell.groupKey = self.key
            cell.groupCell = self
            cell.getStarred()
            cell.switchStarredView()
            cell.mainLabel.text = data["calc_title"]
            cell.mainView.center = CGPoint(x: cell.mainView.center.x-22, y: cell.mainView.center.y-10)
            cell.dateLabel.text = data["Date"]
            cell.monthlyPaymentLabel.text = data["monthly_payment"]
            cell.resizeCalcCell(byWidth: 0.8286, byHeight: 0.75)
            cell.frame.origin = CGPoint(x: -5, y: yVal)
            cell.frame.size = cell.mainView.frame.size
            cell.contentView.frame.size = cell.mainView.frame.size
            self.scrollView.addSubview(cell)
            yVal += 65
        }
    }
    
    /// Refreshes the group cell's scroll view to include only starred elements
    func refreshToStarred() {
        self.removeElements()
        self.addStarredElements()
        self.scrollView.contentSize.height = self.scrollAmount
        self.scrollView.frame.size = CGSize(width: self.scrollView.frame.width, height: self.scrollViewHeight)
        self.scrollView.frame.origin = CGPoint(x: self.scrollView.frame.origin.x, y: self.mainLabel.frame.maxY+10)
        self.changeFrames()
    }
}

// MARK: - CUSTOM TAP GESTURE RECOGNIZER

/// Custom Tap Gesture Recognizer class to allow for the passage of parameters from selectors
class CellTapGestureRecognizer: UITapGestureRecognizer {
    /// The variable that stores the calculation cell to be selected in the starred scroll view
    var calcCellSelected: CalculationCell!
}

// MARK: - CUSTOM SWIPE GESTURE RECOGNIZER

class CellSwipeGestureRecognizer: UISwipeGestureRecognizer {
    var viewSelected: UIView!
}

// MARK: - LOCALIZED

extension String {
    /// Determines the localized version of the string
    var localized: String {
        // Set default
        if let _ = UserDefaults.standard.string(forKey: "i18n_language") { print("true") } else {
            UserDefaults.standard.set("en", forKey: "i18n_language")
            UserDefaults.standard.synchronize()
        }

        // Get bundle
        let lang = UserDefaults.standard.string(forKey: "i18n_language")!
        print("Lang:", lang)
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

// MARK: - SELECTOR CARRIER

/// Simple subclass of UIButton that allows to store certain properties that can be accessed from objc functions for target
class SelectorCarrier: UIButton {
    var numeric: Int?
    var string: String?
    var bool: Bool?
}
