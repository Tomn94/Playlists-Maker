//
//  SongPlayer.swift
//  Playlist Maker
//
//  Created by Tomn on 29/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import MediaPlayer

extension Selector {
    
    /// Player successfully changed between play and pause
    static let playbackStatusChanged = #selector(SongPlayer.playbackStatusChanged)
    
}


/// Class handling song playback
class SongPlayer {
    
    /// Wrapped iOS music player
    private let musicPlayer = MPMusicPlayerController.applicationQueuePlayer()
    
    
    /// Delegate receiving playback events
    weak var delegate: SongPlayerDelegate? {
        didSet {
            
            guard delegate != nil else {
                // Unsubscribe from playback status notifications if no delegate
                musicPlayer.endGeneratingPlaybackNotifications()
                NotificationCenter.default.removeObserver(self)
                return
            }
            
            // Subscribe to playback status notifications to keep delegate updated
            musicPlayer.beginGeneratingPlaybackNotifications()
            NotificationCenter.default.addObserver(self, selector: .playbackStatusChanged,
                                                   name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                                   object: nil)
        }
    }
    
    
    /// Is a song currently playing
    var isPlaying: Bool {
        return musicPlayer.playbackState == .playing
    }

    
    /// Prepare the player to play a list of songs
    ///
    /// - Parameter songs: Media Items from library
    func load(songs: [Song]) {
        
        musicPlayer.pause()
        musicPlayer.currentPlaybackTime = 0
        
        let songItems = songs.map { song in
            song.item
        }
        let collection = MPMediaItemCollection(items: songItems)
        musicPlayer.setQueue(with: collection)
        
        playbackStatusChanged()
    }
    
    /// Play or pause current song depending on player state
    func playPause() {
        
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    /// Play current song
    func resume() {
        
        musicPlayer.play()
    }
    
    /// Pause current song
    func pause() {
        
        musicPlayer.pause()
    }
    
    /// Change the elapsed time of the current track.
    ///
    /// - Parameter time: Time to play at (now or next time Play is invoked)
    func seek(to time: TimeInterval) {
        musicPlayer.currentPlaybackTime = time
    }
    
    /// Called when wrapped music player playback status changed.
    /// Informs the delegate.
    @objc func playbackStatusChanged() {
        delegate?.playbackStatusDidChange(self)
    }

}


/// Delegate to react to SongPlayer events
protocol SongPlayerDelegate: NSObjectProtocol {
    
    /// Called when iOS player status changes (playing, paused…)
    ///
    /// - Parameter songPlayer: Player handling playback
    func playbackStatusDidChange(_ songPlayer: SongPlayer)
    
}
