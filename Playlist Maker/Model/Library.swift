//
//  Library.swift
//  Playlist Maker
//
//  Created by Tomn on 04/05/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import Foundation
import MediaPlayer

/// Contains all information about the current songs to sort
class Library {
    
    
    // MARK: Status
    
    typealias LibraryStatus = MPMediaLibraryAuthorizationStatus
    
    /// Get current access status from iOS
    class var status: LibraryStatus {
        return MPMediaLibrary.authorizationStatus()
    }
    
    
    /// Ask access to iOS music library
    ///
    /// - Parameter handler: Block called after the user choses whether to authorize the app
    class func askAuthorization(handler: @escaping (LibraryStatus) -> Void) {
        
        MPMediaLibrary.requestAuthorization(handler)
    }
    
    
    // MARK: Songs
    
    /// List of the songs to sort
    var songs = [Song]()
    
    /// List of the destination playlists
    var playlists = [Playlist]()
    
    /// Fill library with songs to sort
    func load(completionHandler completion: @escaping () -> ()) {
        
        /* Songs */
        // Get raw songs in library focus
        let songsLibrary = MPMediaQuery(filterPredicates: [MPMediaPropertyPredicate(value: "Asher Roth",
                                                                                    forProperty: MPMediaItemPropertyArtist,
                                                                                    comparisonType: .contains)])
        let librarySongs = songsLibrary.items ?? []
        var songs = [Song]()
        
        // Store songs
        for songItem in librarySongs {
            songs.append(Song(item: songItem))
        }
        
        self.songs = songs
        
        /* Playlists */
        // Get raw playlists in library focus
        let libraryPlaylists = MPMediaQuery.playlists().collections ?? []
        var playlists = [Playlist]()
        
        // Store playlists
        for libraryPlaylist in libraryPlaylists {
            playlists.append(Playlist(collection: libraryPlaylist))
        }
        
        // Sort by name
        playlists.sort { playlist1, playlist2 in
            return playlist1.name < playlist2.name
        }
        
        self.playlists = playlists
        completion()
    }
    
    class func createPlaylist(named playlistName: String,
                              completion completionHandler: @escaping (Playlist?, Error?) -> ()) {
        
        let data = MPMediaPlaylistCreationMetadata(name: playlistName)
        MPMediaLibrary.default().getPlaylist(with: UUID(),
                                             creationMetadata: data,
                                             completionHandler:
            { playlist, error in
                
                guard playlist != nil, error == nil else {
                    completionHandler(nil, error)
                    return
                }
                
                let newPlaylist = Playlist(collection: playlist!)
                completionHandler(newPlaylist, nil)
        })
    }
    
}


/// Represents a song in the user's library.
/// Wraps MPMediaItem
struct Song {
    
    /// Default maximum artwork size displayed
    static let artworkSize = CGSize(width: 100, height: 100)
    
    
    let id: UInt64
    
    let title: String
    
    let artist: String//Artist
    
    let album: String?//Album
    
    let genre: (category: Genre?, raw: String?)
    
    let length: TimeInterval
    
    let artwork: UIImage?
    
    let item: MPMediaItem
    
    
    /// Init Song object with a media library query result
    ///
    /// - Parameter item: Library item to wrap in Song object
    init(item: MPMediaItem) {
        
        self.id      = item.persistentID
        self.title   = item.title ?? "Unknown title"
        self.artist  = item.artist ?? "Unknown artist"
        self.album   = item.albumTitle ?? "Unknown album"
        if let genre = item.genre {
            self.genre = (Genre(fromString: genre), genre)
        } else {
            self.genre = (nil, item.genre)
        }
        self.length  = item.playbackDuration
        self.artwork = item.artwork?.image(at: Song.artworkSize)
        self.item    = item
    }
    
}

/// Represents a user's playlist in their library.
/// MPMediaItemCollection wrapper
struct Playlist {
    
    /// Default maximum artwork size displayed
    static let artworkSize = CGSize(width: 200, height: 200)
    
    
    let id: NSNumber
    
    /// Name of the playlist
    let name: String
    
    /// Songs contained in the playlist
//    let songs: [Song]
    
