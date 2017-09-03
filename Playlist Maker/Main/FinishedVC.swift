//
//  FinishedVC.swift
//  Playlist Maker
//
//  Created by Tomn on 03/09/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

class FinishedVC: UIViewController {
    
    /// Resulting number of sorted songs 
    var count: Int = 0
    
    /// Where the number of sorted songs is displayed
    @IBOutlet weak var detailLabel: UILabel!
    
    /// Presenting view controller
    var parentVC: SettingsTVC?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if count == 1 {
            detailLabel.text = "\(count) song sorted\nCome back regularly!"
        } else {
            detailLabel?.text = "\(count) songs sorted\nCome back regularly!"
        }
    }
    
    @IBAction func supportApp() {
        
        dismiss(animated: true) {
            if let settingsTVC = self.parentVC {
                settingsTVC.tipMachine.showInfo(from: settingsTVC)
            }
        }
    }
    
}
