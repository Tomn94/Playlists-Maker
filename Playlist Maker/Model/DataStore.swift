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
    
    /// Number of times the user finished sorting their songs
    static var sortFinishedCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultsKey.sortFinishedCount)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.sortFinishedCount)
        }
    }
    
    /// Preference whether songs should play right when a song is displayed (defaults to true)
    static var autoplaysSong: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.autoplaySongs)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.autoplaySongs)
        }
    }
    
    /// Date after which songs are accepted in `SongSelectionMode.addedDate`
    var dateSelectionModeStart = UserDefaults.standard.object(forKey: UserDefaultsKey.dateSelectionModeStart) as? Date ?? Date() {
        didSet {
            UserDefaults.standard.set(dateSelectionModeStart,
                                      forKey: UserDefaultsKey.dateSelectionModeStart)
        }
    }
    
    /// Date before which songs are accepted in `SongSelectionMode.addedDate`
    var dateSelectionModeEnd   = UserDefaults.standard.object(forKey: UserDefaultsKey.dateSelectionModeEnd) as? Date ?? Date() {
        didSet {
            UserDefaults.standard.set(dateSelectionModeEnd,
                                      forKey: UserDefaultsKey.dateSelectionModeEnd)
        }
    }
    
    
    // MARK: Singleton
    
    private init() {
        
        UserDefaults.standard.register(defaults: [
            UserDefaultsKey.autoplaySongs : true
        ])
    }
    
    static let shared = DataStore()
    
}
