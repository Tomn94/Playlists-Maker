//
//  GenresTVC.swift
//  Playlist Maker
//
//  Created by Tomn on 01/09/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// Lists genres and their associated emoji.
/// ± easter egg
class GenresVC: UIViewController {
    
    /// Model
    var genres = [
        "🤠 Country",
        "🕺 Disco, Funk, Wave",
        "📻 New Age",
        "🔌 Alternative, Indie",
        "🎙 Rap, Hip-Hop, R'n'B, Soul",
        "🎻 Classical",
        "💃 Dance",
        "🎛 Electronic, Club, Dubstep",
        "🏠 House",
        "🇯🇲 Reggae",
        "🎸 Rock",
        "🎤 Pop",
        "🎷 Jazz",
        "🇪🇸 Latin",
        "🤘 Metal, Punk",
        "👨‍🎤 Singer, Voice",
        "🎥 Soundtrack",
        "🎮 Game",
        "⛪️ Gospel, Spiritual",
        "🌍 World",
        "🎹 Instrumental",
        "💤 Meditative",
        "⚗️ Experimental",
        "🇯🇵 J-Pop",
        "📓 Book",
        "👽 Fantasy",
        "👶 Kids",
        "⭐️ Teens",
        "⚽️ Sports",
        "🏄 Surf",
        "📺 TV",
        "🇬🇧 Brit-Pop",
        "🇫🇷 Variété",
        "🇩🇪 German",
        "❓ Unknown"
    ]
    
    /// UI
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Sort by name (strip emoji) */
        let sortedSet = CharacterSet.alphanumerics.inverted
        genres.sort { genre1, genre2 in
            
            // Remove Variation Selector character for specific emoji, then remove emoji and space
            let strippedGenre1 = genre1.replacingOccurrences(of: "\u{fe0f}", with: "").trimmingCharacters(in: sortedSet)
            let strippedGenre2 = genre2.replacingOccurrences(of: "\u{fe0f}", with: "").trimmingCharacters(in: sortedSet)
            
            return strippedGenre1.localizedCaseInsensitiveCompare(strippedGenre2) == .orderedAscending
        }
        
        /* Apply vibrancy on cell separators using the same blur effect */
        if let effect = visualEffectView.effect as? UIBlurEffect {
            tableView.separatorEffect = UIVibrancyEffect(blurEffect: effect)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if #available(iOS 11.0, *) {
        } else {  // iOS 10
            let barInsets = UIEdgeInsets(top: self.topLayoutGuide.length,
                                         left: 0, bottom: 0, right: 0)
            tableView.contentInset  = barInsets
            tableView.scrollIndicatorInsets = barInsets
            tableView.contentOffset = CGPoint(x: 0, y: -self.topLayoutGuide.length)
        }
    }
    
}


// MARK: - Table View Data Source
extension GenresVC: UITableViewDataSource {    

    func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return genres.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell",
                                                 for: indexPath)

        cell.textLabel?.text = genres[indexPath.row]

        return cell
    }

}
