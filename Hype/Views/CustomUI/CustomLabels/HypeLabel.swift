//
//  HypeLabel.swift
//  Hype
//
//  Created by Trevor Bursach on 10/12/20.
//

import UIKit

//MARK: - Regular Hype Label
class HypeLabel: UILabel {
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateFontTo(font: FontNames.latoRegular)
        self.textColor = .mainText
    }
    
    //MARK: - Class Functions
    
    func updateFontTo(font: String) {
        let size = self.font.pointSize
        self.font = UIFont(name: font, size: size)
    }
    
} // END OF CLASS

//MARK: - Light Hype Label
class HypeLabelLight: HypeLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateFontTo(font: FontNames.latoLight)
        self.textColor = .subtleText
    }
} // END OF CLASS

//MARK: - Bold Hype Label
class HypeLabelBold: HypeLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateFontTo(font: FontNames.latoBold)
    }
}
