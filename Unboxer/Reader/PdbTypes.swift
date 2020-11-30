//
//  Pages.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-02.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Foundation

/**
Refer to analysis at https://djl-analysis.deepsymmetry.org/rekordbox-export-analysis/exports.html
*/

struct PdbFile {
    var blank: UInt32 = 0
    var len_page: UInt32 = 0
    var num_tables: UInt32 = 0
    var next_unused_page: UInt32 = 0
    var unknown: UInt32 = 0
    var sequence: UInt32 = 0
    var more_blank: UInt32 = 0
    var table_headers: [TableHeader] = []
}

enum TableType: Int {
    case tracks = 0,
        genres,
        artists,
        albums,
        labels,
        keys,
        colors,
        playlist_tree,
        playlist_entries,
        unknown_9,
        unknown_10,
        unknown_11,
        unknown_12,
        artwork,
        unknown_14,
        unknown_15,
        columns,
        unknown_17,
        unknown_18,
        history
}

struct TableHeader {
    var type: TableType? = nil
    var empty_c: UInt32 = 0
    var first_page: UInt32 = 0
    var last_page: UInt32 = 0
    
    var pages: [TablePage] = [] // derived from page traversal from first_page to last_page
}

struct TablePage {
    var blank: UInt32 = 0
    var pageIndex: UInt32 = 0
    var type: TableType? = nil
    var next_page: UInt32 = 0
    var unknown_1: UInt32 = 0
    var unknown_2: UInt32 = 0
    var num_rows_small: UInt8 = 0
    var unknown_3: UInt8 = 0
    var unknown_4: UInt8 = 0
    var page_flags: UInt8 = 0
    var free_size: UInt16 = 0
    var used_size: UInt16 = 0
    var unknown_5: UInt16 = 0
    var num_rows_large: UInt16 = 0
    var unknown_6: UInt16 = 0 // 1004 for strange blocks
    var unknown_7: UInt16 = 0
    var row_headers: [RowHeader] = []
    
    var isDataPage: Bool = false // derived from page_flags
    var isEmptyPage: Bool = false
    var numRows: UInt16 = 0 // derived from num_rows_small and num_rows_large
    var rows: [Any] = [] // derived from the row_headers, type based on table type
}

struct RowHeader {
    var presence_flags: UInt16 = 0 // bitmask
    var offsets: [UInt16] = [] // in sane order
}

struct AlbumRow {
    var unknown_1: UInt16 = 0
    var index_shift: UInt16 = 0
    var unknown_2: UInt32 = 0
    var artist_id: UInt32 = 0
    var id: UInt32 = 0
    var unknown_3: UInt32 = 0
    var unknown_4: UInt8 = 0
    var ofs_name: UInt8 = 0
    
    var name: String = "" // ofs_name bytes after the start of the row
}

struct ArtistRow {
    var subtype: UInt16 = 0
    var index_shift: UInt16 = 0
    var id: UInt32 = 0
    var unknown_1: UInt8 = 0
    var ofs_name_near: UInt8 = 0
    var ofs_name_far: UInt16 = 0 // only present if subtype is Far
    
    var name: String = "" // ofs_name_near or orfs_name_far bytes after the start of the row
}

struct ArtworkRow {
    var id: UInt32 = 0
    var path: String = ""
}

struct ColorRow {
    var unknown_1: UInt32 = 0
    var unknown_2: UInt8 = 0
    var id: ColorType? = nil // 2 bytes
    var unknown_3: UInt8 = 0
    var name: String = ""
}

enum ColorType: Int {
    case NoColor = 0,
        Pink,
        Red,
        Orange,
        Yellow,
        Green,
        Aqua,
        Blue,
        Purple
}

struct GenreOrLabelRow {
    var id: UInt32 = 0
    var name: String = ""
}

struct KeyRow {
    var id: UInt32 = 0
    var id2: UInt32 = 0
    var name: String = ""
}

struct PlaylistTreeRow {
    var parent_id: UInt32 = 0
    var unknown: UInt32 = 0
    var sort_order: UInt32 = 0
    var id: UInt32 = 0
    var raw_is_folder: UInt32 = 0
    var name: String = ""
    
    var is_folder: Bool = false // derived from raw_is_folder
}

struct PlaylistEntryRow : Hashable {
    var entry_index: UInt32 = 0
    var track_id: UInt32 = 0
    var playlist_id: UInt32 = 0
}

struct ColumnRow {
    var id: UInt16 = 0
    var index: UInt16 = 0
    var name: String = ""
}

struct TrackRow {
    var unknown_1: UInt16 = 0
    var index_shift: UInt16 = 0
    var bitmask: UInt32 = 0
    var sample_rate: UInt32 = 0
    var composer_id: UInt32 = 0
    var file_size: UInt32 = 0
    var unknown_2: UInt32 = 0
    var unknown_3: UInt16 = 0
    var unknown_4: UInt16 = 0
    var artwork_id: UInt32 = 0
    var key_id: UInt32 = 0
    var orig_artist_id: UInt32 = 0
    var label_id: UInt32 = 0
    var remixer_id: UInt32 = 0
    var bitrate: UInt32 = 0
    var track_number: UInt32 = 0
    var tempo: UInt32 = 0
    var genre_id: UInt32 = 0
    var album_id: UInt32 = 0
    var artist_id: UInt32 = 0
    var id: UInt32 = 0
    var disc_n: UInt16 = 0
    var play_c: UInt16 = 0
    var year: UInt16 = 0
    var s_depth: UInt16 = 0
    var dur: UInt16 = 0
    var unknown_5: UInt16 = 0
    var color_id: UInt8 = 0
    var rating: UInt8 = 0
    var unknown_6: UInt16 = 0
    var unknown_7: UInt16 = 0
    var offsets: [UInt16] = [] // list of 21 2 byte integers pointing to various strings
    
    var strings: [String] = [] // found at the offsets
}
