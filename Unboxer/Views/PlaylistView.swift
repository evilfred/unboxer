//
//  PlaylistView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct PlaylistView: View {
    
    @EnvironmentObject private var userData: UserData
    
    var playlist: Playlist
    
    var body: some View {
        
        let allTracks = userData.catalog!.tracks
        let tracks = playlist.tracks.map({allTracks[$0]!})
        
        return VStack(alignment: .leading) {
            Divider()
        
            Text(playlist.name).font(.headline)
            
            ForEach(tracks) { track in
                PlaylistEntryView(track: track)
            }
        }.padding()
    }
}
