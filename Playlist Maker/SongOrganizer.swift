//
//  ViewController.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    
    /// Autoplay button tapped
    static let toggleAutoplay = #selector(SongOrganizer.toggleAutoplay)
    
}


class SongOrganizer: UIViewController, SongPlayerDelegate {
    
    /// Handles track playback
    let songPlayer = SongPlayer()

    /* Song info - top bar */
    @IBOutlet weak var topBar: UIVisualEffectView!
    @IBOutlet weak var songInfoWrapper: UIView!
    
    @IBOutlet weak var artwork: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    /// Genre & Album
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackChangingIndicator: UIActivityIndicatorView!
    /// Total time
    @IBOutlet weak var timeLabel: UILabel!
    
    /* Progress info - bottom bar */
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    @IBOutlet weak var nextButton: UIButton!
    /// X/Y, where X is the current song index and Y the number of songs to sort
    @IBOutlet weak var progressionLabel: UILabel!
    
    /* Main view & its content - collection view */
    /// Collection view
    @IBOutlet weak var playlistsView: UICollectionView!
    /// Collection view layout
    @IBOutlet weak var playlistsLayout: UICollectionViewFlowLayout!
    /// Collection view controller
    var playlistsViewController: PlaylistsViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songPlayer.delegate = self
        
        /* Playlists collection view setup */
        playlistsViewController  = PlaylistsViewController(collectionViewLayout: playlistsLayout)
        playlistsViewController.organizer = self
        playlistsView.dataSource = playlistsViewController
        playlistsView.delegate   = playlistsViewController
        playlistsView.allowsMultipleSelection = true
        
        let insetsFromBars = UIEdgeInsets(top: topBar.frame.height,        left: 0,
                                          bottom: bottomBar.frame.height, right: 0)
        playlistsView.scrollIndicatorInsets = insetsFromBars
        playlistsView.contentInset = insetsFromBars
        
