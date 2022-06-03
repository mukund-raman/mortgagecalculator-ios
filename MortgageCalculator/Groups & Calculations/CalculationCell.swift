//
//  NewCalculationCell.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 6/20/21.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import UIKit

/// Defines the properties and attributes for the new calculation table view cell
class CalculationCell : UITableViewCell {
    
    // MARK: DEFINITION
    
    var index: Int!
    var key: String!
    var groupCell: GroupCell? = nil
    var isStarred: Bool = false
    let dateLabel: UILabel = UILabel()
    let starredButton: UIButton = UIButton()
    let monthlyPaymentLabel: UILabel = UILabel()
    let selectedView: UIImageView = UIImageView(image: UIImage(named: "filledStar"))
    let unselectedView: UIImageView = UIImageView(image: UIImage(named: "emptyStar"))
    let arrowView: UIImageView = UIImageView(image: UIImage(named: "thin_side_arrow"))
    fileprivate(set) var mainView: UIView = UIView()
    static var isTableView: UIScrollView!
    var groupKey: String! = "null" {
        willSet {
            for cell in RecentsTableViewController.tableViewCells {
                if let groupCell: GroupCell = cell as? GroupCell, groupCell.key == newValue {
                    self.groupCell = groupCell
                }
            }
        }
    }
    let mainLabel: UILabel = UILabel(frame:
        CGRect (
            x: CGFloat.toProp(70, true),
            y: CGFloat.toProp(13, false),
            width: 150,
            height: 27
        )
    )
    
    // MARK: INITIALIZERS
    
    /// Required intializer
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Initializer for the new calculation cell
    /// - Parameters:
    ///   - style: A constant indicating a cell style
    ///   - reuseIdentifier: A string used to identify the cell object if it is to be reused for drawing multiple rows of a table view
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // Call designated initializer and setup the background color of the cell
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // Setup the mainView used inside of the cell
        self.contentView.addSubview(self.mainView)
        self.mainView.frame.size = CGSize(width: CGFloat.toProp(350, true), height: 80)
        self.mainView.clipsToBounds = true
        self.mainView.layer.cornerRadius = 15
        self.mainView.layer.borderWidth = 0.25
        self.mainView.layer.borderColor = UIColor.white.cgColor
        self.mainView.backgroundColor = UIColor.darkBlue2
        
