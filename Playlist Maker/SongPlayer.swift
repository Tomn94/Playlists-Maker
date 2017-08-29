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
    private let musicPlayer = MPMusicPlayerController.applicationQueuePlayer()
    
    
    
    /// Is a song currently playing
    var isPlaying: Bool {
        return musicPlayer.playbackState == .playing
    }
    
    /// Time elapsed while playing the song
    var currentTime: TimeInterval {
        let time = musicPlayer.currentPlaybackTime
        if time.isNaN {
            return 0
        }
        return time
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
        
        playbackTimeChanged()
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
        
        // Create a time to update delegate's slider
        timeUpdater = Timer(timeInterval: 0.1, target: self,
                            selector: .playbackTimeChanged, userInfo: nil,
                            repeats: true)
        RunLoop.current.add(timeUpdater!, forMode: .commonModes)
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
        
        // No need timeUpdater when paused
        if !isPlaying {
            timeUpdater?.invalidate()
            timeUpdater = nil
        }
    }
    
    /// Called when current playback time has changed
    @objc func playbackTimeChanged() {
        delegate?.currentTimeChanged(self)
    }

}


/// Delegate to react to SongPlayer events
protocol SongPlayerDelegate: NSObjectProtocol {
    
    /// Called when iOS player status changes (playing, paused…)
    ///
    /// - Parameter songPlayer: Player handling playback
    func playbackStatusDidChange(_ songPlayer: SongPlayer)
    
    /// Called when the time changes during normal playback
    /// (not called after user interaction, e.g. scrub bar
    ///
    /// - Parameter songPlayer: Player handling playback
    func currentTimeChanged(_ songPlayer: SongPlayer)
    
}
