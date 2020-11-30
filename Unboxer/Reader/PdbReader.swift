//
//  PdbReader.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-02.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Foundation

func readPdbFile(filename: String) -> PdbFile? {
    if let data = NSData(contentsOfFile: filename) {
        var pdb = PdbFile()
        var index = 0
        
        pdb.blank = readUInt32(data as Data, &index)
        assert(pdb.blank == 0, "file start is not blank")
        pdb.len_page = readUInt32(data as Data, &index)
        pdb.num_tables = readUInt32(data as Data, &index)
        pdb.next_unused_page = readUInt32(data as Data, &index)
        pdb.unknown = readUInt32(data as Data, &index)
        pdb.sequence = readUInt32(data as Data, &index)
        pdb.more_blank = readUInt32(data as Data, &index)
        assert(pdb.more_blank == 0, "file more blank is not blank")
        
        pdb.table_headers = [TableHeader]()
        pdb.table_headers.reserveCapacity(Int(pdb.num_tables))
        for _ in 0..<pdb.num_tables {
            pdb.table_headers.append(readTableHeader(data as Data, &index, pdb.len_page))
        }
        
        return pdb
    }
    
    return nil;
}

func readTableHeader(_ data: Data, _ index: inout Int, _ pageLength: UInt32) -> TableHeader {
    var header = TableHeader()
    
    header.type = readTableType(data, &index)
    header.empty_c = readUInt32(data as Data, &index)
   // print("type: \(header.type!) empty c: \(header.empty_c)")
    header.first_page = readUInt32(data as Data, &index)
    header.last_page = readUInt32(data as Data, &index)
    
    header.pages = [TablePage]()
    
    var pageIndex = header.first_page
    while true {
        let page: TablePage = readTablePage(data, pageIndex, pageLength)
        header.pages.append(page)
        
        if (pageIndex == header.last_page) {
            break
        }
        
        pageIndex = page.next_page
    }
    
    return header;
}

