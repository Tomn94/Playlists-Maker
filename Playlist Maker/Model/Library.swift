//
//  Library.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import Foundation
import MediaPlayer

class Library {
    
    var currentSong: Song?
    
    
    // MARK: Status
    
    typealias LibraryStatus = MPMediaLibraryAuthorizationStatus
    
    var status: LibraryStatus {
        return MPMediaLibrary.authorizationStatus()
    }
    
    func askAuthorization(handler: @escaping (LibraryStatus) -> Void) {
        MPMediaLibrary.requestAuthorization(handler)
    }
    
    
    // MARK: Content
    
    var songs: [Song] {
        return []
    }
    
    var artists: [Artist] {
        return []
    }
    
}


class Song {
    
}

class Artist {
    
    var albums: [Album] {
        return []
    }
    
}

class Album {
    
}
