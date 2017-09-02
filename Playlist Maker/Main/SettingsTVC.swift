//
//  SettingsVC.swift
//  Playlist Maker
//
//  Created by Tomn on 31/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    
    /// Called when library access status changed
    static let reloadPlaylists = #selector(SettingsTVC.loadPlaylists)
    
}


class SettingsTVC: UITableViewController {
    
    /// Whether library is currently loading playlists.
    /// Disables table view actions
    var isLoadingLibrary = false
    
    /// Spinner displayed when loading playlists
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    /// Current preference for song selection input
    var songSelectionMode = SongSelectionMode(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKey.songSelectionMode)) ?? .inNoPlaylist {
        didSet {
            UserDefaults.standard.set(songSelectionMode.rawValue,
                                      forKey: UserDefaultsKey.songSelectionMode)
        }
    }
    
    /// Rows in Song Selection Section (0) having a disclosure indicator
    let detailRows = [0, 3, 4]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Remove Ads button */
        navigationItem.leftBarButtonItem = nil
        
        /* Set up loading playlists */
        NotificationCenter.default.addObserver(self, selector: .reloadPlaylists,
                                               name: .libraryAccessGranted, object: nil)
        loadPlaylists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadDetailRows()
    }

    /// Ads button tapped
    @IBAction func showIAP() {
        
        let alert = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    /// Set up main content
    func loadPlaylists() {
        
        let info = UIBarButtonItem(title: "Loading playlists…", style: .plain,
                                   target: nil, action: nil)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: activityIndicator),
                                                   info]
        
        activityIndicator.startAnimating()
        // Remove title for this in compact width
        let previousTitle = navigationItem.title
        if traitCollection.horizontalSizeClass == .compact {
            navigationItem.title = nil
        }
        
        // Disable table view actions
        self.isLoadingLibrary = true
        tableView.allowsSelection = false
        
        DataStore.shared.library.loadPlaylists {
            // Finished loading
            self.isLoadingLibrary = false
            DispatchQueue.main.async {
                let reloadItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                 target: self, action: .reloadPlaylists)
                self.activityIndicator.stopAnimating()
                self.tableView.allowsSelection = true
                self.navigationItem.setRightBarButtonItems([reloadItem], animated: true)
                self.navigationItem.title = previousTitle
                self.reloadDetailRows()
            }
        }
    }
    
    /// Does some checks before engaging sort process.
    /// Then starts generating queue of songs to be sorted.
    func beginSorting() {
        
        guard !isLoadingLibrary else {
            return
        }
        let buttonIndexPath = IndexPath(row: 0, section: 2)
        
        /* No playlist selected in specific playlists mode */
        guard (songSelectionMode != .notInPlaylists ||
               !DataStore.shared.library.selectionNotInPlaylists.isEmpty) &&
              (songSelectionMode != .inPlaylists    ||
               !DataStore.shared.library.selectionInPlaylists.isEmpty) else {
                
                let part  = songSelectionMode == .notInPlaylists ? "don't " : ""
                let alert = UIAlertController(title: "No Playlists Selected",
                                              message: "You chose to sort songs that \(part)belong to specific playlists.\nThen select some playlists to begin.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                tableView.deselectRow(at: buttonIndexPath, animated: true)
                return
        }
        
        /* No destination playlists selected */
        guard !DataStore.shared.library.destinationPlaylists.isEmpty else {
            
            let alert = UIAlertController(title: "No destination playlists selected",
                                          message: "In order to sort songs in playlists, you need to select some!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            tableView.deselectRow(at: buttonIndexPath, animated: true)
            return
        }
        
        /* Generate song list */
        isLoadingLibrary = true
        
        let alert = UIAlertController(title: "Loading songs…",
                                      message: "This could take a few minutes depending on your selection",
                                      preferredStyle: .alert)
        present(alert, animated: true)
        
        DataStore.shared.library.loadSongs(using: songSelectionMode) {
            alert.dismiss(animated: true) {
                
                self.isLoadingLibrary = false
                
                /* No song found in selection */
                guard !DataStore.shared.library.songs.isEmpty else {
                    
                    let alert = UIAlertController(title: "No Songs Found",
                                                  message: "No songs to be sorted were found according to your selection.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                    self.tableView.deselectRow(at: buttonIndexPath, animated: true)
                    return
                }
                
                /* Present Song Organizer and let user begin sorting */
                let storyboard = UIStoryboard(name: "SongOrganizer", bundle: nil)
                let songOrganizer = storyboard.instantiateInitialViewController()
                self.present(songOrganizer!, animated: true)
            }
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
    
    func reloadDetailRows() {
        
        /* Refresh rows containing number of items */
        var indexPaths = [IndexPath]()
        for row in detailRows {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        indexPaths.append(IndexPath(row: 0, section: 1))
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
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
        
        if indexPath.section == 0 {
            
            let selected = indexPath.row == songSelectionMode.rowIndex()
            
            if detailRows.contains(indexPath.row) {
                
                cell.detailTextLabel?.text = selected ? "✓" : nil
                cell.detailTextLabel?.textColor = UIButton.appearance().tintColor
            
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
                
            } else {
                cell.accessoryType = selected ? .checkmark : .none
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
            if let newMode = SongSelectionMode.mode(for: indexPath.row) {
                songSelectionMode = newMode
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
