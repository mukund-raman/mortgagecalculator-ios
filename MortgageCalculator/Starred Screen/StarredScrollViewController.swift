//
//  StarredTableViewController.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 3/16/20.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

/// Manages the scroll view that contains each of the calculation and group cells inside of the starred screen
class StarredScrollViewController : UIViewController  {

    // MARK: - DEFINITION
    
    /// The static variable that holds the instance of the starred scroll view controller
    static var starredScrollViewController: StarredScrollViewController?
    
    /// The UIScrollView containing all of the starred calculation & group cells
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentSize.height = 300
        view.backgroundColor = UIColor.darkBlue1
        view.frame = CGRect (
            x: 0, y: 0,
            width: self.view.frame.width,
            height: self.view.frame.height
        )
        view.isScrollEnabled = true
        return view
    }()
    
    /// The variable that stores the amount to scroll for based on the number of elements in the scroll view
    var scrollAmount: CGFloat {
        let amount = self.scrollView.subviews.count
        if amount == 0 { return 0 }
        else if amount <= 7 { return 800 }
        else { return CGFloat(800 * Double(amount)/6.5) }
    }
    
    // MARK: - FUNCTIONS
    
    /// Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        StarredScrollViewController.starredScrollViewController = self
        view.backgroundColor = UIColor.darkBlue1
        view.addSubview(self.scrollView)
        self.refreshData()
    }

    /// Adds the UI elements to the scroll view
    func addElements() {
        // Iterate through each starred cell and add it to the scroll view
        DataSource.readJSON()
        print("tableViewDataSource count:", RecentsTableViewController.tableViewDataSource.count)
        print("tableViewDataSource:")
        for i in RecentsTableViewController.tableViewDataSource {
            print("\t", i)
        }
        print("tableViewCells count:", RecentsTableViewController.tableViewCells.count)
        print("tableViewCells:")
        for i in RecentsTableViewController.tableViewCells {
            print("\t", i)
        }
        print("dataSource count:", DataSource.dataSource.count)
        print("dataSource:")
        for i in DataSource.dataSource {
            print("\t", i)
        }
        var yVal: CGFloat = 30
        for i in 0..<RecentsTableViewController.tableViewDataSource.count {
            let data = RecentsTableViewController.tableViewDataSource[i]
            let actualIndex = DataSource.dataSource.firstIndex(of: data)
            print("actualIndex:", actualIndex!)
            var currCell: UITableViewCell
            
            if i == RecentsTableViewController.tableViewCells.count {
                if let name = data["group_name"] {
                    let cell = GroupCell(style: .default, reuseIdentifier: "groupCell")
                    cell.key = data["GroupKey"]
                    cell.index = DataSource.dataSource.firstIndex(where: { elem in return elem["GroupKey"] == cell.key })
                    cell.getStarred()
                    cell.switchStarredView()
                    cell.mainLabel.text = name
                    cell.dateLabel.text = data["Date"]
                    currCell = cell
                } else {
                    let cell = CalculationCell(style: .default, reuseIdentifier: "calcCell")
                    cell.key = data["CalculationKey"]
                    cell.index = DataSource.dataSource.firstIndex(where: { elem in return elem["CalculationKey"] == cell.key })
                    cell.groupKey = data["BelongsTo"]!
                    cell.getStarred()
                    cell.switchStarredView()
                    cell.mainLabel.text = data["calc_title"]
                    cell.dateLabel.text = data["Date"]
                    cell.monthlyPaymentLabel.text = data["monthly_payment"]
                    currCell = cell
                }
            } else {
//                for i in RecentsTableViewController.tableViewCells {
//                    print((i as! GroupCell).mainLabel.text!)
//                }
                currCell = RecentsTableViewController.tableViewCells[i]
            }
            
            DataSource.tableView.reloadData()
            if data["isStarred"] != "true" {
                if let groupCell = currCell as? GroupCell {
                    var hasStarred = false
                    for calcCell in groupCell.calculationCells {
                        print(calcCell.isStarred)
                        if calcCell.isStarred {
                            hasStarred = true
                            break
                        }
                    }
                    if !hasStarred {
                        continue
                    }
                }
            }
            
            print(currCell)
            // Create the cloned cell and add it as a subview to the scrollView
            if let groupCell = currCell as? GroupCell {
                // Create the cloned version of the cell
                print(i, ":", groupCell.mainLabel.text!)
//                print("actual index:", i, "; stored index:", groupCell.index)
                groupCell.index = actualIndex
                groupCell.isStarred = true
                for view in self.scrollView.subviews {
                    if let currCell: GroupCell = view as? GroupCell, currCell.key == groupCell.key {
                        continue
                    }
                }
                let cloneCell = groupCell.copyCell()
                cloneCell.refreshToStarred()
                
                // Adjust the coordinate origin of the child calculation cells so that they appear fully on the screen
                for view in cloneCell.scrollView.subviews {
                    if let calcCell = view as? CalculationCell {
                        calcCell.frame.origin = CGPoint(x: -5, y: calcCell.frame.minY)
                    }
                }
                
                // Set up the views for the delete function for the group cell
                let mainView: UIView = UIView(), contentView: UIView = UIView()
                mainView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: cloneCell.frame.height)
                mainView.frame.origin = CGPoint(x: 0, y: 0)
                self.setupSwipeGesture(view: mainView)
                contentView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: cloneCell.frame.height)
                contentView.frame.origin = CGPoint(x: 0, y: 0)
//                contentView.backgroundColor = .yellow.withAlphaComponent(0.2)
                mainView.addSubview(contentView)
                
                // Create the delete button to delete the cell
                let deleteButton: SelectorCarrier = SelectorCarrier()
                deleteButton.numeric = /*DataSource.dataSource.firstIndex(where: { elem in return elem["GroupKey"] == cloneCell.key })*/ actualIndex
                deleteButton.frame.size = CGSize(width: 75, height: cloneCell.frame.height)
                deleteButton.frame.origin = CGPoint(x: UIScreen.main.bounds.width, y: 0)
                deleteButton.backgroundColor = .systemRed
                deleteButton.addTarget(self, action: #selector(self.deleteCell(_:)), for: .touchUpInside)
                deleteButton.setTitle("Delete", for: .normal)
                deleteButton.titleLabel!.font = .systemFont(ofSize: 15, weight: .semibold)
                mainView.addSubview(deleteButton)
                contentView.addSubview(cloneCell)
                
                // Add as a subview and increment the y value
                cloneCell.center = CGPoint(x: UIScreen.main.bounds.width/2, y: cloneCell.center.y)
//                cloneCell.frame.origin = CGPoint(x: cloneCell.frame.minX, y: yVal)
//                cloneCell.mainView.frame.origin = CGPoint(x: 0, y: cloneCell.mainView.frame.minY)
//                self.scrollView.addSubview(cloneCell)
                mainView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: mainView.center.y)
                mainView.frame.origin = CGPoint(x: mainView.frame.minX, y: yVal)
                cloneCell.mainView.frame.origin = CGPoint(x: 0, y: cloneCell.mainView.frame.minY)
                self.scrollView.addSubview(mainView)
                yVal += cloneCell.frame.height + 25
            }
            else {
                // Create the cloned version of the cell
                let calcCell = currCell as! CalculationCell
                let cloneCell = calcCell.copyCell()
                
                // If the calculation cell has a parent group cell, either continue to
                // the next iteration or add the group cell with the calculation cells
                if let parentCell: GroupCell = calcCell.groupCell {
                    parentCell.getStarred()
                    if parentCell.isStarred == false {
                        // If the group cell is already in the scroll view, continue to the next iteration
                        var shouldContinue: Bool = false
                        for view in self.scrollView.subviews {
                            if let groupCell: GroupCell = view as? GroupCell, groupCell.key == parentCell.key {
                                shouldContinue = true
                            }
                        }
                        if shouldContinue { continue }
                        
                        // Create a clone of the parent group cell
                        let parentCloneCell: GroupCell = parentCell.copyCell()
                        parentCloneCell.refreshToStarred()
                        
                        // Adjust the coordinate origin of the child calculation cells so that they appear fully on the screen
                        for view in parentCloneCell.scrollView.subviews {
                            if let calcCell = view as? CalculationCell {
                                calcCell.frame.origin = CGPoint(x: -5, y: calcCell.frame.minY)
                            }
                        }
                        
                        // Add as a subview and increment the y value
                        parentCloneCell.center = CGPoint(x: UIScreen.main.bounds.width/2, y: parentCloneCell.center.y)
                        parentCloneCell.frame.origin = CGPoint(x: parentCloneCell.frame.minX, y: yVal)
                        parentCloneCell.mainView.frame.origin = CGPoint(x: 0, y: parentCloneCell.mainView.frame.minY)
                        self.scrollView.addSubview(parentCloneCell)
                        yVal += parentCloneCell.frame.height + 25
                    }
                    continue
                }
                
                // Setup the view that is shown when a row is selected (transparent/clear)
                let selectedView: UIView = UIView()
                selectedView.backgroundColor = UIColor.lightOrange1
                cloneCell.selectedBackgroundView = selectedView
                
                // Set up a tap gesture recognizer that allows the scroll view to show which calculation cell is currently selected
                let tapGesture: CellTapGestureRecognizer = CellTapGestureRecognizer(target: self, action: #selector(self.switchToSelected(sender:)))
                tapGesture.calcCellSelected = cloneCell
                cloneCell.addGestureRecognizer(tapGesture)
                
                // Add as a subview and increment the y value
                cloneCell.center = CGPoint(x: UIScreen.main.bounds.width/2, y: cloneCell.center.y)
                cloneCell.frame.origin = CGPoint(x: cloneCell.frame.minX, y: yVal)
                self.scrollView.addSubview(cloneCell)
                yVal += cloneCell.frame.height + 25
            }
        }
    }
    
    /// Sets up the swipe gesture recognizer for the cells
    /// - Parameter view: The view to set up the swipe gesture for
    func setupSwipeGesture(view: UIView) {
        var swipeGesture: CellSwipeGestureRecognizer
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
        for direction in directions {
            swipeGesture = CellSwipeGestureRecognizer(target: self, action: #selector(self.swipeView(_:)))
            swipeGesture.viewSelected = view
            view.addGestureRecognizer(swipeGesture)
            swipeGesture.direction = direction
            view.isUserInteractionEnabled = true
            view.isMultipleTouchEnabled = true
        }
    }
    
    /// Performs the swiping animation for the view
    /// - Parameter sender: The cell swipe gesture recognizer for the desired view
    @objc func swipeView(_ sender: CellSwipeGestureRecognizer) {
        let view = sender.viewSelected!
        UIView.animate(withDuration: 0.125) {
            if sender.direction == .right, view.subviews[0].frame.minX == -75 {
                view.subviews[0].frame.origin = CGPoint(x: view.subviews[0].frame.origin.x+75, y: view.subviews[0].frame.origin.y)
                view.subviews[1].frame.origin = CGPoint(x: view.subviews[1].frame.origin.x+75, y: view.subviews[1].frame.origin.y)
            } else if sender.direction == .left, view.subviews[0].frame.minX == 0 {
                view.subviews[0].frame.origin = CGPoint(x: view.subviews[0].frame.origin.x-75, y: view.subviews[0].frame.origin.y)
                view.subviews[1].frame.origin = CGPoint(x: view.subviews[1].frame.origin.x-75, y: view.subviews[1].frame.origin.y)
            }
            view.layoutIfNeeded()
            view.setNeedsDisplay()
        }
    }
    
    /// Deletes the cell
    @objc func deleteCell(_ sender: SelectorCarrier) {
        DataSource.deleteDict(index: sender.numeric!)
    }
    
    /// Switches from the current selection to the desired selection in the scroll view
    /// - Parameter sender: The custom tap gesture recognizer that stores the calculation cell that called it
    @objc func switchToSelected(sender: CellTapGestureRecognizer) {
        let cellToBeSelected: CalculationCell = sender.calcCellSelected!
        cellToBeSelected.isSelected = true
        for view in self.scrollView.subviews {
            if let cell: CalculationCell = view as? CalculationCell, cell.isSelected, cell != cellToBeSelected {
                cell.isSelected = false
            }
        }
    }
    
    /// Removes all of the elements from the scroll view
    func removeElements() {
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
    }
    
    /// Returns the associated view for the given index
    /// - Parameter index: The index of the cell desired
    /// - Returns: The UITableViewCell at that index and a boolean value indicating whether the cell is a calculation or a group
//    func returnElementAt(index: Int) -> (UITableViewCell, Bool)? {
//        // Retrieves and makes sure the data is starred
//        let data = RecentsTableViewController.tableViewDataSource[index]
//        guard data["isStarred"] == "true" else { return nil }
//
//        // If the element has just been created, make a cell and return it
//        if index == RecentsTableViewController.tableViewCells.count {
//            if let name = data["group_name"] {
//                let cell = GroupCell(style: .default, reuseIdentifier: "groupCell")
//                cell.index = index
//                cell.key = data["GroupKey"]
//                cell.getStarred()
//                cell.switchStarredView()
//                cell.mainLabel.text = name
//                cell.dateLabel.text = data["Date"]
//                return (cell, true)
//            } else {
//                let cell = CalculationCell(style: .default, reuseIdentifier: "calcCell")
//                cell.index = index
//                cell.key = data["CalculationKey"]
//                cell.groupKey = data["BelongsTo"]!
//                cell.getStarred()
//                cell.switchStarredView()
//                cell.mainLabel.text = data["calc_title"]
//                cell.dateLabel.text = data["Date"]
//                cell.monthlyPaymentLabel.text = data["monthly_payment"]
//                return (cell, false)
//            }
//        }
//
//        print("The index at which the element needs to be returned:", index)
//
//        // Get the cell and return it
//        for i in RecentsTableViewController.tableViewCells {
//            let indexNum = RecentsTableViewController.tableViewCells.firstIndex(of: i)!
//            print("The index at which the given table view cell was found in RecentsTableViewController.recentsTableViewCells:", indexNum)
//            if let calc = i as? CalculationCell {
//                print("Is the index number equal to the index at which the element needs to be returned?:", indexNum == index)
//                if indexNum == index {
//                    calc.mainLabel.text = data["calc_title"]!
//                    return (calc, false)
//                }
//            } else if let group = i as? GroupCell {
//                print(group.index)
//                if group.index == index {
//                    group.mainLabel.text = data["group_name"]!
//                    return (group, true)
//                }
//            }
//        }
//        return nil
//    }
    
    /// Refreshes the data in the scroll view
    func refreshData() {
        print("here")
        DataSource.tableView.reloadData()
        
        self.removeElements()
        self.addElements()
        self.scrollView.contentSize.height = self.scrollAmount
    }
}
