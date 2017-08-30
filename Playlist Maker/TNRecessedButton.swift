//
//  RecessedButton v1
//  TNRecessedButton.swift
//
//  Created by Thomas NAUDET @tomn94 on 30/08/2017.
//  Copyright © 2017 Thomas NAUDET. Under MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

/**
    Usage example:
 
         let button = RecessedButton()
 
     More on:
         https://github.com/Tomn94/TNRecessedButton
 */

import UIKit

fileprivate extension Selector {
    
    /// Button tapped
    static let tapped = #selector(RecessedButton.stateChanged)
    
}


/// Button acting as a toggle switch.
/// Displays a rounded rect background when selected.
open class RecessedButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    private func initSetup() {
        
        /* Respond to touch */
        addTarget(self, action: .tapped, for: .touchUpInside)
        
        /* Actually no need to do anything else,
           iOS already adds a background for selected state… */
    }
    
    @objc fileprivate func stateChanged() {
        isSelected = !isSelected
    }
    
}


/// Bar button acting as a toggle switch.
/// Displays a rounded rect background when selected.
open class RecessedBarButton: UIBarButtonItem {
    
    open var button: RecessedButton?
    
    public convenience init(button: RecessedButton) {
        self.init(customView: button)
        self.button = button
    }
    
}
