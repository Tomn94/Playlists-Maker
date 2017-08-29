//
//  SongPlayer.swift
//  Playlist Maker
//
//  Created by Tomn on 29/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import MediaPlayer

/// Class handling song playback
class SongPlayer {
    
    /// Wrapped iOS music player
    let musicPlayer = MPMusicPlayerController.applicationQueuePlayer()

    
    /// Prepare the player to play a list of songs
    ///
    /// - Parameter songs: Media Items from library
    func load(songs: [MPMediaItem]) {
        
        let collection = MPMediaItemCollection(items: songs)
        musicPlayer.setQueue(with: collection)
        musicPlayer.prepareToPlay()
    }
    
    /// Play current song
    func resume() {
        musicPlayer.play()
    }
    
    /// Pause current song
    func pause() {
        musicPlayer.pause()
    }
    
    /// Set next song as the new current song
    func next() {
        musicPlayer.skipToNextItem()
    }

}
