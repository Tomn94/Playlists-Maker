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
        
        let playlist = DataStore.shared.library.playlists[indexPath.item]
        cell.name.text = playlist.name
        cell.imageView.image = playlist.artwork
        
        cell.wrapper.layer.cornerRadius = 7
        cell.wrapper.clipsToBounds = true
        
        let contentLayer = cell.contentView.layer
        contentLayer.shadowOpacity = PlaylistCell.shadowStyle.opacity
        contentLayer.shadowColor   = PlaylistCell.shadowStyle.color
        contentLayer.shadowRadius  = PlaylistCell.shadowStyle.radius
        contentLayer.shadowOffset  = PlaylistCell.shadowStyle.offset
        cell.clipsToBounds = false
        
        return cell
    }
    
}

// MARK: - Delegate
extension PlaylistsViewController {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - collectionView: <#collectionView description#>
    ///   - indexPath: <#indexPath description#>
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            
            let contentLayer = cell.contentView.layer
            
            let duration = 0.15
            
            let animationOpacity = CABasicAnimation(keyPath: "shadowOpacity")
            animationOpacity.fromValue = PlaylistCell.shadowStyle.opacity
            animationOpacity.toValue   = PlaylistCell.selectedShadowStyle.opacity - 0.2
            animationOpacity.duration  = duration
            contentLayer.add(animationOpacity, forKey: "shadowOpacity")
            
            let animationColor = CABasicAnimation(keyPath: "shadowColor")
            animationColor.fromValue = PlaylistCell.shadowStyle.color
            animationColor.toValue   = PlaylistCell.selectedShadowStyle.color
            animationColor.duration  = duration
            contentLayer.add(animationColor, forKey: "shadowColor")
            
            let animationRadius = CABasicAnimation(keyPath: "shadowRadius")
            animationRadius.fromValue = PlaylistCell.shadowStyle.radius
            animationRadius.toValue   = PlaylistCell.selectedShadowStyle.radius
            animationRadius.duration  = duration
            contentLayer.add(animationRadius, forKey: "shadowRadius")
            
            let animationOffset = CABasicAnimation(keyPath: "shadowOffset")
            animationOffset.fromValue = PlaylistCell.shadowStyle.offset
            animationOffset.toValue   = PlaylistCell.selectedShadowStyle.offset
            animationOffset.duration  = duration
            contentLayer.add(animationOffset, forKey: "shadowOffset")
            
            contentLayer.shadowOpacity = PlaylistCell.selectedShadowStyle.opacity
            contentLayer.shadowColor   = PlaylistCell.selectedShadowStyle.color
            contentLayer.shadowRadius  = PlaylistCell.selectedShadowStyle.radius
            contentLayer.shadowOffset  = PlaylistCell.selectedShadowStyle.offset
        }
    }
    
}


// MARK:
/// Appearance & structure of a cell displaying a playlist
class PlaylistCell: UICollectionViewCell {
    
    typealias PlaylistCellStyle = (opacity: Float, color: CGColor, radius: CGFloat, offset: CGSize)
    static let shadowStyle        : PlaylistCellStyle = (opacity: 0.2, color: UIColor.black.cgColor,
                                                         radius: 5, offset: CGSize(width: 0, height: 4))
    static let selectedShadowStyle: PlaylistCellStyle = (opacity: 1, color: #colorLiteral(red: 1, green: 0.231372549, blue: 0.1921568627, alpha: 1).cgColor,
                                                         radius: 8, offset: .zero)
    
    
    /// Text displaying the name of the playlist
    @IBOutlet weak var name:  UILabel!
    
    /// Background image
    @IBOutlet weak var imageView: UIImageView!
    
    /// View holding the content (name, image)
    @IBOutlet weak var wrapper: UIView!
    
}
