//
//  ComposerView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI


struct ComposerView: View {
    
    @EnvironmentObject private var userData: UserData
    
    var composer: Artist
    
    var body: some View {
        
        let tracks = userData.catalog!.tracks.values.filter { $0.composerId == composer.id }
        
        return VStack(alignment: .leading) {
            Divider()
        
            Text(composer.name).font(.headline)
            
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