func readTablePage(_ data: Data, _ pageIndex: UInt32, _ pageLength: UInt32) -> TablePage {
    var tablePage = TablePage()
    
    let base: Int = Int(pageIndex) * Int(pageLength)
    var index = base
    tablePage.blank = readUInt32(data, &index)
    assert(tablePage.blank == 0, "page start is not blank")
    tablePage.pageIndex = readUInt32(data, &index)
    assert(tablePage.pageIndex == pageIndex, "page index does not match")
    tablePage.type = readTableType(data, &index)
    tablePage.next_page = readUInt32(data, &index)
    tablePage.unknown_1 = readUInt32(data, &index)
    tablePage.unknown_2 = readUInt32(data, &index)
    tablePage.num_rows_small = readUInt8(data, &index)
    tablePage.unknown_3 = readUInt8(data, &index)
    tablePage.unknown_4 = readUInt8(data, &index)
    tablePage.page_flags = readUInt8(data, &index)
    tablePage.free_size = readUInt16(data, &index)
    tablePage.used_size = readUInt16(data, &index)
    tablePage.unknown_5 = readUInt16(data, &index)
    tablePage.num_rows_large = readUInt16(data, &index)
    tablePage.unknown_6 = readUInt16(data, &index)
    tablePage.unknown_7 = readUInt16(data, &index)
    
   // print("Table page \(tablePage.type!) \(tablePage.unknown_1) \(tablePage.unknown_2) \(tablePage.unknown_3) \(tablePage.unknown_4) \(tablePage.unknown_5) \(tablePage.unknown_6) \(tablePage.unknown_7) ")
    
    tablePage.isDataPage = (tablePage.page_flags & 0x40) == 0
    tablePage.isEmptyPage = tablePage.pageIndex == 0 && tablePage.unknown_6 == 0
    

    if (tablePage.num_rows_large != 0x1fff
        && tablePage.num_rows_large > tablePage.num_rows_small) {
        tablePage.numRows = tablePage.num_rows_large
    } else {
        tablePage.numRows = UInt16(tablePage.num_rows_small)
    }

    if (tablePage.type == .tracks) {
        print("Tracks page \(tablePage.pageIndex) isData: \(tablePage.isDataPage) isEmpty: \(tablePage.isEmptyPage) row count: \(tablePage.numRows)")
    }
    
    if (tablePage.isDataPage && !tablePage.isEmptyPage) {
        
        // Read row headers, starting at the end.
        tablePage.row_headers = [RowHeader]()
        tablePage.rows = [Any]()
        
        let endIndex = (Int(pageIndex) + 1) * Int(pageLength)
        let numGroups = (tablePage.numRows - 1) / 16 + 1
        for i in 0..<numGroups {
            var rowHeader = RowHeader()
            
            // to find current presence flags:
            // - go to end of the entire page
            // - move back 36 for each processed group
            // - move back another 4 to read the presence flags
            let presenceIndex = endIndex - (Int(i) * 34) - 4
            
            var dummyIndex = presenceIndex
            rowHeader.presence_flags = readUInt16(data, &dummyIndex)
            // note: there's another mystery 2-byte value right at the end
            
            rowHeader.offsets = [UInt16]()
            
            for j in 0..<16 {
                if (rowHeader.presence_flags & (1 << j) > 0) {
                    var offsetIndex = presenceIndex - 2 * (j+1)
                    rowHeader.offsets.append(readUInt16(data, &offsetIndex))
                }
            }
            
            tablePage.row_headers.append(rowHeader)
            
            // Read rows
            let rowBase = base + 0x28
            for rowOffset in rowHeader.offsets {
                let rowAddr = rowBase + Int(rowOffset)
                
                if let pageType = tablePage.type {
                    var row:Any? = nil
                    if pageType == TableType.albums {
                        row = readAlbumRow(data, rowAddr)
                    } else if pageType == .artists {
                        row = readArtistRow(data, rowAddr)
                    } else if pageType == .artwork {
                        row = readArtworkRow(data, rowAddr)
                    } else if pageType == .tracks {
                        row = readTrackRow(data, rowAddr)
                    } else if pageType ==  .genres {
                        row = readGenreOrLabelRow(data, rowAddr)
                    } else if pageType == .labels {
                        row = readGenreOrLabelRow(data, rowAddr)
                    } else if pageType == .keys {
                        row = readKeyRow(data, rowAddr)
                    } else if pageType == .colors {
                        row = readColorRow(data, rowAddr)
                    } else if pageType == .playlist_tree {
                        row = readPlaylistTreeRow(data, rowAddr)
                    } else if pageType == .playlist_entries {
                        row = readPlaylistEntryRow(data, rowAddr)
                    } else if pageType == .history {
                        //print("Found history row at \(rowAddr)")
                    } else if pageType == .columns {
                        if (rowOffset != 0x07FF) { // is this for all table/row types?
                            // and why is "MATCHING" colum never hit?
                            row = readColumnRow(data, rowAddr)
                        }
                    }
                    
                    if row != nil {
                        tablePage.rows.append(row!)
                    }
                }
            }
        }
    }
    
    return tablePage
}

func readColumnRow(_ data: Data, _ index: Int) -> ColumnRow {
    var curr = index
    
    var row = ColumnRow()
    row.id = readUInt16(data, &curr)
    row.index = readUInt16(data, &curr)
    row.name = readString(data, curr) ?? ""
    
    return row
}

func readColorRow(_ data: Data, _ index: Int) -> ColorRow {
    var curr = index
    
    var row = ColorRow()
    row.unknown_1 = readUInt32(data, &curr)
    row.unknown_2 = readUInt8(data, &curr)
   
    let typeInt = readUInt16(data, &curr)
    row.id = ColorType.init(rawValue: Int(typeInt))

    row.unknown_3 = readUInt8(data, &curr)
    row.name = readString(data, curr) ?? ""
    
    return row
}

