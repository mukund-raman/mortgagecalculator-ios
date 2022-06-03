//
//  CustomAlertController.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 3/23/20.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//	

import Foundation
import UIKit

/// Custom Alert Controller that allows detailed customization of the alert actions and colors
class SelectionAlertController: UIViewController {

    // MARK: - DEFINITION
    
    // Elements used in the alert dialog message form of the controller
    var mainView: UIView!
    var rowHeight: Int!
    lazy var firstLabelText: String = self.rows[0].mainLabel.text?.localized ?? ""
    lazy var firstLabelColor: UIColor = self.rows[0].mainLabel.textColor
    
    /// An array of custom alert rows to represent all of the rows in the alert controller
    var rows: [CustomAlertRow] = []
    
    /// Computed property determining whether the first row is a cancel row or not
    var firstIsCancel: Bool = false {
        willSet {
            // If the new value is false, make sure that all the rows are indented equally
            guard newValue else {
                // Change the cancel row to become a normal row again
                self.transformIntoNormalRow(cancelRow: &self.rows[0])
                
                // Iterate through each row and position them accordingly
                var yCoord: Int = Int(self.view.frame.height-130)
                for index in 0..<self.rows.count {
                    // Get the current row and set the center of the row
                    var currentRow = self.rows[index]
                    currentRow.center = CGPoint(x: Int(currentRow.center.x), y: yCoord)
                    
                    // Add any extra attributes to the current row
                    self.addAttributes(forIndex: index, endIndex: self.rows.count-1, row: &currentRow)
                    yCoord -= self.rowHeight
                }
                return
            }
            
            // Store the first row in a cancel row var and change it to become a cancel row
            var cancelRow = self.rows[0]
            cancelRow.subviews[cancelRow.subviews.count-1].removeFromSuperview()
            self.transformIntoCancelRow(alertRow: &cancelRow)
            
            // Iterate through each row except the first and move them up
            for index in 1..<self.rows.count {
                // Get the current row and set the center of the row
                var currRow = self.rows[index]
                currRow.center = CGPoint(x: currRow.center.x, y: currRow.center.y-10)
                
                // Add any extra attributes to the current row
                self.addAttributes(forIndex: index, startIndex: 1, endIndex: self.rows.count-1, row: &currRow)
            }
        }
    }
    
    // MARK: - INITIALIZERS
    
    /// Sets up the alert message being displayed
    /// - Parameter numberOfRows: The number of rows in the alert controller
    init(numberOfRows: Int) {
        // Setup the basic information for the UI elements
        self.mainView = UIView()
        
        // Call the parent's initializer
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .clear
        
        // Set the max height and call the setup UI Elements function
        self.rowHeight = 55
        self.setupUIElements(numberOfRows, self.rowHeight)
    }
    
    /// A required initializer when implementing UIViewController
    /// - Parameter coder: An unarchiver object
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - FUNCTIONS
    
    /// Adds the attributes of rounded corners and separators to the rows
    /// - Parameters:
    ///   - index: The index of the row to add rounded corners and separators to
    ///   - startIndex: The starting index of the array of rows (default is 0)
    ///   - endIndex: The ending index of the array of rows
    ///   - currRow: The current row that is to be modified
    func addAttributes(forIndex index: Int, startIndex: Int = 0, endIndex: Int, row currRow: inout CustomAlertRow) {
        // If the element is the first or last, then add 2 rounded corners for each
        if index == startIndex {
            // Create the mask path used to round the corners of the current row
            let maskPath = UIBezierPath(roundedRect: currRow.bounds,
                        byRoundingCorners: [.bottomLeft, .bottomRight],
                        cornerRadii: CGSize(width: 15.0, height: 15.0))

            // Create a ShapeLayer() object to be used to round the corners of the current row
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            currRow.layer.mask = shape
        }
        else if index == endIndex {
            // Create the mask path used to round the corners of the current row
            let maskPath = UIBezierPath(roundedRect: currRow.bounds,
                        byRoundingCorners: [.topLeft, .topRight],
                        cornerRadii: CGSize(width: 15.0, height: 15.0))
            
            // Create a ShapeLayer() object to be used to round the corners of the current row
            let shape = CAShapeLayer()
            shape.path = maskPath.cgPath
            currRow.layer.mask = shape
            return
        }
        
        // Add a border for the current row to separate it from the next row
        currRow.addBorder(side: .top, color: .gray, thickness: 1)
    }
    
