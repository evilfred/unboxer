//
//  PlaylistEntryView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct PlaylistEntryView: View {
       
    @EnvironmentObject private var userData: UserData
    
    var track: Track
    
    var body: some View {
        
        var artistName = "Missing artist"
        if let realArtistId = track.artistId {
            if let artist = userData.catalog!.artists[realArtistId] {
                artistName = artist.name
            }
        }
        
        let title = track.title ?? "Missing title"
        
        return VStack(alignment: .leading) {
            HStack {
                HStack {
                    Text(artistName)
                    Spacer()
                }.frame(width:250)
                
                HStack {
                    Text(title)
                    Spacer()
                }.frame(width:250)
                
                if (track.artworkId != nil) {
                    ArtworkView(artworkId: track.artworkId!)
                }
                
                Spacer()
            }
        }.frame(width: 700)
    }
}

