//
//  PlaylistsView.swift
//  Playlist Maker
//
//  Created by Tomn on 06/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

class PlaylistsViewController: UICollectionViewController {
    
}

// MARK: - Data Source
extension PlaylistsViewController {
    
    /// Defines the number of playlists displayed
    ///
    /// - Parameters:
    ///   - collectionView: Collection View to configure
    ///   - section: Group of cells to fill
    /// - Returns: Number of playlist cells in a given section
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return DataStore.shared.library.playlists.count
    }
    
    /// Configure cells
    ///
    /// - Parameters:
    ///   - collectionView: Collection View to populate
    ///   - indexPath: Position of the cell to configure
    /// - Returns: The configured cell
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playlistCell",
                                                      for: indexPath) as! PlaylistCell
        
        cell.wrapper.layer.cornerRadius = 5
        cell.wrapper.clipsToBounds = true
        
        return cell
    }
    
}

// MARK: - Delegate
extension PlaylistsViewController {
    
}


// MARK:
/// Appearance & structure of a cell displaying a playlist
class PlaylistCell: UICollectionViewCell {
    
    /// Text displaying the name of the playlist
    @IBOutlet weak var name:  UILabel!
    
    /// Background image
    @IBOutlet weak var image: UIImageView!
    
    /// View holding the content (name, image)
    @IBOutlet weak var wrapper: UIView!
    
}
