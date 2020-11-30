//
//  ArtistView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct ArtistView: View {
    
    @EnvironmentObject private var userData: UserData
    
    var artist: Artist
    
    var body: some View {
        
        let albums = userData.catalog!.albums.values.filter { $0.artistId == artist.id }
        let tracks = userData.catalog!.tracks.values.filter { $0.artistId == artist.id }
        
        return VStack(alignment: .leading) {
            Divider()
        
            Text(artist.name).font(.headline)
            
            // todo: put tracks under albums
            
            if (albums.count > 0) {
                Text("Albums")
                    .fontWeight(.bold)
                VStack {
                    ForEach(albums) { album in
                        HStack {
                            Text(album.name)
                            Spacer()
                        }
                    }
                }
            }
            
            Text("Tracks")
                .fontWeight(.bold)
            HStack {
                ForEach(tracks) { track in
                    TrackMini(track: track)
                }
                Spacer()
            }
        }.padding()
    }
}
