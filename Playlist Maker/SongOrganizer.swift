//
//  ViewController.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

class SongOrganizer: UIViewController {

    @IBOutlet weak var artwork: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var scrubbar: UISlider!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressionLabel: UILabel!
    
    @IBOutlet weak var playlistsView: UICollectionView!
    @IBOutlet weak var playlistsLayout: UICollectionViewFlowLayout!
    var playlistsViewController: PlaylistsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistsViewController  = PlaylistsViewController(collectionViewLayout: playlistsLayout)
        playlistsView.dataSource = playlistsViewController
        playlistsView.delegate   = playlistsViewController
        playlistsView.allowsMultipleSelection = true
        
        DataStore.shared.library.load()
        show(song: DataStore.shared.library.songs.first!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        artwork.layer.cornerRadius = 5
        artwork.clipsToBounds = true
    }

    func show(song: Song) {
        
        artwork.image = song.artwork
        
        titleLabel.text  = song.title
        artistLabel.text = song.artist
        
        var detailText = ""
        
        if let genre = song.genre.category {
            detailText = genre.rawValue
        } else if let genre = song.genre.raw {
            detailText = genre
            if detailText != "" {
                detailText += " — "
            }
        }
        
        if let album = song.album {
            detailText += album
        }
        
        detailLabel.text = detailText
        
        scrubbar.minimumValue = 0
        scrubbar.maximumValue = Float(song.length)
        scrubbar.value = 0
        
        progressionLabel.text = "\((DataStore.shared.currrentIndex ?? 0) + 1)/\(DataStore.shared.library.songs.count)"
        
        if (DataStore.shared.currrentIndex ?? 0) + 1 == DataStore.shared.library.songs.count {
            nextButton.setTitle("Done", for: .normal)
        } else {
            nextButton.setTitle("Next", for: .normal)
        }
    }

}
