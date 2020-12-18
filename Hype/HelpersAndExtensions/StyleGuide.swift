//
//  StyleGuide.swift
//  Hype
//
//  Created by Trevor Bursach on 10/12/20.
//

import UIKit

struct FontNames {
    static let latoBold = "Lato-Bold"
    static let latoLight = "Lato-Light"
    static let latoRegular = "Lato-Regular"
}

extension UIColor {
    static let borderHighlight = UIColor(named: "borderHighlight")!
    static let cardGray = UIColor(named: "cardGray")!
    static let greenAccent = UIColor(named: "greenAccent")!
    static let mainText = UIColor(named: "mainText")!
    static let purpleAccent = UIColor(named: "purpleAccent")!
    static let spaceBlack = UIColor(named: "spaceBlack")!
    static let spaceGray = UIColor(named: "spaceGray")!
    static let subtleText = UIColor(named: "subtleText")!
}

extension UIView {
    
    func addCornerRadius(radius: CGFloat = 4) {
        self.layer.cornerRadius = radius
    }
    
    func addAccentBorder(width: CGFloat = 3, color: UIColor = .borderHighlight) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func rotate(by radians: CGFloat = (-CGFloat.pi / 2)) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}
