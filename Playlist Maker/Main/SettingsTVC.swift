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
        /// Used when setting destination playlists
        case destination
    }
    
    /// Current setting for song selection input
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* Refresh rows containing number of items */
        var indexPaths = [IndexPath]()
        for row in detailRows {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        indexPaths.append(IndexPath(row: 0, section: 1))
        tableView.reloadRows(at: indexPaths, with: .none)
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
        
        guard let detailVC = segue.destination as? DetailSettingsTVC else {
            return
        }
        
        // Set already selected items up
        if segue.identifier == "notInPlaylistsSegue" {
            detailVC.songSelectionMode = .notInPlaylists
            detailVC.selectedPlaylists = DataStore.shared.library.selectionNotInPlaylists
            
        } else if segue.identifier == "inPlaylistsSegue" {
            detailVC.songSelectionMode = .inPlaylists
            detailVC.selectedPlaylists = DataStore.shared.library.selectionInPlaylists
            
        } else if segue.identifier == "destinationPlaylistsSegue" {
            detailVC.songSelectionMode = .destination
            detailVC.selectedPlaylists = DataStore.shared.library.destinationPlaylists
        }
    }

}


// MARK: - Table View Data Source
extension SettingsTVC {
    
    /// Extra customization for cells with detail accessory:
    ///   - sets check mark color.
    ///   - Their number of items (playlists) is updated
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the eventual row to customize
    /// - Returns: Cell with customization, eventually
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if detailRows.contains(indexPath.row) {
            cell.detailTextLabel?.textColor = UIButton.appearance().tintColor
            
            if indexPath.section == 0 {
                if indexPath.row == 2 {         // Not In Playlists
                    let count = DataStore.shared.library.selectionNotInPlaylists.count
                    if count == 1 {
                        cell.textLabel?.text = "Songs not contained in 1 playlist…"
                    } else {
                        cell.textLabel?.text = "Songs not contained in \(count) playlists…"
                    }
                    
                } else if indexPath.row == 3 {  // In Playlists
                    let count = DataStore.shared.library.selectionInPlaylists.count
                    if count == 1 {
                        cell.textLabel?.text = "Songs contained in 1 playlist…"
                    } else {
                        cell.textLabel?.text = "Songs contained in \(count) playlists…"
                    }
                }
                
            }
        } else if indexPath.section == 1 {      // Destination playlists
            let count = DataStore.shared.library.destinationPlaylists.count
            if count == 1 {
                cell.textLabel?.text = "1 playlist selected"
            } else {
                cell.textLabel?.text = "\(count) playlists selected"
            }
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
