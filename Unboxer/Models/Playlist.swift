//
//  Playlist.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-02.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Foundation

struct Playlist: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
}

struct TrackRef: Hashable, Codable, Identifiable {
    var id: Int
    var trackId: Int
}

struct Track: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var bpm: Int
    
}
