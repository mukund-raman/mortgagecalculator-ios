//
//  DataSource.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 12/25/19.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

/// Manages the data collected from the application and deals with JSON
class DataSource : NSObject {
    
    // MARK: - DEFINITION
    
    static var starredAmt: Int = 0
    static var dataSource: [[String:String]] = []
    static var tableView = RecentsTableViewController.staticTableView
    static var jsonURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("dataSource.json")
    
    // MARK: - JSON FUNCTONS
    
    /// Creates a JSON object and parses it into the JSON file
    /// - Parameter dict: The dictionary from which the JSON object is created
    class func createJSON(fromDict dict: [String:String]) {
        // Read the current JSON file into the array of dictionaries
        self.readJSON()
        
        // Adds the parameter dictionary to the total array of dictionaries
        self.dataSource.append(dict)
        
        // Writes to the JSON file the current array of dictionaries
        self.writeJSON()
        
        // Reload table data
        self.tableView.reloadData()
        print("tableView subviews count:", self.tableView.subviews.filter({ view in
            if let _ = view as? UITableViewCell { return true }
            else { return false }
        }).count)
        for i in 0..<RecentsTableViewController.tableViewDataSource.count {
            RecentsViewController.recentsViewController!.tableViewController.tableView(self.tableView, cellForRowAt: IndexPath(item: 0, section: i))
        }
    }
    
    /// Reads the JSON from the JSON file and stores it into the data source array of dictionaries
    class func readJSON() {
        // Guard statements to get the data from the file and parse it into JSON object
        if !FileManager.default.fileExists(atPath: self.jsonURL.path) {
            do { try "[\n\n]".write(to: self.jsonURL, atomically: true, encoding: .utf8) }
            catch { preconditionFailure(error.localizedDescription) }
        }
        guard let data = try? Data(contentsOf: self.jsonURL) else {
            preconditionFailure("Not convertible to DATA")
        }
        guard let json = try? JSON(data: data) else { preconditionFailure("Not convertible to JSON") }
        
        // Configure the json object and store in the dataSource object
        self.dataSource = json.arrayValue.map { elem in
            let dict1: Dictionary<String, JSON> = elem.dictionaryValue
            var dict2 = [String:String]()
            dict1.forEach { dict2[$0.key] = $0.value.stringValue }
            return dict2
        }
    }
    
    /// Writes the current data source to the JSON file
    class func writeJSON() {
        // Parse the current array of dictionaries into a JSON object
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self.dataSource, options: .prettyPrinted) else {
            assertionFailure("Unable to parse JSON")
            return
        }
        
        // Write the string representation of beautified JSON to the JSON file
        let stringVal: String = String(data: jsonData, encoding: .init(rawValue: 1))!
        do { try stringVal.write(to: self.jsonURL, atomically: true, encoding: .utf8) }
        catch { preconditionFailure(error.localizedDescription) }
    }
    
    /// Writes the group data to the JSON file
    /// - Parameters:
    ///   - name: The name of the group
    ///   - isStarred: A boolean value indicating whether the group is starred
    class func writeGroupToJSON(withName name: String, isStarred: Bool, groupKey: String) {
        // Create the date and dateformatter object used to show when the calculation was created
        let date: Date = Date()
        let dateFormatter = DateFormatter()
        var dateArray: [String] = []
        
        // Add the current month to the current date array
        dateFormatter.dateFormat = "LLLL"
        dateArray.append(dateFormatter.string(from: date))
        
        // Add the current day to the current date array
        dateFormatter.dateFormat = "d"
        dateArray.append(dateFormatter.string(from: date))
        
        // Add the current year to the current date array
        dateFormatter.dateFormat = "yyyy"
        dateArray.append(dateFormatter.string(from: date))
        
        // Create the group data dictionary and write it to the JSON file
        let groupDict: [String:String] = [
            "group_name" : name,
            "Date" : dateArray[0] + " " + dateArray[1] + ", " + dateArray[2],
            "isStarred" : String(isStarred),
            "GroupKey" : groupKey
        ]
        self.createJSON(fromDict: groupDict)
        StarredScrollViewController.starredScrollViewController?.refreshData()
    }
    
    /// Deletes the dictionary at the specified index in the JSON file
    /// - Parameter index: The index at which to delete the element
    class func deleteDict(index: Int) {
        // Read JSON
        self.readJSON()
        
        // Remove any subcells of the given cell if needed
        let cellDict = self.dataSource[index], cellName: String!
        if let _ = cellDict["group_name"] {
            cellName = cellDict["group_name"]!
//            var indexArr: [Int] = []
//            for i in 0..<self.dataSource.count {
//                if let belongsTo = self.dataSource[i]["BelongsTo"], belongsTo == cellDict["GroupKey"] {
//                    self.dataSource.remove(at: i)
//                    indexArr.append(i)
//                }
//            }
//            for i in indexArr { self.dataSource.remove(at: i) }
            self.dataSource.removeAll(where: { $0["BelongsTo"] != nil && $0["BelongsTo"] == cellDict["GroupKey"] })
        } else {
            cellName = cellDict["calc_title"]!
        }
        
        // Re-write the newly modified dataSource to JSON file and refresh
        self.dataSource.remove(at: index)
        self.writeJSON()
        self.tableView.reloadData()
        
        for i in self.tableView.subviews.filter({ view in
            if let _ = view as? UITableViewCell { return true }
            else { return false }
        }) {
            if let groupCell = i as? GroupCell, groupCell.mainLabel.text! == cellName {
                groupCell.removeFromSuperview()
            }
        }
        
        StarredScrollViewController.starredScrollViewController?.refreshData()
    }
    
    // MARK: - MISC FUNCTIONS
    
    /// Switches the given group or calculation to be starred or unstarred accordingly
    /// - Parameter index: The index of the group or calculation
    class func switchStarred(index: Int) {
        self.readJSON()
        guard let starString = self.dataSource[index]["isStarred"] else { return }
        guard let isStarred = Bool(starString) else { preconditionFailure("Failed") }
        if isStarred { self.dataSource[index]["isStarred"] = "false" }
        else { self.dataSource[index]["isStarred"] = "true" }
        self.writeJSON()
    }
    
    /// Updates each calculation that belongs to the group at the given index
    /// - Parameters:
    ///   - index: The index of the calculation
    ///   - newName: The new name of the group
    class func updateBelongsTo(index: Int, newName: String) {
        guard let oldName = self.dataSource[index]["group_name"] else { return }
        for i in 0..<self.dataSource.count {
            if self.dataSource[i]["BelongsTo"] == oldName {
                self.dataSource[i]["BelongsTo"] = newName
            }
        }
        self.writeJSON()
    }
    
    /// Changes the name of a calculation
    /// - Parameters:
    ///   - newCalcName: The new name for the calculation
    ///   - calcUUID: The unique identifier of the calculation
    class func changeCalcName(newCalcName: String, calcUUID: String) {
        self.readJSON()
        for i in 0..<self.dataSource.count {
            if self.dataSource[i]["CalculationKey"] == calcUUID, newCalcName != self.dataSource[i]["calc_title"] {
                self.dataSource[i]["calc_title"] = newCalcName
                self.writeJSON()
                self.tableView.reloadData()
                StarredScrollViewController.starredScrollViewController?.refreshData()
            }
        }
    }
}