func readPlaylistTreeRow(_ data: Data, _ index: Int) -> PlaylistTreeRow {
    var curr = index
    
    var row = PlaylistTreeRow()
    row.parent_id = readUInt32(data, &curr)
    row.unknown = readUInt32(data, &curr)
    row.sort_order = readUInt32(data, &curr)
    row.id = readUInt32(data, &curr)
    row.raw_is_folder = readUInt32(data, &curr)
    row.name = readString(data, curr) ?? ""
    
    row.is_folder = row.raw_is_folder > 0
    
    return row
}

func readPlaylistEntryRow(_ data: Data, _ index: Int) -> PlaylistEntryRow {
    var curr = index
    
    var row = PlaylistEntryRow()
    row.entry_index = readUInt32(data, &curr)
    row.track_id = readUInt32(data, &curr)
    row.playlist_id = readUInt32(data, &curr)
    
    return row
}

func readArtworkRow(_ data: Data, _ index: Int) -> ArtworkRow {
    var curr = index
    
    var artwork = ArtworkRow()
    artwork.id = readUInt32(data, &curr)
    if let path = readString(data, curr) {
        artwork.path = path
    }
    
    return artwork
}

func readAlbumRow(_ data: Data, _ index: Int) -> AlbumRow {
    var curr = index
    
    var album = AlbumRow()
    album.unknown_1 = readUInt16(data, &curr)
    album.index_shift = readUInt16(data, &curr)
    album.unknown_2 = readUInt32(data, &curr)
    album.artist_id = readUInt32(data, &curr)
    album.id = readUInt32(data, &curr)
    album.unknown_3 = readUInt32(data, &curr)
    album.unknown_4 = readUInt8(data, &curr)
    album.ofs_name = readUInt8(data, &curr)
    
    let offset = index + Int(album.ofs_name)
    
    if let name = readString(data, offset) {
        album.name = name
    }
    
    /*
    if album.artist_id == 0 {
        print("Got 0 artist id for \(album.name)")
    }*/
    
    return album
}

func readArtistRow(_ data: Data, _ index: Int) -> ArtistRow {
    var curr = index
    
    var artist = ArtistRow()
    artist.subtype = readUInt16(data, &curr)
    artist.index_shift = readUInt16(data, &curr)
    artist.id = readUInt32(data, &curr)
    artist.unknown_1 = readUInt8(data, &curr)
    
    artist.ofs_name_near = readUInt8(data, &curr)
    
    var offset = 0
    if (artist.subtype == 0x0064) {
        artist.ofs_name_far = readUInt16(data, &curr)
        offset = index + Int(artist.ofs_name_far)
    } else {
        offset = index + Int(artist.ofs_name_near)
    }

    if let name = readString(data, offset) {
        artist.name = name
    }
    
    return artist
}

func readTrackRow(_ data: Data, _ index: Int) -> TrackRow {
    var curr = index
    
    var row = TrackRow()
    row.unknown_1 = readUInt16(data, &curr)
    row.index_shift = readUInt16(data, &curr)
    row.bitmask = readUInt32(data, &curr)
    row.sample_rate = readUInt32(data, &curr)
    row.composer_id = readUInt32(data, &curr)
    row.file_size = readUInt32(data, &curr)
    row.unknown_2 = readUInt32(data, &curr)
    row.unknown_3 = readUInt16(data, &curr)
    row.unknown_4 = readUInt16(data, &curr)
    row.artwork_id = readUInt32(data, &curr)
    row.key_id = readUInt32(data, &curr)
    row.orig_artist_id = readUInt32(data, &curr)
    row.label_id = readUInt32(data, &curr)
    row.remixer_id = readUInt32(data, &curr)
    row.bitrate = readUInt32(data, &curr)
    row.track_number = readUInt32(data, &curr)
    row.tempo = readUInt32(data, &curr)
    row.genre_id = readUInt32(data, &curr)
    row.album_id = readUInt32(data, &curr)
    row.artist_id = readUInt32(data, &curr)
    row.id = readUInt32(data, &curr)
    row.disc_n = readUInt16(data, &curr)
    row.play_c = readUInt16(data, &curr)
    row.year = readUInt16(data, &curr)
    row.s_depth = readUInt16(data, &curr)
    row.dur = readUInt16(data, &curr)
    row.unknown_5 = readUInt16(data, &curr)
    row.color_id = readUInt8(data, &curr)
    row.rating = readUInt8(data, &curr)
    row.unknown_6 = readUInt16(data, &curr)
    row.unknown_7 = readUInt16(data, &curr)
    
    row.offsets = [UInt16]()
    for _ in 0..<21 {
        row.offsets.append(readUInt16(data, &curr))
    }
    
    row.strings = [String]()
    var q = 0
    for offset in row.offsets {
        let strOffset = index + Int(offset)
        let str = readString(data, strOffset) ?? ""
        row.strings.append(str)
        q += 1
    }
    
    let indexStr = String(format: "%X", index)
    print("At \(indexStr) found track \(row.strings[17])")
    //print("Track title: \(row.strings[17])")
    
    return row
}