    let artwork: UIImage?
    
    
    /// Init Playlist object with a playlist raw type
    ///
    /// - Parameter collection: Playlist in library
    init(collection: MPMediaItemCollection) {
        
        self.id   = collection.value(forProperty: MPMediaPlaylistPropertyPersistentID) as? NSNumber ?? NSNumber(value: 0)
        
        self.name = collection.value(forProperty: MPMediaPlaylistPropertyName) as? String ?? "Unknown playlist"
        
        /* Fetch artworks from the 4 first tracks
           Does not use collection.items.dropLast because it's O(nbrSongs - 4) */
        var artworks = [UIImage]()
        let nbrSongs = collection.count
        if let firstArtwork = collection.items.first?.artwork?.image(at: Playlist.artworkSize) {
            artworks.append(firstArtwork)
        }
        if nbrSongs > 1,
           let secondArtwork = collection.items[1].artwork?.image(at: Playlist.artworkSize) {
            artworks.append(secondArtwork)
        }
        if nbrSongs > 2,
           let thirdArtwork  = collection.items[2].artwork?.image(at: Playlist.artworkSize) {
            artworks.append(thirdArtwork)
        }
        if nbrSongs > 3,
           let fourthArtwork = collection.items[3].artwork?.image(at: Playlist.artworkSize) {
            artworks.append(fourthArtwork)
        }
        /* Try to find other artworks if there are not 4 enough */
        var index = 4
        while artworks.count < 4 && index < nbrSongs && index < 50 {
            
            if let otherArtwork = collection.items[index].artwork?.image(at: Playlist.artworkSize) {
                artworks.append(otherArtwork)
            }
            index += 1
        }
        
        /* Combine them */
        self.artwork = Playlist.combinedArtwork(from: artworks)
        
        /*self.songs = collection.items.map({ playlistItem -> Song in
            Song(item: playlistItem)
        })*/
    }
    
    /// <#Description#>
    ///
    /// - Parameter artworks: <#artworks description#>
    /// - Returns: <#return value description#>
    private static func combinedArtwork(from artworks: [UIImage]) -> UIImage? {
        
        if artworks.count >= 2 {
            let size = Playlist.artworkSize
            
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
            let halfWidth  = size.width  / 2
            let halfHeight = size.height / 2
            
            UIColor.white.set()
            UIRectFill(CGRect(origin: .zero, size: size))
            
            if artworks.count == 2 {
                let halfSize = CGSize(width: size.width / 2, height: size.height / 2)
                
                artworks[0].draw(in: CGRect(origin: .zero, size: halfSize))
                artworks[1].draw(in: CGRect(origin: CGPoint(x: halfHeight, y: 0), size: halfSize))
                
            } else {
                let quarterSize = CGSize(width: size.width / 2, height: size.height / 2)
                
                artworks[0].draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: quarterSize))
                artworks[1].draw(in: CGRect(origin: CGPoint(x: halfWidth, y: 0), size: quarterSize))
                artworks[2].draw(in: CGRect(origin: CGPoint(x: 0, y: halfHeight), size: quarterSize))
                if artworks.count >= 4 {
                    artworks[3].draw(in: CGRect(origin: CGPoint(x: halfWidth, y: halfHeight), size: quarterSize))
                }
            }
            
            defer {
                UIGraphicsEndImageContext()
            }
            
            return UIGraphicsGetImageFromCurrentImageContext()
            
        } else if artworks.count == 1 {
            return artworks.first
            
        } else {
            return nil
        }
    }
    
    /// <#Description#>
    ///
    /// - Parameter song: <#song description#>
    /// - Returns: <#return value description#>
    func contains(song: Song) -> Bool {
        
        let songPredicate = MPMediaPropertyPredicate(value: song.id,
                                                     forProperty: MPMediaItemPropertyPersistentID,
                                                     comparisonType: .equalTo)
        let playlistPredicate = MPMediaPropertyPredicate(value: self.id,
                                                         forProperty: MPMediaPlaylistPropertyPersistentID,
                                                         comparisonType: .equalTo)
        let results = MPMediaQuery(filterPredicates: [songPredicate, playlistPredicate])
        
        return results.items?.count ?? 0 > 0
    }
    
}

struct Artist {
    
    var albums: [Album] {
        return []
    }
    
}

struct Album {
    
}

/// Defines principal music genres
enum Genre: String {
    
    case country = "🤠"
    case disco = "🕺"
    case newAge = "📻"
    case alternative = "🔌"
    case rap = "🎙"
    case classical = "🎻"
    case dance = "💃"
    case electronic = "🎛"
    case house = "🏠"
    case reggae = "🇯🇲"
    case rock = "🎸"
    case pop = "🎤"
    case jazz = "🎷"
    case latin = "🇪🇸"
    case metal = "🤘"
    case singer = "👨‍🎤"
    case soundtrack = "🎥"
    case game = "🎮"
    case gospel = "⛪️"
    case world = "🌍"
    case instrumental = "🎹"
    case meditative = "💤"
    case experimental = "⚗️"
    case jPop = "🇯🇵"
    case book = "📓"
    case fantasy = "👽"
    case kids = "👶"
    case teens = "⭐️"
    case sports = "⚽️"
    case surf = "🏄"
    case tv = "📺"
    case britPop = "🇬🇧"
    case variété = "🇫🇷"
    case german = "🇩🇪"
    case unknown = "❓"
    
