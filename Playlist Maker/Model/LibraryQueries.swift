//
//  LibraryQueries.swift
//  Playlist Maker
//
//  Created by Tomn on 01/09/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import MediaPlayer

/// List of already-available media requests filtering songs in Library.
class LibraryQueries {
    
    /// Returns all songs in library
    class var allSongs: Set<MPMediaItem> {
        return Set(MPMediaQuery.songs().items ?? [])
    }
    
    /// Returns all songs contained in `DataStore.shared.library.selectionInPlaylists`
    class var inSelectedPlaylists: Set<MPMediaItem> {
        
        let playlists = DataStore.shared.library.selectionInPlaylists
        return LibraryQueries.inPlaylists(playlists)
    }
    
    /// Returns all songs not contained in `DataStore.shared.library.selectionInPlaylists`.
    class var notInSelectedPlaylists: Set<MPMediaItem> {
        
        let selectionNotInPlaylists = DataStore.shared.library.selectionNotInPlaylists
        return LibraryQueries.notInPlaylists(selectionNotInPlaylists)
    }
    
    class var notInDestinationPlaylists: Set<MPMediaItem> {
        
        let destinationPlaylists = DataStore.shared.library.destinationPlaylists
        return LibraryQueries.notInPlaylists(destinationPlaylists)
    }
    
    class var inNoPlaylists: Set<MPMediaItem> {
    
        let allPlaylists = DataStore.shared.library.playlists
        return LibraryQueries.notInPlaylists(allPlaylists)
    }
    
    class var addedToLibraryAtDates: Set<MPMediaItem> {
        
        /* Set interval */
        var startDate    = DataStore.shared.dateSelectionModeStart
        var   endDate    = DataStore.shared.dateSelectionModeEnd
        
        // Apply mode
        let rawMode = UserDefaults.standard.integer(forKey: UserDefaultsKey.dateSelectionMode)
        let dateSelectionMode = DateSelectionMode(rawValue: rawMode) ?? .after
        if dateSelectionMode == .before {
            startDate = Date.distantPast
        }
        if dateSelectionMode == .after {
            endDate   = Date.distantFuture
        }
        
        var librarySongs = Set<MPMediaItem>()
        
        let allSongs = MPMediaQuery.songs().items ?? []
        for song in allSongs {
            let songDate = song.dateAdded
            
            if songDate > startDate &&
               songDate <   endDate {
                // Add songs
                librarySongs.insert(song)
            }
        }
        
        return librarySongs
    }
    
    
    // MARK: - Common
    
    /// Returns all songs in library that are contained in the given playlists
    ///
    /// - Parameter playlists: Playlists whose songs will be included
    /// - Returns: Unique set of songs listed in those playlists
    private class func inPlaylists(_ playlists: [Playlist]) -> Set<MPMediaItem> {
        
        var librarySongs = Set<MPMediaItem>()
        
        /* Go through each playlist
           NB: There could be a filter
           */
        for playlist in playlists {
            
            let query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(value: playlist.id,
                                                     forProperty: MPMediaPlaylistPropertyPersistentID)
            query.addFilterPredicate(predicate)
            
            let results = query.items ?? []
            for result in results {
                librarySongs.insert(result)
            }
        }
        
        return librarySongs
    }
    
    /// Returns all songs in library that are not contained in any given playlist.
    /// Inverts `inPlaylists(_:)`
    ///
    /// - Parameter playlists: Playlists whose songs will be excluded
    /// - Returns: Difference between Library songs and songs in playlists
    private class func notInPlaylists(_ playlists: [Playlist]) -> Set<MPMediaItem> {
        
        let allSongs       = LibraryQueries.allSongs
        let allInPlaylists = LibraryQueries.inPlaylists(playlists)
        
        return allSongs.subtracting(allInPlaylists)
    }
    
}