    /// Transforms the given row into a cancel row
    /// - Parameter alertRow: The row to be modified into a cancel row
    func transformIntoCancelRow(alertRow: inout CustomAlertRow) {
        // Store the original text and color in case the caller changes the cancel back
        self.firstLabelText = alertRow.mainLabel.text?.localized ?? ""
        self.firstLabelColor = alertRow.mainLabel.textColor
        
        // Setup properties for the alert row
        alertRow.frame = CGRect(x: alertRow.frame.minX, y: self.view.frame.height-CGFloat.toProp(170, false), width: alertRow.frame.width, height: 120)
        alertRow.layer.masksToBounds = true
        alertRow.layer.cornerRadius = 15
        
        // Setup the properties for the main label
        alertRow.mainLabel.text = "Cancel".localized
        alertRow.mainLabel.textColor = .red
        alertRow.mainLabel.layer.masksToBounds = true
        alertRow.mainLabel.layer.cornerRadius = 15
        alertRow.mainLabel.font = UIFont(name: "HelveticaNeue-Bold", size: alertRow.mainLabel.font.pointSize)
        
        // Setup the properties for the content button
        alertRow.contentButton.layer.masksToBounds = true
        alertRow.contentButton.layer.cornerRadius = 15
        alertRow.contentButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
    }
    
    /// Transforms the given cancel row back into a normal row to be added alongside the other rows
    /// - Parameter alertRow: The row to be modified back into a normal row
    func transformIntoNormalRow(cancelRow: inout CustomAlertRow) {
        cancelRow.mainLabel.text = self.firstLabelText.localized
        cancelRow.mainLabel.textColor = self.firstLabelColor
        cancelRow.contentButton.removeTarget(self, action: #selector(self.close), for: .touchUpInside)
    }
    
    /// Closes the alert controller
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Sets up the UI Elements in the alert controller
    /// - Parameters:
    ///   - numberOfRows: The number of rows in the alert controller
    ///   - rowHeight: The height of each row
    func setupUIElements(_ numberOfRows: Int, _ rowHeight: Int) {
        // Setup the frame of the main view
        self.view.addSubview(mainView)
        self.mainView.frame = CGRect (
            x: 0, y: 0,
            width: self.view.frame.width,
            height: self.view.frame.height
        )
        
        // Add each row to the array and to the main view
        var yCoord: Int = Int(self.view.frame.height-CGFloat.toProp(165, false))
        for index in 0..<numberOfRows {
            // Create the custom alert row and set up the row accordingly
            var alertRow = CustomAlertRow(y: yCoord, height: rowHeight)
            self.addAttributes(forIndex: index, endIndex: numberOfRows-1, row: &alertRow)
            yCoord -= rowHeight
            
            // Add the row to the rows array and add it to the main view as a subview
            self.rows.append(alertRow)
            self.view.addSubview(alertRow)
        }
        
    }
    
    // MARK: - CUSTOM ALERT ROW
    
    /// Custom Alert Cell to represent each row in the UI alert controller
    class CustomAlertRow: UIView {
        
        // MARK: DEFINITION
        
        // UI Elements used for the cell
        fileprivate(set) var mainLabel: UILabel!
        fileprivate(set) var contentButton: UIButton!
        var background_color: UIColor = .white {
            willSet {
                self.backgroundColor = newValue
            }
        }
        var tint: CGFloat = 0 {
            willSet {
                self.contentButton.backgroundColor = UIColor.white.withAlphaComponent(newValue)
            }
        }
        
        // MARK: INITIALIZERS
        
        /// Initializer for the custom alert row
        /// - Parameters:
        ///   - y: The y-coordinate position of the alert row
        ///   - height: The height of the row
        init(y: Int, height: Int) {
            // Setup the position of the main label
            let width = Int(UIScreen.main.bounds.width)-50
            self.mainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
            self.mainLabel.font = UIFont(name: "HelveticaNeue", size: 18)
            self.mainLabel.textAlignment = .center
            
            // Setup the position of the content button
            self.contentButton = UIButton()
            self.contentButton.addSubview(self.mainLabel)
            self.contentButton.frame = self.mainLabel.frame
            
            // Call the superclass's initializer to set up the ui view
            super.init(frame: CGRect(x: 0, y: y, width: width, height: height))
            self.center = CGPoint(x: UIScreen.main.bounds.width/2, y: self.center.y)
            self.backgroundColor = self.background_color
            self.addSubview(self.contentButton)
        }
        
        /// Required initializer when implementing UIView
        /// - Parameter coder: An unarchiver object
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    }
}
