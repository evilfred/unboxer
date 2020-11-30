//
//  MusicCatalog.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-04.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Foundation

struct MusicCatalog {
    
    var basePath: String
    
    var playlists: [Playlist]
    
    var albums: [Int: Album]
    var artists: [Int: Artist]
    var tracks: [Int: Track]
       
    var artworks: [Int: String]
    var genres: [Int: String]
    var labels: [Int: String]
    var keys: [Int: String]
    
    init(basePath: String, pdb: PdbFile) {
        self.basePath = basePath
        
        self.playlists = extractPlaylists(pdb)
        self.albums = extractAlbums(pdb)
        self.artists = extractArtists(pdb)
        self.tracks = extractTracks(pdb)
        self.artworks = extractArtworks(pdb)
        self.genres = extractGenres(pdb)
        self.labels = extractLabels(pdb)
        self.keys = extractKeys(pdb)
    }
}