    init?(fromString input: String) {
        
        /* Lowercase and without accents for comparison purposes */
        let normalizedInput = input.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        
        /* Find genre in input string */
        if normalizedInput.containsAny(["country"]) {
            self = .country
        } else if normalizedInput.containsAny(["variete", "franc", "french"]) {
            self = .variété
        } else if normalizedInput.containsAny(["brit"]) {
            self = .britPop
        } else if normalizedInput.containsAny(["german"]) {
            self = .german
        } else if normalizedInput.containsAny(["disco", "funk", "wave"]) {
            self = .disco
        } else if normalizedInput.containsAny(["age", "old", "swing"]) {
            self = .newAge
        } else if normalizedInput.containsAny(["rap", "hip-hop", "hiphop", "hip hop", "soul", "r&b", "rnb", "r'n'b"]) {
            self = .rap
        } else if normalizedInput.containsAny(["alternati", "indie", "trip"]) {
            self = .alternative
        } else if normalizedInput.containsAny(["classi", "symphoni", "sonat", "chamb"]) {
            self = .classical
        } else if normalizedInput.containsAny(["dance", "danse"]) {
            self = .dance
        } else if normalizedInput.containsAny(["lectroni", "dubstep", "tech", "trance", "fusion", "acid", "club"]) {
            self = .electronic
        } else if normalizedInput.containsAny(["house", "lounge"]) {
            self = .house
        } else if normalizedInput.containsAny(["reggae", "dub", "root", "ska"]) {
            self = .reggae
        } else if normalizedInput.containsAny(["jazz"]) {
            self = .jazz
        } else if normalizedInput.containsAny(["latin", "tango", "samba", "spain", "spanish", "espagn"]) {
            self = .latin
        } else if normalizedInput.containsAny(["metal", "punk", "hard", "bass", "jungle"]) {
            self = .metal
        } else if normalizedInput.containsAny(["singer", "chant", "vocal", "auteur", "writer", "voix", "voice", "spoken", "parle", "podcast"]) {
            self = .singer
        } else if normalizedInput.containsAny(["soundtrack", "movie", "film", "video"]) {
            self = .soundtrack
        } else if normalizedInput.containsAny(["kid", "child", "enfan", "family", "famille", "christmas", "holiday", "vacance"]) {
            self = .kids
        } else if normalizedInput.containsAny(["gospel", "christ", "chreti", "religi", "spirit"]) {
            self = .gospel
        } else if normalizedInput.containsAny(["world", "monde", "folk", "europ"]) {
            self = .world
        } else if normalizedInput.containsAny(["instrument", "acousti", "ambient", "ambian"]) {
            self = .instrumental
        } else if normalizedInput.containsAny(["meditat", "down"]) {
            self = .meditative
        } else if normalizedInput.containsAny(["jpop", "j-pop", "j pop", "anime"]) {
            self = .jPop
        } else if normalizedInput.containsAny(["book"]) {
            self = .book
        } else if normalizedInput.containsAny(["fantas", "scifi", "sci-fi", "sci fi"]) {
            self = .fantasy
        } else if normalizedInput.containsAny(["surf"]) {
            self = .surf
        } else if normalizedInput.containsAny(["sport"]) {
            self = .sports
        } else if normalizedInput.containsAny(["tv", "television"]) {
            self = .tv
        } else if normalizedInput.containsAny(["pop"]) {
            self = .pop
        } else if normalizedInput.containsAny(["rock", "grunge", "drum", "blues", "guitar"]) {
            self = .rock
        } else if normalizedInput.containsAny(["experiment", "industrial"]) {
            self = .experimental
        } else if normalizedInput.containsAny(["game", "jeu"]) {
            self = .game
        } else if normalizedInput.containsAny(["teen", "ado"]) {
            self = .teens
        } else if normalizedInput.containsAny(["unknown", "other", "easy"]) {
            self = .unknown
        } else {
            return nil
        }
    }
}

extension String {
    
    /// Indicates whether the string contains any inputted substring
    ///
    /// - Parameter array: Substrings to locate in this larger string
    /// - Returns: True if one or more substrings are found
    func containsAny(_ array: [String]) -> Bool {
        
        /* Return true as soon as we have our 1st match */
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        
        return false
    }
    
}