        // Set up a tap gesture recognizer that opens the calculation details when clicked
        self.mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openCalcDetails)))
        
        // Setup the main UILabel used inside of the main view
        self.mainView.addSubview(self.mainLabel)
        self.mainLabel.text = ""
        self.mainLabel.textAlignment = .center
        self.mainLabel.adjustsFontSizeToFitWidth = true
        self.mainLabel.textColor = UIColor.lightOrange1
        self.mainLabel.font = UIFont(name: "HelveticaNeue", size: 17)
        
        // Setup the date label used inside of the main view
        self.mainView.addSubview(self.dateLabel)
        self.dateLabel.text = ""
        self.dateLabel.textColor = .darkGray
        self.dateLabel.adjustsFontSizeToFitWidth = true
        self.dateLabel.font = UIFont(name: "HelveticaNeue", size: 17)
        self.dateLabel.frame = CGRect (
            x: CGFloat.toProp(92.5, true),
            y: self.mainView.frame.maxY/2,
            width: 104.5,
            height: 30
        )
        
        // Setup the monthly payment label used inside of the main view
        self.mainView.addSubview(self.monthlyPaymentLabel)
        self.monthlyPaymentLabel.text = ""
        self.monthlyPaymentLabel.numberOfLines = 0
        self.monthlyPaymentLabel.adjustsFontSizeToFitWidth = true
        self.monthlyPaymentLabel.textColor = UIColor.lightOrange1
        self.monthlyPaymentLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        self.monthlyPaymentLabel.frame = CGRect (
            x: CGFloat.toProp(250, true),
            y: self.mainView.frame.maxY/4,
            width: 60,
            height: CGFloat.toProp(40, true)
        )
        
        // Create an image view to store the side arrow to be displayed on the right side of the cell
        self.mainView.addSubview(self.arrowView)
        self.arrowView.frame = CGRect(
            x: CGFloat.toProp(320, true),
            y: self.mainView.frame.maxY/4,
            width: 24,
            height: 40
        )
        self.arrowView.image = self.arrowView.image?.withTintColor(UIColor.lightOrange1, renderingMode: .alwaysOriginal)
        self.arrowView.image = UIGraphicsImageRenderer(size: self.arrowView.bounds.size).image { (context) in
            self.arrowView.image!.draw(in: CGRect(origin: .zero, size: self.arrowView.bounds.size))
        }
        
        // Sets up the starred button frame
        self.starredButton.frame = CGRect (
            x:  CGFloat.toProp(20, true),
            y: self.mainView.frame.maxY/3.2,
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
        self.unselectedView.image = UIGraphicsImageRenderer(size: self.arrowView.bounds.size).image { (context) in
            self.unselectedView.image!.draw(in: CGRect(origin: .zero, size: self.arrowView.bounds.size))
        }
        
        // Resize the main and content view to fit the group cell
        self.frame.size = self.mainView.frame.size
        self.contentView.frame.size = self.mainView.frame.size
    }
    
    // MARK: FUNCTIONS
    
    /// Resizes all of the UI Elements according to the percentage provided
    /// - Parameters:
    ///   - percentWidth: The percent by which the width should be scaled
    ///   - percentHeight: The percent by which the height should be scaled
    func resizeCalcCell(byWidth percentWidth: CGFloat, byHeight percentHeight: CGFloat) {
        guard percentWidth < 1.0, percentWidth > 0.0 else { return }
        guard percentHeight < 1.0, percentHeight > 0.0 else { return }
        self.mainView.transform = CGAffineTransform(scaleX: percentWidth, y: percentHeight)
    }
    
    /// Gets the previous starred state of the cell
    func getStarred() { self.isStarred = Bool(DataSource.dataSource[index]["isStarred"]!)! }
    
    /// Switches the button from being starred to unstarred and vice versa
    @objc func switchStarredButton() {
        self.isStarred = !self.isStarred
        if self.groupKey != "null" {
            let groupCell = RecentsTableViewController.tableViewCells.first(where: { elem in
                if let groupCell = elem as? GroupCell, groupCell.key == self.groupKey {
                    return true
                }
                return false
            }) as! GroupCell
            for cell in groupCell.calculationCells {
                if cell.key == self.key {
                    cell.isStarred = self.isStarred
                    break
                }
            }
        } else {
            (RecentsTableViewController.tableViewCells.first(where: { elem in
                if let calcCell = elem as? CalculationCell, calcCell.mainLabel.text! == self.mainLabel.text! {
                    return true
                }
                return false
            }) as! CalculationCell).isStarred = self.isStarred
        }
        self.switchStarredView()
        DataSource.switchStarred(index: self.index)
        StarredScrollViewController.starredScrollViewController?.refreshData()
    }
    
    /// Opens the calculation details page for this cell
    @objc func openCalcDetails() {
        CalculationCell.isTableView = self.window!.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0] as? UIScrollView
        let nextController: CalculationPageController = CalculationPageController(calculationCell: self)
        if let _ = CalculationCell.isTableView as? UITableView {
            let mainViewController: RecentsViewController = RecentsViewController.recentsViewController!
            mainViewController.navigationBar.isHidden = true
            nextController.backButton = mainViewController.recentsBackButton
            nextController.backButton.addTarget(nextController, action: #selector(nextController.close), for: .touchUpInside)
            nextController.view.addSubview(nextController.backButton)
            nextController.backButton.isHidden = false
            mainViewController.show(nextController, sender: mainViewController)
        } else {
            let mainViewController: StarredViewController = StarredViewController.starredViewController!
            mainViewController.navigationBar.isHidden = true
            nextController.backButton = mainViewController.starredBackButton
            nextController.backButton.addTarget(nextController, action: #selector(nextController.close), for: .touchUpInside)
            nextController.view.addSubview(nextController.backButton)
            nextController.backButton.isHidden = false
            mainViewController.show(nextController, sender: mainViewController)
        }
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
}
