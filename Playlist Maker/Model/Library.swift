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
    var status: LibraryStatus {
        return MPMediaLibrary.authorizationStatus()
    }
    
    
    /// Ask access to iOS music library
    ///
    /// - Parameter handler: Block called after the user choses whether to authorize the app
    func askAuthorization(handler: @escaping (LibraryStatus) -> Void) {
        
        MPMediaLibrary.requestAuthorization(handler)
    }
    
    
    // MARK: Songs
    
    /// List of the songs to sort
    var songs = [Song]()
    
    /// List of the destination playlists
    var playlists = [Playlist]()
    
    /// Fill library with songs to sort
    func load() {
        
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
        
        /* Playlists
        // Get raw playlists in library focus
        let libraryPlaylists = MPMediaQuery.playlists().collections ?? []
        var playlists = [Playlist]()
        
        // Store playlists
        for libraryPlaylist in libraryPlaylists {
            playlists.append(Playlist(collection: libraryPlaylist))
        }
        
        self.playlists = playlists*/
    }
    
}


/// Represents a song in the user's library.
/// Wraps MPMediaItem
struct Song {
    
    /// Default maximum artwork size displayed
    static let artworkSize = CGSize(width: 100, height: 100)
    
    
    let title: String
    
    let artist: String//Artist
    
    let album: String?//Album
    
    let genre: (category: Genre?, raw: String?)
    
    let length: TimeInterval
    
    let artwork: UIImage?
    
    
    /// Init Song object with a media library query result
    ///
    /// - Parameter item: Library item to wrap in Song object
    init(item: MPMediaItem) {
        
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
    }
    
}

/// Represents a user's playlist in their library.
/// MPMediaItemCollection wrapper
struct Playlist {
    
    /// Name of the playlist
    let name: String
    
    /// Songs contained in the playlist
    let songs: [Song]
    
    /// Init Playlist object with a playlist raw type
    ///
    /// - Parameter collection: Playlist in library
    init(collection: MPMediaItemCollection) {
        
        self.name  = collection.value(forProperty: MPMediaPlaylistPropertyName) as? String ?? "Unknown playlist"
        self.songs = collection.items.map({ playlistItem -> Song in
            Song(item: playlistItem)
        })
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
