//
//  SettingsVC.swift
//  Playlist Maker
//
//  Created by Tomn on 31/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = nil
    }
    
    @IBAction func showIAP() {
        
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func beginSorting() {
        
    }
    
    
    // MARK: - Navigation

    // Preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}


// MARK: - Table View Delegate
extension SettingsTVC {
    
    /// Called when a row is tapped by user
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the selected row
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        // Song Selection
        case 0:
            break
            
        // Destination Playlists
        case 1:
            break
        
        // Fire Button
        case 2:
            beginSorting()
            
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
