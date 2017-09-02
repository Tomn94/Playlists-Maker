//
//  Utils.swift
//  Playlist Maker
//
//  Created by Tomn on 30/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import Foundation

/// UserDefaults common keys
enum UserDefaultsKey {
    
    /// Boolean whether songs should play right when a song is displayed
    static let autoplaySongs = "autoplaySongs"
    
    /// Song Selection mode
    static let songSelectionMode = "songSelectionMode"
    
    /// Array of selected playlists IDs for `selectionNotInPlaylists`
    static let selectionNotInPlaylists    = "selectionNotInPlaylists"
    
    /// Array of selected playlists IDs for `selectionInPlaylists`
    static let selectionInPlaylists       = "selectionInPlaylists"
    
    /// Array of selected playlists IDs for `destinationPlaylists`
    static let destinationPlaylists       = "destinationPlaylists"
    
    /// Date Selection mode
    static let dateSelectionMode      = "dateSelectionMode"
    
    /// Date after which songs are accepted, for `dateSelectionModeStart`
    static let dateSelectionModeStart = "dateSelectionModeStart"
    
    /// Date before which songs are accepted, for `dateSelectionModeEnd`
    static let dateSelectionModeEnd   = "dateSelectionModeEnd"
    
}

extension Notification.Name {
    
    /// Called when user granted access to music library
    static let libraryAccessGranted = Notification.Name("libraryAccessGranted")
    
}

extension String {
    
    /// Indicates whether the string contains any inputted substring
    ///
    /// - Parameter array: Substrings to locate in this larger string
    /// - Returns: True if one or more substrings are found
    func containsAny(_ array: [String]) -> Bool {
        
        /* Return true as soon as we have our 1st match */
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        
        return false
    }
    
}
