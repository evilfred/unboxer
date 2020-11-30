//
//  MusicExtractor.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-03.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Foundation

func extractAlbums(_ pdb: PdbFile) -> [Int:Album] {
    var albums: [Int:Album] = [:]
    
    if let albumTable = pdb.table_headers.first(where: {$0.type == .albums}) {
        for page in albumTable.pages {
            if page.isDataPage && !page.isEmptyPage {
                for row in page.rows {
                    let albumRow = row as! AlbumRow
                    let albumId = Int(albumRow.id)
                    albums[albumId] =
                        Album(
                            id: albumId,
                            artistId: Int(albumRow.artist_id),
                            name: albumRow.name)
                }
            }
        }
    }
    
    return albums
}

func extractArtists(_ pdb: PdbFile) -> [Int:Artist] {
    var artists: [Int: Artist] = [:]
    
    if let artistTable = pdb.table_headers.first(where: {$0.type == .artists}) {
        for page in artistTable.pages {
            if page.isDataPage && !page.isEmptyPage {
                for row in page.rows {
                    let artistRow = row as! ArtistRow
                    let artistId = Int(artistRow.id)
                    
                    artists[artistId] =
                        Artist(
                            id: artistId,
                            name: artistRow.name)
                }
            }
        }
    }
    
    return artists
}

func extractGenres(_ pdb: PdbFile) -> [Int:String] {
    return extractGenresOrLabels(pdb, .genres)
}

func extractLabels(_ pdb: PdbFile) -> [Int:String] {
    return extractGenresOrLabels(pdb, .labels)
}

func extractGenresOrLabels(_ pdb: PdbFile, _ tableType: TableType) -> [Int:String] {
    var results: [Int: String] = [:]
    
    if let table = pdb.table_headers.first(where: {$0.type == tableType}) {
        for page in table.pages {
            if page.isDataPage && !page.isEmptyPage {
                for row in page.rows {
                    let genreOrLabelRow = row as! GenreOrLabelRow
                    let id = Int(genreOrLabelRow.id)
                    results[id] = genreOrLabelRow.name
                }
            }
        }
    }
    
    return results
}
    
func extractKeys(_ pdb: PdbFile) -> [Int:String] {
    var results: [Int: String] = [:]
    
    if let table = pdb.table_headers.first(where: {$0.type == .keys}) {
        for page in table.pages {
            if page.isDataPage && !page.isEmptyPage {
                for row in page.rows {
                    let keyRow = row as! KeyRow
                    let id = Int(keyRow.id)
                    results[id] = keyRow.name
                }
            }
        }
    }
    
    return results
}

func getPtr(_ val: UInt32) -> Int? {
    if val == 0 {
        return nil
    } else {
        return Int(val)
    }
}

func extractArtworks(_ pdb: PdbFile) -> [Int:String] {
    var results: [Int: String] = [:]
    
    if let table = pdb.table_headers.first(where: {$0.type == .artwork}) {
        for page in table.pages {
            if page.isDataPage && !page.isEmptyPage {
                for row in page.rows {
                    let artRow = row as! ArtworkRow
                    let id = Int(artRow.id)
                    results[id] = artRow.path
                }
            }
        }
    }
    
    return results
}

// converts empty strings to nil
func getOptStr(_ val: String) -> String? {
    if val.isEmpty {
        return nil
    } else {
        return val
    }
}

func extractTracks(_ pdb: PdbFile) -> [Int:Track] {
    var tracks: [Int: Track] = [:]
    
    let unknownStrs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 13, 18]
    
    if let trackTable = pdb.table_headers.first(where: {$0.type == .tracks}) {
        for page in trackTable.pages {
            if page.isDataPage && !page.isEmptyPage {
                for row in page.rows {
                    let trackRow = row as! TrackRow
                    let trackId = Int(trackRow.id)
                    
                    tracks[trackId] =
                        Track(
                            id: trackId,
                            keyId: getPtr(trackRow.key_id),
                            originalArtistId: getPtr(trackRow.orig_artist_id),
                            artworkId: getPtr(trackRow.artwork_id),
                            albumId: getPtr(trackRow.album_id),
                            composerId: getPtr(trackRow.composer_id),
                            colorId: getPtr(UInt32(trackRow.color_id)),
                            labelId: getPtr(trackRow.label_id),
                            remixerId: getPtr(trackRow.remixer_id),
                            artistId: getPtr(trackRow.artist_id),
                            genreId: getPtr(trackRow.genre_id),
                            
                            bitmask: trackRow.bitmask,
                            duration: Int(trackRow.dur),
                            bitRate: Int(trackRow.bitrate),
                            sampleRate: Int(trackRow.sample_rate),
                            fileSize: Int(trackRow.file_size),
                            trackNumber: Int(trackRow.track_number),
                            tempo: Int(trackRow.tempo),
                            year: Int(trackRow.year),
                            rating: Int(trackRow.rating),
                            sampleDepth: Int(trackRow.s_depth),
                            discNumber: Int(trackRow.disc_n),
                            playCount: Int(trackRow.play_c),
                            
                            isrc: getOptStr(trackRow.strings[0]),
                            title: getOptStr(trackRow.strings[17]),
                            dateAdded: getOptStr(trackRow.strings[10]),
                            releaseDate: getOptStr(trackRow.strings[11]),
                            remixName: getOptStr(trackRow.strings[12]),
                            analyzePath: getOptStr(trackRow.strings[14]),
                            analyzeDate: getOptStr(trackRow.strings[15]),
                            comment: getOptStr(trackRow.strings[16]),
                            filename: getOptStr(trackRow.strings[19]),
                            filePath: getOptStr(trackRow.strings[20]))
                    for unindex in unknownStrs {
                        let unstr = trackRow.strings[unindex]
                        if (!unstr.isEmpty) {
                            //print("Unknown str at \(unindex): \(unstr)")
                        }
                    }
                    
                }
            }
        }
    }
    
    return tracks
}

func extractPlaylists(_ pdb: PdbFile) -> [Playlist] {
    
    var entryMap: [UInt32: Set<PlaylistEntryRow>] = [:]
    if let entryTable = pdb.table_headers.first(where: {$0.type == .playlist_entries}) {
        for page in entryTable.pages {
            for row in page.rows {
                let entryRow = row as! PlaylistEntryRow
                
                if var set = entryMap[entryRow.playlist_id] {
                    set.insert(entryRow)
                    entryMap[entryRow.playlist_id] = set // TODO: why is this needed?
                } else {
                    var newSet: Set<PlaylistEntryRow> = Set()
                    newSet.insert(entryRow)
                    entryMap[entryRow.playlist_id] = newSet
                }
            }
        }
    }
    
    var playlists: [Playlist] = []
    if !entryMap.isEmpty {
        if let treeTable = pdb.table_headers.first(where: {$0.type == .playlist_tree}) {
            
            for page in treeTable.pages {
                for row in page.rows {
                    let treeRow = row as! PlaylistTreeRow
                    
                    var trackIds:[Int] = []
                    if let entries: Set<PlaylistEntryRow> = entryMap[treeRow.id] {
                        trackIds = Array(entries).sorted {$0.entry_index < $1.entry_index}.map {Int($0.track_id)}
                    }
                    
                    playlists.append(
                        Playlist(
                            id: Int(treeRow.id),
                            name: treeRow.name,
                            sortOrder: treeRow.sort_order,
                            isFolder: treeRow.is_folder,
                            children: [], // TODO: add hierarchy support
                            tracks: trackIds))
                }
            }
        }
    }
    
    return playlists
}
