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
    let songs: [[Song]] = {
        let allSongs     = DataStore.shared.library.songs
        let currentIndex = DataStore.shared.currentIndex ?? 0
        
        /* Cut sections at current index */
        let done = allSongs[0 ..< currentIndex]
        let todo = allSongs[currentIndex ..< allSongs.count]
        
        return [Array(done), Array(todo)]
    }()
    
    /* UI */
    /// Table view containing listed songs
    @IBOutlet weak var tableView: UITableView!
    
    /// Main view containing the table view on top of a blur effect
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let count = DataStore.shared.library.songs.count
        if count == 1 {
            title = "Sorting 1 Song"
        } else {
            title = "Sorting \(count) Songs"
        }

        /* Apply vibrancy on cell separators using the same blur effect */
        if let effect = visualEffectView.effect as? UIBlurEffect {
            tableView.separatorEffect = UIVibrancyEffect(blurEffect: effect)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        /* Always show the current song */
        guard songs.count > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: false)
    }

}

// MARK: - Table View Data Source
extension QueueVC: UITableViewDataSource {
    
    /// Determines the number of sections in the list
    ///
    /// - Parameter tableView: Songs list view
    /// - Returns: 2 sections, Done & To Do
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return songs.count
    }
    
    /// Determines the number of rows in the list
    ///
    /// - Parameters:
    ///   - tableView: Songs list view
    ///   - section: Section index
    /// - Returns: Number of songs
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        return songs[section].count
    }
    
    /// Fills the section names
    ///
    /// - Parameters:
    ///   - tableView: Songs list view
    ///   - section: Section index
    /// - Returns: Number of songs in section and section title
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            let count = songs[0].count
            if count == 1 {
                return "1 Sorted Song"
            }
            return "\(count) Sorted Songs"
        }
        
        return "\(songs[1].count) Remaining"
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
        let song = songs[indexPath.section][indexPath.row]
        
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
