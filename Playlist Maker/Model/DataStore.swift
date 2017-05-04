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
    var currrentIndex: Int?
    
    
    /// Music playback handler
    let player = Player()
    
    
    // MARK: Singleton
    
    private init() {}
    
    static let shared = DataStore()
    
}
