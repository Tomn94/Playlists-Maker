//
//  Library.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import Foundation
import MediaPlayer

/// Contains all information about the current songs to sort
class Library {
    
    
    // MARK: Status
    
    typealias LibraryStatus = MPMediaLibraryAuthorizationStatus
    
    /// Get current access status from iOS
    var status: LibraryStatus {
        return MPMediaLibrary.authorizationStatus()
    }
    
    
    /// Ask access to iOS music library
    ///
    /// - Parameter handler: Block called after the user choses whether to authorize the app
    func askAuthorization(handler: @escaping (LibraryStatus) -> Void) {
        
        MPMediaLibrary.requestAuthorization(handler)
    }
    
    
    // MARK: Songs
    
    /// List of the songs to sort
    var songs = [Song]()
    
    /// Fill library with songs to sort
    func load() {
        
        /* Get raw songs in library focus */
        let librarySongs = MPMediaQuery.songs().items ?? []
        var songs = [Song]()
        
        /* Create Song and add to list */
        for songItem in librarySongs {
            songs.append(Song(item: songItem))
        }
        
        self.songs = songs
    }
    
}


/// Represents a song in the user's library.
/// Wraps MPMediaItem
struct Song {
    
    /// Default maximum artwork size displayed
    static let artworkSize = CGSize(width: 100, height: 100)
    
    
    let title: String
    
    let artist: String//Artist
    
    let album: String?//Album
    
    let genre: String?//Genre
    
    let length: TimeInterval
    
    let artwork: UIImage?
    
    
    /// Init Song object with a media library query result
    ///
    /// - Parameter item: Library item to wrap in Song object
    init(item: MPMediaItem) {
        
        self.title   = item.title ?? "Unknown title"
        self.artist  = item.artist ?? "Unknown artist"
        self.album   = item.albumTitle ?? "Unknown album"
        self.genre   = item.genre
        self.length  = item.playbackDuration
        self.artwork = item.artwork?.image(at: Song.artworkSize)
    }
    
}

struct Artist {
    
    var albums: [Album] {
        return []
    }
    
}

struct Album {
    
}

enum Genre: String {
    case all
}
