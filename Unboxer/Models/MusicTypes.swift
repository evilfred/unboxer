//
//  Artist.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-03.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Cocoa
import Foundation
import SwiftUI

protocol Namable {
    var name: String { get }
}

typealias IdNamable = Identifiable & Namable

struct Artist: Hashable, Codable, IdNamable {
    var id: Int
    var name: String
}

struct Album: Hashable, Codable, IdNamable {
    var id: Int
    var artistId: Int
    var name: String
}

struct Artwork: Hashable, Codable, Identifiable {
    var id: Int
    var path: String?
}

struct Track: Hashable, Codable, Identifiable {
    var id: Int
    
    var keyId: Int?
    var originalArtistId: Int?
    var artworkId: Int?
    var albumId: Int?
    var composerId: Int?
    var colorId: Int?
    var labelId: Int?
    var remixerId: Int?
    var artistId: Int?
    var genreId: Int?
    
    var bitmask: UInt32
    
    var duration: Int
    var bitRate: Int
    var sampleRate: Int
    var fileSize: Int
    var trackNumber: Int
    var tempo: Int
    var year: Int
    var rating: Int
    var sampleDepth: Int
    var discNumber: Int
    var playCount: Int
    
    var isrc: String?
    var title: String?
    var dateAdded: String?
    var releaseDate: String?
    var remixName: String?
    var analyzePath: String?
    var analyzeDate: String?
    var comment: String?
    var filename: String?
    var filePath: String?
}

struct Color: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
}

struct Playlist: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var sortOrder: UInt32
    var isFolder: Bool
    var children: [Playlist]
    var tracks: [Int]
}
