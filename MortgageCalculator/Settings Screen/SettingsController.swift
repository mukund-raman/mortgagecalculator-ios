//
//  SettingsController.swift
//  Mortgage Calculator
//
//  Created by Mukund K Raman on 3/19/20.
//  Copyright © 2021 REMA Consulting Group LLC. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

/// Manages the settings screen of the application
class SettingsController: UINavigationController, UITextFieldDelegate {
    
    // MARK: - DEFINITION
    
    // The views that contain each functionality in the settings page
    let currencyView: UIView = UIView()
    let languageView: UIView = UIView()
    let textSizeView: UIView = UIView()
    let reviewView: UIView = UIView()
    
    // The variables that contain input from the text size section
    let textSizeTextField: UITextField = UITextField()
    let textSizeSlider: UISlider = UISlider()
    
    /// The language the user has currently selected
    var selectedLanguage: String! = Locale(identifier: "en-US").localizedString(forLanguageCode: UserDefaults.standard.string(forKey: "i18n_language")!)!
    
    /// The view that contains the entire settings page
    let mainView: UIView = UIView()
    
    /// The dictionary that maps between a language and its code
    var languagesDict: [String:String] = [:]
    
    /// Generates a list of all languages and locales supported by the current iOS version
    var languages: [String] {
        var languages = [String]()
        let currentLocale = NSLocale.current as NSLocale
        for languageCode in NSLocale.availableLocaleIdentifiers {
            if let name = currentLocale.displayName(forKey: NSLocale.Key.languageCode, value: languageCode), !languages.contains(name) {
                languages.append(name)
                languagesDict.updateValue(String(languageCode.prefix(2)), forKey: name)
            }
        }
        return languages.sorted()
    }
    
    /// The variable that stores an instance of this class that is accessible anywhere
    static var settingsController: SettingsController? = nil
    
    // MARK: - FUNCTIONS
    
    /// Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        // Set the background color of the controller's view
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkBlue1
        self.textSizeTextField.delegate = self
        
