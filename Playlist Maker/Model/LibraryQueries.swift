//
//  LibraryQueries.swift
//  Playlist Maker
//
//  Created by Tomn on 01/09/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import MediaPlayer

class LibraryQueries {
    
    class var allSongs: Set<MPMediaItem> {
        return Set(MPMediaQuery.songs().items ?? [])
    }
    
    class var inSelectedPlaylists: Set<MPMediaItem> {
        
        let playlists = DataStore.shared.library.selectionInPlaylists
        return LibraryQueries.inPlaylists(playlists)
    }
    
    class var notInSelectedPlaylists: Set<MPMediaItem> {
        
        let allSongs    = LibraryQueries.allSongs
        let inPlaylists = LibraryQueries.inSelectedPlaylists
        
        return allSongs.subtracting(inPlaylists)
    }
    
    class var notInDestinationPlaylists: Set<MPMediaItem> {
        
        let allSongs   = LibraryQueries.allSongs
        let playlists  = DataStore.shared.library.destinationPlaylists
        let allInDests = LibraryQueries.inPlaylists(playlists)
        
        return allSongs.subtracting(allInDests)
    }
    
    class var inNoPlaylists: Set<MPMediaItem> {
    
        let allSongs       = LibraryQueries.allSongs
        let playlists      = DataStore.shared.library.playlists
        let allInPlaylists = LibraryQueries.inPlaylists(playlists)
        
        return allSongs.subtracting(allInPlaylists)
    }
    
    
    private class func inPlaylists(_ playlists: [Playlist]) -> Set<MPMediaItem> {
        
        var librarySongs = Set<MPMediaItem>()
        
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
    
}
