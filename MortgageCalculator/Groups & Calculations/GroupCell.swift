//
//  GroupCell.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 6/20/21.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

/// Defines the properties and attributes for the new group table view cell
class GroupCell: UITableViewCell {
    
    // MARK: DEFINITION
    
    // The variables and UI elements used for the starred button
    var index: Int!
    var key: String!
    var isStarred: Bool = false
    var starredButton: UIButton = UIButton()
    let selectedView: UIImageView = UIImageView(image: UIImage(named: "filledStar"))
    let unselectedView: UIImageView = UIImageView(image: UIImage(named: "emptyStar"))
    
    // Stores all the child calculation cells in an array for easier use
    var calculationCells: [CalculationCell] {
        var arr: [CalculationCell] = []
        for view in self.scrollView.subviews {
            if let calcCell = view as? CalculationCell {
                arr.append(calcCell)
            }
        }
        return arr
    }
    
    // The variables and UI elements used for the group plus button
    let plusButton: UIButton = UIButton()
    let plusImageView: UIImageView = UIImageView(image: UIImage(named: "groupPlusButton"))
    
    // The variables used to create the edit button
    let groupEditButton: UIButton = UIButton()
    let editImageView: UIImageView = UIImageView(image: UIImage(named: "Edit"))
    
    // The variables used to create a scroll view containing all of the child calculations
    static var heightList: [String:Int] = [:]
    var scrollAmount: CGFloat { return CGFloat(70 * Double(self.subviewCount)) }
    var scrollViewHeight: CGFloat { return min(210, CGFloat(70 * Double(self.subviewCount))) }
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentSize.height = 100
        view.backgroundColor = UIColor.darkBlue1
        view.frame = CGRect (
            x: CGFloat.toProp(30, true), y: 0,
            width: self.mainView.frame.width-50,
            height: 0
        )
        view.isScrollEnabled = true
        return view
    }()
    var subviewCount: Int {
        var count: Int = 0
        for view in self.scrollView.subviews {
            if let _ = view as? CalculationCell { count+=1 }
        }
        return count
    }
    
    // The major UI elements used in the cell
    fileprivate(set) var mainView: UIView = UIView()
    let dateLabel: UILabel = UILabel(frame:
        CGRect (
            x: CGFloat.toProp(200, true),
            y: CGFloat.toProp(12, false),
            width: CGFloat.toProp(110, true),
            height: CGFloat.toProp(40, false)
        )
    )
    let mainLabel: UILabel = UILabel(frame:
        CGRect (
            x: CGFloat.toProp(25, true),
            y: CGFloat.toProp(15, false),
            width: CGFloat.toProp(150, true),
            height: CGFloat.toProp(40, false)
        )
    )

    // MARK: INITIALIZERS
    
    /// Required intializer
    /// - Parameter coder: An unarchiver object
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Initializer for new group cell
    /// - Parameters:
    ///   - style: A constant indicating a cell style
    ///   - reuseIdentifier: A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // Call designated initializer and setup the background color of the cell
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // Add all UI elements to the cell
        self.contentView.addSubview(self.mainView)
        self.mainView.frame.size = CGSize(width: CGFloat.toProp(350, true), height: 125)
        self.mainView.isUserInteractionEnabled = true
        self.mainView.addSubview(self.mainLabel)
        self.mainView.addSubview(self.dateLabel)
        
        // Setup properties of the main view
        self.mainView.clipsToBounds = true
        self.mainView.layer.cornerRadius = 15
        self.mainView.layer.borderWidth = 0.25
        self.mainView.backgroundColor = .clear
        self.mainView.layer.borderColor = UIColor.white.cgColor
        
        // Setup the properties of the mainLabel
        self.mainLabel.text = ""
        self.mainLabel.textAlignment = .left
        self.mainLabel.adjustsFontSizeToFitWidth = true
        self.mainLabel.textColor = UIColor.lightOrange1
        self.mainLabel.backgroundColor = .clear
        self.mainLabel.font = UIFont(name: "HelveticaNeue", size: 23)
        
        // Setup the properties of the dateLabel
        self.dateLabel.text = ""
        self.dateLabel.textColor = .darkGray
        self.dateLabel.backgroundColor = .clear
        self.dateLabel.adjustsFontSizeToFitWidth = true
        self.dateLabel.font = UIFont(name: "HelveticaNeue", size: 23)
        
        // Sets up the starred button frame
        self.starredButton.frame = CGRect (
            x:  CGFloat.toProp(80, true),
            y: self.mainView.frame.maxY-55,
            width: 30,
            height: 30
        )
        self.mainView.addSubview(self.starredButton)
        self.starredButton.backgroundColor = .clear
        self.starredButton.addTarget(self, action: #selector(self.switchStarredButton), for: .touchUpInside)
        
        // Sets up the selected view for the starred button
        self.selectedView.frame = CGRect(x: -3, y: 0, width: 34.29, height: 30)
        self.selectedView.image = self.selectedView.image?.withTintColor(.white, renderingMode: .alwaysTemplate)
        self.selectedView.image = UIGraphicsImageRenderer(size: self.selectedView.bounds.size).image { (context) in
            self.selectedView.image!.draw(in: CGRect(origin: .zero, size: self.selectedView.bounds.size))
        }
        
        // Sets up the unselected view for the starred button
        self.starredButton.addSubview(self.unselectedView)
        self.unselectedView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.unselectedView.image = self.unselectedView.image?.withTintColor(.white, renderingMode: .alwaysTemplate)
        self.unselectedView.image = UIGraphicsImageRenderer(size: self.unselectedView.bounds.size).image { (context) in
            self.unselectedView.image!.draw(in: CGRect(origin: .zero, size: self.unselectedView.bounds.size))
        }
        
        // Sets up the plus button for the creation of a calculation inside the current group
        self.plusButton.frame = CGRect (
            x: CGFloat.toProp(150, true),
            y: self.mainView.frame.maxY-65,
            width: 50,
            height: 50
        )
        self.mainView.addSubview(self.plusButton)
        self.plusButton.backgroundColor = .clear
        self.plusButton.addTarget(self, action: #selector(self.createNewCalculation), for: .touchUpInside)
        
        // Sets up the image view used as part of the plus button
        self.plusButton.addSubview(self.plusImageView)
        self.plusImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.plusImageView.image = self.plusImageView.image?.withTintColor(UIColor.lightOrange1, renderingMode: .alwaysTemplate)
        self.plusImageView.image = UIGraphicsImageRenderer(size: self.plusImageView.bounds.size).image { (context) in
            self.plusImageView.image!.draw(in: CGRect(origin: .zero, size: self.plusImageView.bounds.size))
        }
        
        // Sets up the group edit button frame and properties
        self.groupEditButton.frame = CGRect (
            x: CGFloat.toProp(245, true),
            y: self.mainView.frame.maxY-55,
            width: 30,
            height: 30
        )
        self.mainView.addSubview(self.groupEditButton)
        self.groupEditButton.backgroundColor = .clear
        self.groupEditButton.addTarget(self, action: #selector(self.renameGroup), for: .touchUpInside)
        
        // Sets up the edit image view for the group edit button
        self.groupEditButton.addSubview(self.editImageView)
        self.editImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.editImageView.image = self.editImageView.image?.withTintColor(.white, renderingMode: .alwaysTemplate)
        self.editImageView.image = UIGraphicsImageRenderer(size: self.editImageView.bounds.size).image { (context) in
            self.editImageView.image!.draw(in: CGRect(origin: .zero, size: self.editImageView.bounds.size))
        }
        
        // Setup the properties of the scroll view
        self.mainView.addSubview(self.scrollView)
    }
    
    // MARK: FUNCTIONS
    
    /// Gets the previous starred state of the cell
    func getStarred() { self.isStarred = Bool(DataSource.dataSource[self.index]["isStarred"]!)! }
    
    /// Switches the button from being starred to unstarred and vice versa
    @objc public func switchStarredButton() {
        // Switches state of being starred
        self.isStarred = !self.isStarred
        self.switchStarredView()
        DataSource.switchStarred(index: self.index)
        
        // Stars every child calculation cell as well if the group cell is about to be starred
        for view in self.scrollView.subviews {
            if let calcCell: CalculationCell = view as? CalculationCell, self.isStarred {
                if !calcCell.isStarred {
                    calcCell.isStarred = !calcCell.isStarred
                    calcCell.switchStarredView()
                    DataSource.switchStarred(index: calcCell.index)
                }
                calcCell.isStarred = true
                DataSource.dataSource[index]["isStarred"] = "true"
            }
        }
        
        // Writes the changes to the JSON file and reloads table data
        DataSource.writeJSON()
        DataSource.tableView.reloadData()
        (RecentsTableViewController.tableViewCells.first(where: { elem in
            if let groupCell = elem as? GroupCell, groupCell.mainLabel.text! == self.mainLabel.text! {
                return true
            }
            return false
        }) as! GroupCell).isStarred = self.isStarred
        print("Group Cell", self.mainLabel.text!, "is starred:", (RecentsTableViewController.tableViewCells.first(where: { elem in
            if let groupCell = elem as? GroupCell, groupCell.mainLabel.text! == self.mainLabel.text! {
                return true
            }
            return false
        }) as! GroupCell).isStarred)
        
        StarredScrollViewController.starredScrollViewController?.refreshData()
    }
    
    /// Switches between a starred and unstarred view of the star button
    func switchStarredView() {
        if self.isStarred {
            self.unselectedView.removeFromSuperview()
            self.starredButton.addSubview(self.selectedView)
        }
        else {
            self.selectedView.removeFromSuperview()
            self.starredButton.addSubview(self.unselectedView)
        }
    }
    
    /// Opens the new calculation page from the group plus button
    @objc func createNewCalculation() {
        let view = self.window!.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]
        if let _ = view as? UITableView {
            let mainViewController: RecentsViewController = RecentsViewController.recentsViewController!
            mainViewController.startingGroup = self.key
            mainViewController.startingGroupCell = self
            mainViewController.openCalc()
        } else {
            let mainViewController: StarredViewController = StarredViewController.starredViewController!
            mainViewController.startingGroup = self.key
            mainViewController.startingGroupCell = self
            mainViewController.openCalc()
        }
    }
    
    /// Refreshes the scroll view
    func refreshScrollView() {
        self.removeElements()
        self.addElements()
        self.scrollView.contentSize.height = self.scrollAmount
        self.scrollView.frame.size = CGSize(width: self.scrollView.frame.width, height: self.scrollViewHeight)
        self.scrollView.frame.origin = CGPoint(
            x: self.scrollView.frame.origin.x,
            y: self.mainLabel.frame.maxY+12
        )
        GroupCell.heightList[self.mainLabel.text!] = self.subviewCount
        self.changeFrames()
    }
    
    /// Changes the frames of the group cell accordingly
    /// - Parameter isTrue: A boolean value indicating whether the frames of the group should increase or not
    func changeFrames(_ isTrue: Bool = true) {
        self.mainView.frame.size = CGSize(
            width: self.mainView.frame.width,
            height: self.mainView.frame.height+(isTrue ? self.scrollViewHeight+10 : 0)
        )
        self.frame.size = self.mainView.frame.size
        self.starredButton.frame = CGRect (
            x: CGFloat.toProp(80, true),
            y: self.mainView.frame.maxY-55,
            width: 30,
            height: 30
        )
        self.plusButton.frame = CGRect (
            x: CGFloat.toProp(150, true),
            y: self.mainView.frame.maxY-65,
            width: 50,
            height: 50
        )
        self.groupEditButton.frame = CGRect (
            x: CGFloat.toProp(245, true),
            y: self.mainView.frame.maxY-55,
            width: 30,
            height: 30
        )
    }
    
    /// Adds the different cells to the scroll view
    func addElements() {
        var yVal: Int = 0
        for i in 0..<DataSource.dataSource.count {
            let data = DataSource.dataSource[i]
            guard data["BelongsTo"] == self.key else { continue }
            print("index of calculation cell when adding to group", self.mainLabel.text!, ":", i)
            
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
    
    /// Removes all of the cells from the scroll view
    func removeElements() {
        for view in self.scrollView.subviews {
            if let calcCell: CalculationCell = view as? CalculationCell {
                calcCell.removeFromSuperview()
            }
        }
    }
    
    /// Alerts the user with a message to rename the group
    @objc func renameGroup() {
        let view = self.window!.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0]
        if let _ = view as? UITableView {
            let mainViewController: RecentsViewController = RecentsViewController.recentsViewController!
            mainViewController.renameGroup(forIndex: index)
        } else {
            let mainViewController: StarredViewController = StarredViewController.starredViewController!
            mainViewController.renameGroup(forIndex: index)
        }
    }
}
