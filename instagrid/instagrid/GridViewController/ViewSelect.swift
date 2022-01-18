//
//  File.swift
//  instagrid
//
//  Created by Florian Fourcade on 05/01/2022.
//

import UIKit

class ViewSelect: UIStackView {
    
    //creation of the 3 outlets for choice the view
    @IBOutlet private var firstLayoutButton : UIButton!
    @IBOutlet private var secondLayoutButton : UIButton!
    @IBOutlet private var thirdLayoutButton : UIButton!
    
    
    private func selectedLayout(_ style : Layout) {
        switch style{
        case .layout1:
            firstLayoutButton.isSelected = true
            secondLayoutButton.isSelected = false
            thirdLayoutButton.isSelected = false
            
            // when the button is selected,change the image of the button
            firstLayoutButton.setImage(UIImage(named : "Selected"), for: .selected)
        case .layout2:
            firstLayoutButton.isSelected = false
            secondLayoutButton.isSelected = true
            thirdLayoutButton.isSelected = false
            
            // when the button is selected,change the image of the button
            secondLayoutButton.setImage(UIImage(named : "Selected"), for: .selected)
        case .layout3:
            firstLayoutButton.isSelected = false
            secondLayoutButton.isSelected = false
            thirdLayoutButton.isSelected = true
            
            // when the button is selected,change the image of the button
            thirdLayoutButton.setImage(UIImage(named : "Selected"), for: .selected)
        }
    }
}
