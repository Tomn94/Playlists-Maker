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
    
    
    /// Available song selection settings
    enum SongSelection: Int {
        /// Songs in no playlist at all
        case inNoPlaylist
        /// Songs not in destination playlists
        case inNoDestination
        /// Songs not in selected playlists
        case notInPlaylists
        /// Songs in selected playlists
        case inPlaylists
        /// Whole library
        case allSongs
    }
    
    /// Current setting for song selection
    var songSelectionMode: SongSelection = .inNoPlaylist
    
    /// Rows in Song Selection Section (0) having a disclosure indicator
    let detailRows = [2, 3]

    
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


// MARK: - Table View Data Source
extension SettingsTVC {
    
    /// Extra customization for cells with detail accessory:
    /// Sets check mark color
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the eventual row to customize
    /// - Returns: Cell with customized text color, eventually
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if detailRows.contains(indexPath.row) {
            cell.detailTextLabel?.textColor = tableView.tintColor
        }
        
        return cell
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
            
            // Deselect all rows
            for row in 0..<tableView.numberOfRows(inSection: 0) {
                let iP = IndexPath(row: row, section: 0)
                if detailRows.contains(row) {
                    tableView.cellForRow(at: iP)?.detailTextLabel?.text = nil
                } else {
                    tableView.cellForRow(at: iP)?.accessoryType = .none
                }
            }
            
            // Select requested row
            if detailRows.contains(indexPath.row) {
                tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "✓"
                // Don't deselect, it'll be done when detail view is dismissed
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
            // Set mode
            songSelectionMode = SongSelection(rawValue: indexPath.row) ?? .inNoPlaylist
            
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