        /* Top bar setup */
        artwork.layer.cornerRadius = 5
        artwork.clipsToBounds = true
        
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        if let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            titleLabel.font = UIFont(descriptor: boldFontDescriptor,
                                     size: 0)  // keep current size
            titleLabel.adjustsFontForContentSizeCategory = true
        }
        
        /* Bottom bar setup */
        nextButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        /* Load content */
        DataStore.shared.library.load {
            /* Completion handler */
            self.playlistsViewController.playlists = DataStore.shared.library.playlists
        }
        showSong(at: 0, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /* Monospaced figures */
        let monospaced = [
            UIFontDescriptorFeatureSettingsAttribute : [
                [UIFontFeatureTypeIdentifierKey     : kNumberSpacingType,           // monospaced
                 UIFontFeatureSelectorIdentifierKey : kMonospacedNumbersSelector],
                [UIFontFeatureTypeIdentifierKey     : kStylisticAlternativesType,   // alternative 6 & 9
                 UIFontFeatureSelectorIdentifierKey : kStylisticAltOneOnSelector]
            ]]
        
        // Time
        let footnoteDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
        let monoFootnoteFontDescriptor = footnoteDescriptor.addingAttributes(monospaced)
        timeLabel.font        = UIFont(descriptor: monoFootnoteFontDescriptor, size: 0)
        
        // Progression
        let caption2Descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption2)
        let monoCaption2FontDescriptor = caption2Descriptor.addingAttributes(monospaced)
        progressionLabel.font = UIFont(descriptor: monoCaption2FontDescriptor, size: 0)
    }
    
    func setUpNavigationBar() {
        
        let toggleButton = RecessedButton(type: .system)
        toggleButton.setTitle("Autoplay", for: .normal)
        toggleButton.isSelected = UserDefaults.standard.bool(forKey: UserDefaultKeys.autoplaySongs)
        toggleButton.addTarget(self, action: .toggleAutoplay, for: .touchUpInside)
        navigationItem.leftBarButtonItem = RecessedBarButton(button: toggleButton)
    }

    func showSong(at index: Int,
                  animated: Bool = true) {
        
        /* Avoids retap mistakes */
        nextButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.nextButton.isUserInteractionEnabled = true
        }
        
        /* Update current song */
        let songs = DataStore.shared.library.songs
        let songsCount = songs.count
        guard index < songsCount else { return }
        let song = songs[index]
        
        DataStore.shared.currentIndex = index
        
        if animated {
            /* Animate changes */
            let pushAnimation = CATransition()
            pushAnimation.duration = 0.3
            pushAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pushAnimation.type = kCATransitionPush
            pushAnimation.subtype = kCATransitionFromRight
            songInfoWrapper.layer.add(pushAnimation, forKey: nil)
            
            let fadeAnimation = CATransition()
            fadeAnimation.duration = 0.3
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            playlistsView.layer.add(fadeAnimation, forKey: nil)
            timeLabel.layer.add(fadeAnimation, forKey: nil)
        }
    
        /* We'll deselect previous selection */
        let previouslySelectedIndexes = playlistsView.indexPathsForSelectedItems ?? []
        /* And select the playlists in which the song is */
        let playlists = DataStore.shared.library.playlists
        var selectedIndexes = [IndexPath]()
        for (index, playlist) in playlists.enumerated() {
            if playlist.contains(song: song) {
                
                let selectedIndex = IndexPath(item: index, section: 0)
                selectedIndexes.append(selectedIndex)
                
                playlistsView.selectItem(at: selectedIndex, animated: false, scrollPosition: [])
                
                let cell = playlistsView.cellForItem(at: selectedIndex) as? PlaylistCell
                cell?.apply(style: PlaylistCell.selectedShadowStyle)
            }
        }
        /* Apply deselection, but avoiding deselecting common playlists */
        for selectedIndex in previouslySelectedIndexes
            where !selectedIndexes.contains(selectedIndex) {
                playlistsView.deselectItem(at: selectedIndex, animated: false)
                
                let cell = playlistsView.cellForItem(at: selectedIndex) as? PlaylistCell
                cell?.apply(style: PlaylistCell.deselectedShadowStyle)
        }
        playlistsViewController.indexPathsForPlaylistsAlreadyContaining = selectedIndexes
        
        /* Update UI */
        // Base info
        artwork.image    = song.artwork
        titleLabel.text  = song.title
        artistLabel.text = song.artist
        
        var detailText = ""
        // Genre
        if let genre = song.genre.category {
            detailText = genre.rawValue
        } else if let genre = song.genre.raw {
            detailText = genre
            if detailText != "" {
                detailText += " — "
            }
        }
        // Album
        if let album = song.album {
            detailText += album
        }
        detailLabel.text = detailText
        
        // Time info
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        timeLabel.text = formatter.string(from: song.length)
        
        // Load song in player
        songPlayer.load(songs: [song])
        if DataStore.autoplaysSong {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                // Dispatch otherwise player UI not ready
                self.songPlayer.resume()
            }
        }
        
        // Bottom bar
        progressionLabel.text = "\(index + 1)/\(songsCount)"
        
        if index + 1 == songs.count {
            nextButton.setTitle("Done", for: .normal)
        } else {
            nextButton.setTitle("Next Song", for: .normal)
        }
    }
    
    
    // MARK: Actions
    
    /// Autoplay switch button tapped
    func toggleAutoplay() {
        
        let userDefaults = UserDefaults.standard
        let autoplayKey  = UserDefaultKeys.autoplaySongs
        userDefaults.set(!userDefaults.bool(forKey: autoplayKey), forKey: autoplayKey)
    }

    /// Next button tapped
    @IBAction func nextSong() {
        
        guard let currentIndex = DataStore.shared.currentIndex
            else { return }
        
        showSong(at: currentIndex + 1)
    }
    
    
    // MARK: Media playback - User actions
    
    /// Play/Pause button tapped
    @IBAction func playPause() {
        
        songPlayer.playPause()
        
        /* iOS takes some time to change playback status,
           we'll indicate it with an unknown status indicator */
        playbackChangingIndicator.startAnimating()
        playButton.isHidden = true
    }
    
    
    // MARK: Media playback - Received events
    
    func playbackStatusDidChange(_ songPlayer: SongPlayer) {
        
        /* Hide unknown status indicator */
        playbackChangingIndicator.stopAnimating()
        playButton.isHidden = false
        
        /* Update play/pause button */
        if songPlayer.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
}
