//
//  DataStore.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import Foundation

/// Holds data for the whole app
class DataStore {
    
    /// Music library
    let library = Library()
    
    /// Position of the song currently focused to be sorted
    var currentIndex: Int?
    
    var currentSong: Song? {
        if let index = currentIndex {
            return library.songs[index]
        }
        return nil
    }
    
    /// Setting whether songs should play right when a song is displayed (defaults to true)
    static var autoplaysSong: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultKeys.autoplaySongs)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.autoplaySongs)
        }
    }
    
    
    // MARK: Singleton
    
    private init() {
        
        UserDefaults.standard.register(defaults: [
            UserDefaultKeys.autoplaySongs : true
        ])
    }
    
    static let shared = DataStore()
    
}
