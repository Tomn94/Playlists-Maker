//
//  SettingsVC.swift
//  Playlist Maker
//
//  Created by Tomn on 31/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {
    
    /// Whether library is currently loading playlists.
    /// Disables table view actions
    var isLoadingLibrary = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = nil  // remove Ads button
        
        /* Load playlists */
        // Indicate with UI
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)
        activity.startAnimating()
        
        // Disable table view actions
        self.isLoadingLibrary = true
        
        DataStore.shared.library.loadPlaylists {
            // Finished loading
            self.isLoadingLibrary = false
            DispatchQueue.main.async {
                activity.stopAnimating()
            }
        }
    }

    /// Ads button tapped
    @IBAction func showIAP() {
        
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    /// Begin process
    func beginSorting() {
        
        guard !isLoadingLibrary else {
            return
        }
    }
    
    
    // MARK: - Navigation
    
    /// Disable table view actions when loading library
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        return !isLoadingLibrary
    }

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
        
        guard !isLoadingLibrary else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        switch indexPath.section {
        // Song Selection
        case 0:
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 4 {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
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
