//
//  TrackView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-04.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct TrackView: View {
    @EnvironmentObject private var userData: UserData
    
    var track: Track
    
    func getAlbumStr(_ albumId: Int?) -> String {
        if let realAlbumId = albumId {
            if let album = self.userData.catalog!.albums[realAlbumId] {
                return album.name
            } else {
                return "Missing album \(realAlbumId)"
            }
        } else {
            return ""
        }
    }
    
    func getArtistStr(_ artistId: Int?) -> String {
        if let realArtistId = artistId {
            if let artist = self.userData.catalog!.artists[realArtistId] {
                return artist.name
            } else {
                return "Missing artist \(realArtistId)"
            }
        } else {
            return ""
        }
    }
    
    func getGenreStr(_ genreId: Int?) -> String {
       if let realGenreId = genreId {
           if let genre = self.userData.catalog!.genres[realGenreId] {
               return genre
           } else {
               return "Missing genre \(realGenreId)"
           }
       } else {
           return ""
       }
    }
    
    func getLabelStr(_ labelId: Int?) -> String {
        if let realLabelId = labelId {
            if let label = self.userData.catalog!.labels[realLabelId] {
                return label
            } else {
                return "Missing label \(realLabelId)"
            }
        } else {
            return ""
        }
    }
    
    func getKeyStr(_ keyId: Int?) -> String {
        if let realKeyId = keyId {
            if let key = self.userData.catalog!.keys[realKeyId] {
                return key
            } else {
                return "Missing key \(realKeyId)"
            }
        } else {
            return ""
        }
    }
    
    func getTempoStr(_ tempo: Int) -> String {
        let bpm = Double(tempo) / 100.0
        return String(format: "%.2f BPM", bpm)
    }
    
    func getDurationStr(_ duration: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(duration))!
    }
    
    func getSizeStr(_ bytes: Int) -> String {
        let megaBytes = Double(bytes) / 1024.0 / 1024.0
        return String(format: "%.2f MB", megaBytes)
    }
    
    var body: some View {
        
        var titleStr = ""
        if (track.title != nil) {
            titleStr = track.title!
        }
        
        var artistStr = ""
        if (track.artistId != nil) {
            artistStr = "  /  \(self.getArtistStr(track.artistId))"
        }
        
        var albumStr = ""
        if (track.albumId != nil) {
            albumStr = "  /  \(self.getAlbumStr(track.albumId))"
        }
        
        return VStack(alignment: .leading) {
            Divider()
            
            Text("\(titleStr)\(artistStr)\(albumStr)")
                .fontWeight(.bold)
            
            HStack {
                if (track.genreId != nil) {
                    Text(self.getGenreStr(track.genreId))
                }
                
                Text(self.getTempoStr(track.tempo))
                Text(self.getDurationStr(track.duration))
                Text("Plays: \(track.playCount)")
                
                if (track.keyId != nil) {
                    Text("Key: \(self.getKeyStr(track.keyId))")
                }
                
                if (track.rating != 0) {
                    Text("Rating: \(track.rating)")
                }
            }
            
            HStack(alignment: .top) {
                VStack {
                    if (track.artworkId != nil) {
                        ArtworkView(artworkId: track.artworkId!)
                    }
                }
                .frame(width: 120.0)
                
                HStack {
                    VStack(alignment: .leading) {
                        if (track.isrc != nil) {
                           Text("ISRC: \(track.isrc!)")
                        }
                        
                        if (track.labelId != nil) {
                            Text("Label: \(self.getLabelStr(track.labelId))")
                        }
                    
                        if (track.composerId != nil) {
                            Text("Composer: \(self.getArtistStr(track.composerId))")
                        }
                        if (track.originalArtistId != nil) {
                            Text("Original Artist: \(self.getArtistStr(track.originalArtistId))")
                        }
                        if (track.remixerId != nil) {
                            Text("Remixer: \(self.getArtistStr(track.remixerId))")
                        }
                    }
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        if (track.filename != nil) {
                            Text(track.filename!)
                        }
                        Text(track.filePath ?? "")
                        Text(self.getSizeStr(track.fileSize))
                    }
                    Spacer()
                }
            }
        }.padding()
    }
}
