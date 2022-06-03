//
//  RecentsTableView.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 12/25/19.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

/// Manages the table view that contains each of the calculation and group cells inside of the recents screen
class RecentsTableViewController : UIViewController, UITableViewDelegate {
    
    // MARK: - DEFINITION
    
    // Creates the constants & variables required for the table view
    var safeArea: UILayoutGuide!
    static let staticTableView: UITableView = UITableView()
    static var tableViewDataSource: [[String:String]] {
        get {
            let dataSource = DataSource.dataSource
            var newDataSource: [[String:String]] = []
            for i in 0..<dataSource.count {
                let elem = dataSource[i]
                if let belongsTo = elem["BelongsTo"], belongsTo == "null" {
                    newDataSource.append(elem)
                }
                else if let _ = elem["GroupKey"] {
                    newDataSource.append(elem)
                }
            }
            return newDataSource
        }
    }
    let tableView = RecentsTableViewController.staticTableView
    
    /// Contains all of the cells used in the recents table view
    static var tableViewCells: [UITableViewCell] {
        DataSource.readJSON()
        var arr: [UITableViewCell] = Array(repeating: UITableViewCell(), count: self.tableViewDataSource.count)
        print("tableView subviews count:", self.staticTableView.subviews.filter({ view in
            if let _ = view as? UITableViewCell { return true }
            else { return false }
        }).count)
        for view in self.staticTableView.subviews {
            if let cell = view as? CalculationCell { arr.append(cell) }
            else if let cell = view as? GroupCell {
                print("groupCell:", cell)
                let index = DataSource.dataSource.firstIndex(where: { elem in
//                    print(elem)
                    return elem["GroupKey"] == cell.key
                })
                
                if let i = index {
//                    print("index of cell", cell.mainLabel.text!, ":", i)
                    print("i:", i)
                    arr[i] = cell
//                    if i < arr.count { arr.insert(cell, at: i) }
//                    else { arr.append(cell) }
                }
                else {
                    print("INDEX FOR GROUPCELL", cell.mainLabel.text!, "NOT FOUND")
                }
            }
        }
//        for cell in arr {
//            if let calcCell = cell as? CalculationCell {
//                print(calcCell.mainLabel.text!)
//            }
//            else {
//                print((cell as! GroupCell).mainLabel.text!)
//            }
//        }
        return arr
    }
    
    // MARK: - FUNCTIONS
    
    /// Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the data source of the tableView and sets up the table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.setupTableView()
    }
    
    /// Creates the view that the controller manages
    override func loadView() {
        super.loadView()
    }
    
    /// Reloads table view data once the new calculation is created by the user
    /// - Parameter sender: The button that called this function
    @objc func didCreateCalc(_ sender: UIButton) {
        self.tableView.reloadData()
    }
    
    /// Sets up the table view for displaying the calculation and group cells
    func setupTableView() {
        // Adds tableView as a subview
        view.addSubview(self.tableView)
        
        /* Sets the auto resizing mask constraint to false, then manually sets the constraints
           to that of the root view, and setting the background to the dark color of the theme */
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.tableView.backgroundColor = UIColor.darkBlue1
        self.tableView.estimatedSectionHeaderHeight = 30
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.tableView.frame.height)
        self.tableView.contentSize = CGSize(width: self.tableView.frame.size.width, height: self.tableView.contentSize.height)
        self.tableView.alwaysBounceHorizontal = false
        
        // Registers a UITableViewCell that is part of the table view, with all of the rows
        self.tableView.register(CalculationCell.self, forCellReuseIdentifier: "calcCell")
        self.tableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
    }
}
