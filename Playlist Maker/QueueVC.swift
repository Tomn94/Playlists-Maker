//
//  QueueVC.swift
//  Playlist Maker
//
//  Created by Tomn on 31/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// View controller presenting a list of songs to sort.
/// Displayed modally on top of presenting view controller with a blur effect inbetween.
class QueueVC: UIViewController {

    /// Model
    let songs = DataStore.shared.library.songs
    
    /* UI */
    /// Table view containing listed songs
    @IBOutlet weak var tableView: UITableView!
    /// Main view containing the table view on top of a blur effect
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Apply vibrancy on cell separators using the same blur effect */
        if let effect = visualEffectView.effect as? UIBlurEffect {
            tableView.separatorEffect = UIVibrancyEffect(blurEffect: effect)
        }
    }

}

// MARK: - Table View Data Source
extension QueueVC: UITableViewDataSource {
    
    /// Determines the number of rows in the list
    ///
    /// - Parameters:
    ///   - tableView: Songs list view
    ///   - section: One and only section
    /// - Returns: Number of songs
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    /// Populates the songs list with rows
    ///
    /// - Parameters:
    ///   - tableView: Songs list view
    ///   - indexPath: Position in the list
    /// - Returns: Customized row with its content
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell & its model data */
        let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath)
        let song = songs[indexPath.row]
        
        /* Put Artist & Album names together, separated by an em dash */
        var detailText = ""
        if !song.artist.isEmpty {
            detailText += song.artist
        }
        if !(song.album?.isEmpty ?? true) {
            if !detailText.isEmpty {
                detailText += " — "
            }
            detailText += song.album ?? ""
        }
        
        /* Apply on UI */
        cell.textLabel?.text       = song.title
        cell.detailTextLabel?.text = detailText
        cell.imageView?.image      = song.artwork
        cell.backgroundColor       = .clear  // see blur behind
        
        return cell
    }
    
}