        // Set up and add the main view to the controller's view
        self.view.addSubview(self.mainView)
        self.mainView.frame = CGRect (
            x: 0,
            y: CGFloat.toProp(180, false),
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height-CGFloat.toProp(260, false)
        )
    }
    
    /// Creates the view that the controller manages
    override func loadView() {
        // Loads the view and sets the colors of the navigation bar
        SettingsController.settingsController = self
        super.loadView()
        
        // Create a label that holds the navigation title of the recents page
        let label = UILabel()
        label.text = "Settings".localized
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 35)
        label.frame = CGRect (
            x: CGFloat.toProp(50, true),
            y: 0, width: CGFloat.toProp(200, true),
            height: CGFloat.toProp(100, false)
        )
        self.navigationBar.addSubview(label)
        self.navigationBar.shadowImage = UIImage()
        
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
            constant: 40
        )
        
        // Sets auto resizing mask to false and activates the layout constraint
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelTrailingConstraint,
            labelXConstraint,
            labelBottomConstraint
        ])
        
        self.setupMainView()
    }
    
    /// Opens the review area where the user can post their review of the app on the app store
    @objc func openReview() {
        SKStoreReviewController.requestReview()
    }
    
    /// Updates the textfield in the text size box and the text size of the application
    @objc func updateTextSizeSlider() {
        self.textSizeTextField.text = String(Int(self.textSizeSlider.value))
    }
    
    /// Updates the text size slider and the text size of the application
    @objc func updateTextSizeTextField() {
        guard self.textSizeTextField.text! != "" else { return }
        self.textSizeSlider.setValue(Float(self.textSizeTextField.text!)!, animated: true)
    }
    
    // MARK: SET UP MAIN VIEW
    
    /// Sets up the UI elements in the main view of the settings page
    func setupMainView() {
        
        // MARK: CURRENCY VIEW
        
        // Sets up the currency view
        self.currencyView.frame = CGRect (
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 80
        )
        self.mainView.addSubview(self.currencyView)
        
        // Sets up the currency label
        let currencyLabel: UILabel = UILabel()
        currencyLabel.frame.size = CGSize(width: 100, height: 20)
        currencyLabel.frame.origin = CGPoint(x: 20, y: currencyLabel.frame.origin.y)
        currencyLabel.text = "CURRENCY"
        currencyLabel.textColor = .lightGray
        currencyLabel.font = UIFont(name: "", size: 20)
        self.currencyView.addSubview(currencyLabel)
        
        // Sets up the rounded rectangle view for the currency view
        let currencyBoxView: UIView = UIView()
        currencyBoxView.frame.size = CGSize(width: UIScreen.main.bounds.width-30, height: 45)
        currencyBoxView.frame.origin = CGPoint(x: UIScreen.main.bounds.width/2-currencyBoxView.frame.width/2, y: currencyBoxView.frame.origin.y+25)
        currencyBoxView.backgroundColor = UIColor.darkBlue2
        currencyBoxView.layer.cornerRadius = 15
        self.currencyView.addSubview(currencyBoxView)
        
        // Sets up the currency button
        let currencyButton: UIButton = UIButton()
        currencyButton.showsMenuAsPrimaryAction = true
        currencyButton.frame.size = CGSize(width: currencyBoxView.frame.width, height: currencyBoxView.frame.height)
        
        // Sets up the currency button menu
        let currencyClose: UIAction = UIAction(title: "Close", attributes: .destructive) { _ in }
        let currencyItems = UIMenu(title: "More", options: .displayInline, children: [
            UIAction(title: "Item 1") { _ in },
            UIAction(title: "Item 2") { _ in }
        ])
        currencyButton.menu = UIMenu(title: "", children: [currencyItems, currencyClose])
        currencyBoxView.addSubview(currencyButton)
        
        // Sets up the arrow at the end of the currency button
        let currencyArrowView: UIImageView = UIImageView(image: UIImage(named: "thin_side_arrow"))
        currencyArrowView.frame.size = CGSize(width: 20, height: 20)
        currencyArrowView.center = CGPoint(x: currencyBoxView.frame.width-20, y: currencyBoxView.frame.height/2)
        currencyArrowView.image = currencyArrowView.image?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        currencyArrowView.image = UIGraphicsImageRenderer(size: currencyArrowView.bounds.size).image { (context) in
            currencyArrowView.image!.draw(in: CGRect(origin: .zero, size: currencyArrowView.bounds.size))
        }
        currencyButton.addSubview(currencyArrowView)
        
        // MARK: LANGUAGE VIEW
        
        // Sets up the language view
        self.languageView.frame = CGRect (
            x: 0,
            y: 90,
            width: UIScreen.main.bounds.width,
            height: 80
        )
        self.mainView.addSubview(self.languageView)
        
        // Sets up the language label
        let languageLabel: UILabel = UILabel()
        languageLabel.frame.size = CGSize(width: 100, height: 20)
        languageLabel.frame.origin = CGPoint(x: 20, y: languageLabel.frame.origin.y)
        languageLabel.text = "LANGUAGE"
        languageLabel.textColor = .lightGray
        languageLabel.font = UIFont(name: "", size: 20)
        self.languageView.addSubview(languageLabel)
        
        // Sets up the rounded rectangle view for the language view
        let languageBoxView: UIView = UIView()
        languageBoxView.frame.size = CGSize(width: UIScreen.main.bounds.width-30, height: 45)
        languageBoxView.frame.origin = CGPoint(x: UIScreen.main.bounds.width/2-languageBoxView.frame.width/2, y: languageBoxView.frame.origin.y+25)
        languageBoxView.backgroundColor = UIColor.darkBlue2
        languageBoxView.layer.cornerRadius = 15
        self.languageView.addSubview(languageBoxView)
        
        // Sets up the language button
        let languageButton: UIButton = UIButton()
        languageButton.showsMenuAsPrimaryAction = true
        languageButton.frame.size = CGSize(width: languageBoxView.frame.width, height: languageBoxView.frame.height)
        
        // Sets up the language button menu
        let languageClose: UIAction = UIAction(title: "Close", attributes: .destructive) { _ in }
        var languageActions: [UIAction] = []
        for i in self.languages {
            languageActions.append(UIAction(title: i) { _ in
                self.selectedLanguage = i
                UserDefaults.standard.set(self.languagesDict[self.selectedLanguage], forKey: "i18n_language")
                languageButton.setTitle(i.localized, for: .normal)
            })
        }
        let languageItems = UIMenu(title: "More", options: .displayInline, children: languageActions)
        languageButton.menu = UIMenu(title: "", children: [languageItems, languageClose])
        languageButton.setTitle(self.selectedLanguage.localized, for: .normal)
        languageBoxView.addSubview(languageButton)
        
        // Sets up the arrow at the end of the language button
        let languageArrowView: UIImageView = UIImageView(image: UIImage(named: "thin_side_arrow"))
        languageArrowView.frame.size = CGSize(width: 20, height: 20)
        languageArrowView.center = CGPoint(x: languageBoxView.frame.width-20, y: languageBoxView.frame.height/2)
        languageArrowView.image = languageArrowView.image?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        languageArrowView.image = UIGraphicsImageRenderer(size: languageArrowView.bounds.size).image { (context) in
            languageArrowView.image!.draw(in: CGRect(origin: .zero, size: languageArrowView.bounds.size))
        }
        languageButton.addSubview(languageArrowView)
        
        // MARK: TEXT SIZE VIEW
        
        // Sets up the text size view
        self.textSizeView.frame = CGRect (
            x: 0,
            y: 180,
            width: UIScreen.main.bounds.width,
            height: 80
        )
        self.mainView.addSubview(self.textSizeView)
        
        // Sets up the text size label
        let textSizeLabel: UILabel = UILabel()
        textSizeLabel.frame.size = CGSize(width: 100, height: 20)
        textSizeLabel.frame.origin = CGPoint(x: 20, y: textSizeLabel.frame.origin.y)
        textSizeLabel.text = "TEXT SIZE"
        textSizeLabel.textColor = .lightGray
        textSizeLabel.font = UIFont(name: "", size: 20)
        self.textSizeView.addSubview(textSizeLabel)
        
        // Sets up the rounded rectangle view for the text size view
        let textSizeBoxView: UIView = UIView()
        textSizeBoxView.frame.size = CGSize(width: UIScreen.main.bounds.width-30, height: 45)
        textSizeBoxView.frame.origin = CGPoint(x: UIScreen.main.bounds.width/2-textSizeBoxView.frame.width/2, y: textSizeBoxView.frame.origin.y+25)
        textSizeBoxView.backgroundColor = UIColor.darkBlue2
        textSizeBoxView.layer.cornerRadius = 15
        self.textSizeView.addSubview(textSizeBoxView)
        
        // Sets up the text size slider
        self.textSizeSlider.frame.size = CGSize(width: textSizeBoxView.frame.width*0.6, height: textSizeBoxView.frame.height)
        self.textSizeSlider.frame.origin = CGPoint(x: 15, y: textSizeBoxView.frame.height/2 - self.textSizeSlider.frame.height/2)
        self.textSizeSlider.addTarget(self, action: #selector(self.updateTextSizeSlider), for: .touchUpInside)
        self.textSizeSlider.tintColor = UIColor.lightOrange1
        self.textSizeSlider.isContinuous = true
        self.textSizeSlider.minimumValue = 20
        self.textSizeSlider.maximumValue = 150
        self.textSizeSlider.setValue(100, animated: true)
        textSizeBoxView.addSubview(self.textSizeSlider)
        
        // Sets up the text field alternative to the text size slider
        self.textSizeTextField.frame.size = CGSize(width: textSizeBoxView.frame.width*0.2, height: textSizeBoxView.frame.height-10)
        self.textSizeTextField.frame.origin = CGPoint(x: textSizeSlider.frame.width+40, y: textSizeBoxView.frame.height/2 - self.textSizeTextField.frame.height/2)
        self.textSizeTextField.addTarget(self, action: #selector(self.updateTextSizeTextField), for: UIControl.Event.editingChanged)
        self.textSizeTextField.textAlignment = .right
        self.textSizeTextField.text = "100"
        self.textSizeTextField.layer.cornerRadius = 10
        self.textSizeTextField.layer.masksToBounds = true
        self.textSizeTextField.layer.borderWidth = 0.3
        self.textSizeTextField.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.textSizeTextField.textColor = UIColor.lightOrange1
        self.textSizeTextField.addDoneButtonToKeyboard()
        textSizeBoxView.addSubview(self.textSizeTextField)
        
        // Sets up the percentage sign at the end of the textfield
        let percentageSign: UILabel = UILabel()
        percentageSign.frame.size = CGSize(width: 20, height: textSizeBoxView.frame.height)
        percentageSign.frame.origin = CGPoint(x: self.textSizeSlider.frame.width+self.textSizeTextField.frame.width+45, y: textSizeBoxView.frame.height/2 - percentageSign.frame.height/2)
        percentageSign.text = "%"
        percentageSign.textColor = .lightGray
        textSizeBoxView.addSubview(percentageSign)
        
        // MARK: REVIEW VIEW
        
        // Sets up the review view
        self.reviewView.frame = CGRect (
            x: 0,
            y: 300,
            width: UIScreen.main.bounds.width,
            height: 45
        )
        self.mainView.addSubview(self.reviewView)
        
        // Sets up the rounded rectangle view for the review view
        let reviewBoxView: UIView = UIView()
        reviewBoxView.frame.size = CGSize(width: UIScreen.main.bounds.width-30, height: 45)
        reviewBoxView.frame.origin = CGPoint(x: UIScreen.main.bounds.width/2-reviewBoxView.frame.width/2, y: reviewBoxView.frame.origin.y)
        reviewBoxView.backgroundColor = UIColor.darkBlue2
        reviewBoxView.layer.cornerRadius = 15
        self.reviewView.addSubview(reviewBoxView)
        
        // Sets up the review button
        let reviewButton: UIButton = UIButton()
        reviewButton.showsMenuAsPrimaryAction = true
        reviewButton.frame.size = CGSize(width: reviewBoxView.frame.width, height: reviewBoxView.frame.height)
        reviewButton.setTitle("    Write us a review!", for: .normal)
        reviewButton.contentHorizontalAlignment = .left
        reviewButton.addTarget(self, action: #selector(openReview), for: .touchUpInside)
        reviewBoxView.addSubview(reviewButton)
        
        // Sets up the arrow at the end of the review button
        let reviewArrowView: UIImageView = UIImageView(image: UIImage(named: "thin_side_arrow"))
        reviewArrowView.frame.size = CGSize(width: 20, height: 20)
        reviewArrowView.center = CGPoint(x: reviewBoxView.frame.width-20, y: reviewBoxView.frame.height/2)
        reviewArrowView.image = reviewArrowView.image?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        reviewArrowView.image = UIGraphicsImageRenderer(size: reviewArrowView.bounds.size).image { (context) in
            reviewArrowView.image!.draw(in: CGRect(origin: .zero, size: reviewArrowView.bounds.size))
        }
        reviewButton.addSubview(reviewArrowView)
    }
}