func readGenreOrLabelRow(_ data: Data, _ index: Int) -> GenreOrLabelRow {
    var curr = index
    
    var row = GenreOrLabelRow()
    row.id = readUInt32(data, &curr)
    if let name = readString(data, curr) {
        row.name = name
    }
    
    return row
}

func readKeyRow(_ data: Data, _ index: Int) -> KeyRow {
    var curr = index
    
    var row = KeyRow()
    row.id = readUInt32(data, &curr)
    row.id2 = readUInt32(data, &curr)
    if let name = readString(data, curr) {
        row.name = name
    }
    
    return row
}

func readTableType(_ data: Data, _ index: inout Int) -> TableType {
    let typeInt: UInt32 = readUInt32(data, &index)
    return TableType.init(rawValue: Int(typeInt))!
}

func readUInt8(_ data: Data, _ index: inout Int) -> UInt8 {
    let result = data[index]
    index += 1
    return result
}

func readUInt16(_ data: Data, _ index: inout Int) -> UInt16 {
    let count = 2
    
    let range = index..<(index+count)
    let bytes: Data = data.subdata(in: range);
    
    let result: UInt16 = bytes.withUnsafeBytes{$0.load(as: UInt16.self)};
    //var result = UInt8(0)
    //withUnsafeMutableBytes(of: &result) {bytes.copyBytes(to: $0)}
    
    index += count;
    return result;
}

func readUInt32(_ data: Data, _ index: inout Int) -> UInt32 {
    let count = 4
    
    let range = index..<(index+count)
    let bytes: Data = data.subdata(in: range);
    
    let result: UInt32 = bytes.withUnsafeBytes{$0.load(as: UInt32.self)};
    //var result = UInt8(0)
    //withUnsafeMutableBytes(of: &result) {bytes.copyBytes(to: $0)}
    
    index += count;
    return result;
}

func readString(_ data: Data, _ index: Int) -> String? {
    let lengthKind = data[index]
    
    var strOut:String? = nil
    if (lengthKind == 0x40) {
        
        // Long ASCII
        var seek = index + 1
        let length = Int(readUInt16(data, &seek))
        
        let sourceData = data.subdata(in: seek..<(seek+length))
        
        strOut = String(data: sourceData, encoding: .utf8)
    } else if (lengthKind == 0x90) {
        
        var seek = index + 1
        let length = Int(readUInt16(data, &seek))
        
        seek += 1 // 00 indicates little endian
        
        if (data[seek] == 0x03) {
            // Special case ASCII string for ISRC
            seek += 1
            let sourceData = data.subdata(in: seek..<(seek+length))
            
            strOut = String(data: sourceData, encoding: .utf8)
        } else {
            // UTF-16 string
            strOut = String(data: data.subdata(in: seek..<(seek+length-4)), encoding: .utf16LittleEndian)
        }
    } else {
        
        // Short ASCII
        let length = (Int(lengthKind) - 1) / 2 - 1
        let sourceData = data.subdata(in: (index + 1)..<(index + 1 + length))
        strOut = String(data: sourceData, encoding: .utf8)
    }
    
    
    return strOut
}
