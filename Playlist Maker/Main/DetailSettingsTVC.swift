//
//  DetailSettingsTVC.swift
//  Playlist Maker
//
//  Created by Tomn on 31/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// List of playlists that can be selected
class DetailSettingsTVC: UITableViewController {
    
    /// Table view model
    var playlists = DataStore.shared.library.playlists
    
    /// Subset of `playlists` which are selected
    var selectedPlaylists = [Playlist]()
    
    /// Mode being customized here
    var songSelectionMode: SongSelectionMode = .inNoPlaylist
    
    
    @IBAction func newPlaylist() {
        
        let alert = UIAlertController(title: "Name your new playlist",
                                      message: nil,
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "My New Playlist"
        })
        
        let confirmAction = UIAlertAction(title: "Create",
                                          style: .default, handler: { [unowned self] _ in
            
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces)
            guard !(name?.isEmpty ?? true) else {
                /* Retry if empty name */
                self.newPlaylist()
                return
            }
            
            Library.createPlaylist(named: name!,
                                   completion:
                { [unowned self] playlist, error in
                    
                    DispatchQueue.main.async {
                        /* Apple Music error */
                        guard playlist != nil, error == nil else {
                            let alert = UIAlertController(title: "Unable to create playlist",
                                                          message: error?.localizedDescription,
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                            self.present(alert, animated: true)
                            return
                        }
                        
                        /* Reload data */
                        DataStore.shared.library.playlists.append(playlist!)
                        DataStore.shared.library.playlists.sort { playlist1, playlist2 in
                            playlist1.name.localizedCaseInsensitiveCompare(playlist2.name) == .orderedAscending
                        }
                        self.playlists = DataStore.shared.library.playlists
                        
                        /* Reload UI */
                        if let indexSort = self.playlists.index(where: {
                            $0.id == playlist!.id
                        }) {
                            let indexPath = IndexPath(row: indexSort, section: 0)
                            self.tableView.insertRows(at: [indexPath], with: .automatic)
                            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        }
                    }
            })
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(confirmAction)
        alert.preferredAction = confirmAction
        
        present(alert, animated: true)
    }
    
    @IBAction func selectAll() {
        
        selectedPlaylists = playlists
        updateSelectionStorage()
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    @IBAction func deselectAll() {
        
        selectedPlaylists = []
        updateSelectionStorage()
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    func updateSelectionStorage() {
        
        switch songSelectionMode {
        case .notInPlaylists:
            DataStore.shared.library.selectionNotInPlaylists = selectedPlaylists
            
        case .inPlaylists:
            DataStore.shared.library.selectionInPlaylists    = selectedPlaylists
            
        case .destination:
            DataStore.shared.library.destinationPlaylists    = selectedPlaylists
            
        case .addedAfterDate, .inNoPlaylist, .inNoDestination, .allSongs:
            break
        }
    }

}

// MARK: - Table View Data Source
extension DetailSettingsTVC {

    /// Determines the number of rows in the list
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - section: One-and-only section
    /// - Returns: Number of playlists
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return playlists.count
    }
    
    /// Sets header title according to song selection mode
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - section: One-and-only section
    /// - Returns: Name of selection mode
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        
        switch songSelectionMode {
        case .notInPlaylists:
            return "Sort songs not contained in…"
        case .inPlaylists:
            return "Sort songs contained in…"
            
        case .destination:
            return "Allow songs to be added to…"
            
        case .addedAfterDate,
             .inNoPlaylist,
             .inNoDestination,
             .allSongs:
            return nil
        }
    }

    /// Populates table view with custom cell
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the cell to fill with contents
    /// - Returns: Cell displaying a playlist
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsDetailCell",
                                                 for: indexPath)
        
        let playlist = playlists[indexPath.row]
        cell.textLabel?.text  = playlist.name
        cell.imageView?.image = playlist.artwork
        
        // Selection state
        let shouldBeSelected = selectedPlaylists.contains { $0.id == playlist.id }
        cell.accessoryType   = shouldBeSelected ? .checkmark : .none

        return cell
    }

}

// MARK: - Table View Delegate
extension DetailSettingsTVC {
    
    /// Called when the users taps a cell
    ///
    /// - Parameters:
    ///   - tableView: This table view
    ///   - indexPath: Position of the selection
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        let playlist = playlists[indexPath.row]
        let selectionIndex = selectedPlaylists.index { $0.id == playlist.id }
        
        // Change model
        if selectionIndex == nil {
            selectedPlaylists.append(playlist)
        } else {
            selectedPlaylists.remove(at: selectionIndex!)
        }
        
        // Store changes
        updateSelectionStorage()
        
        // Apply inverted selection state
        tableView.cellForRow(at: indexPath)?.accessoryType = selectionIndex == nil ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
