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
        
        if let selected = collectionView.indexPathsForSelectedItems?.contains(indexPath) {
            cell.apply(style: selected ? PlaylistCell.selectedShadowStyle : PlaylistCell.unselectedShadowStyle)
        } else {
            cell.apply(style: PlaylistCell.unselectedShadowStyle)
        }
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
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PlaylistCell {
            
            cell.animateSelectionStyle(before: PlaylistCell.unselectedShadowStyle,
                                       after:  PlaylistCell.selectedShadowStyle)
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - collectionView: <#collectionView description#>
    ///   - indexPath: <#indexPath description#>
    override func collectionView(_ collectionView: UICollectionView,
                                 didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PlaylistCell {
            
            cell.animateSelectionStyle(before: PlaylistCell.selectedShadowStyle,
                                       after:  PlaylistCell.unselectedShadowStyle)
        }
    }
    
}


// MARK:
/// Appearance & structure of a cell displaying a playlist
class PlaylistCell: UICollectionViewCell {
    
    typealias PlaylistCellStyle = (opacity: Float, color: CGColor, radius: CGFloat, offset: CGSize)
    
    static let unselectedShadowStyle: PlaylistCellStyle = (opacity: 0.2, color: UIColor.black.cgColor,
                                                           radius: 5, offset: CGSize(width: 0, height: 4))
    
    static let selectedShadowStyle:   PlaylistCellStyle = (opacity: 1, color: #colorLiteral(red: 1, green: 0.231372549, blue: 0.1921568627, alpha: 1).cgColor,
                                                           radius: 8, offset: .zero)
    
    
    /// Text displaying the name of the playlist
    @IBOutlet weak var name:  UILabel!
    
    /// Background image
    @IBOutlet weak var imageView: UIImageView!
    
    /// View holding the content (name, image)
    @IBOutlet weak var wrapper: UIView!
    
    
    func apply(style: PlaylistCellStyle) {
        let contentLayer = contentView.layer
        contentLayer.shadowOpacity = style.opacity
        contentLayer.shadowColor   = style.color
        contentLayer.shadowRadius  = style.radius
        contentLayer.shadowOffset  = style.offset
    }
    
    func animateSelectionStyle(before: PlaylistCellStyle, after: PlaylistCellStyle) {
        
        let duration = 0.15
        let contentLayer = contentView.layer
        
        let animationOpacity = CABasicAnimation(keyPath: "shadowOpacity")
        animationOpacity.fromValue = before.opacity
        animationOpacity.toValue   = after.opacity
        animationOpacity.duration  = duration
        contentLayer.add(animationOpacity, forKey: "shadowOpacity")
        
        let animationColor = CABasicAnimation(keyPath: "shadowColor")
        animationColor.fromValue = before.color
        animationColor.toValue   = after.color
        animationColor.duration  = duration
        contentLayer.add(animationColor, forKey: "shadowColor")
        
        let animationRadius = CABasicAnimation(keyPath: "shadowRadius")
        animationRadius.fromValue = before.radius
        animationRadius.toValue   = after.radius
        animationRadius.duration  = duration
        contentLayer.add(animationRadius, forKey: "shadowRadius")
        
        let animationOffset = CABasicAnimation(keyPath: "shadowOffset")
        animationOffset.fromValue = before.offset
        animationOffset.toValue   = after.offset
        animationOffset.duration  = duration
        contentLayer.add(animationOffset, forKey: "shadowOffset")
        
        apply(style: after)
    }
    
}
