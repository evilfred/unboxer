//
//  MiniTrack.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct TrackMini: View {
       
    var track: Track
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    Text(track.title ?? "Missing title")
                    Spacer()
                }.frame(width:125)
                
                if (track.artworkId != nil) {
                    ArtworkView(artworkId: track.artworkId!)
                }
                
                Spacer()
            }
        }.frame(width: 250)
    }
}

/*
struct TrackMini_Previews: PreviewProvider {
    static var previews: some View {
        TrackMini(track: Track(title: "Test track", artworkId: nil))
    }
}
*/
