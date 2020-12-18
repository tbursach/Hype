//
//  HypeTextField.swift
//  Hype
//
//  Created by Trevor Bursach on 10/12/20.
//

import UIKit

class HypeTextField: UITextField {
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpViews()
    }
    
    //MARK: - Class Function
    
    func setUpViews() {
        
        setUpPlaceholderText()
        updateFontTo(name: FontNames.latoRegular)
        
        self.addCornerRadius(radius: 10)
        self.layer.masksToBounds = true
        self.addAccentBorder()
        self.textColor = .mainText
        self.backgroundColor = .spaceBlack
        
    }
    
    func setUpPlaceholderText() {
        let currentPlaceholder = self.placeholder
        self.attributedPlaceholder = NSAttributedString(string: currentPlaceholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.subtleText, NSAttributedString.Key.font : UIFont(name: FontNames.latoLight, size: 16)!])
    }
    
    func updateFontTo(name: String) {
        guard let size = self.font?.pointSize else { return }
        self.font = UIFont(name: name, size: size)
    }
    
} // END OF CLASS
