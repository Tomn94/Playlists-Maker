//
//  Player.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import Foundation

class Player {
    
    /// Is the focused music currently being listened
    var isPlaying: Bool = false
    
    /// Time elapsed for the currently playing song
    var playbackTime: TimeInterval?
    
    
    /// Play the selected music
    func play() {
        
    }
    
    /// Pause the current music
    func pause() {
        
    }
    
    /// Inverts listening state
    func playPause() {
        
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
}
