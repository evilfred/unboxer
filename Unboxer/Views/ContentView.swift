//
//  ContentView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-02.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Foundation
import SwiftUI

struct ContentView: View {
     
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        VStack {
            if (self.userData.catalog == nil) {
                PdbLoader()
            } else {
                TabView {
                    PlaylistList().tabItem {
                        Text("Playlists")
                    }
                    TrackList().tabItem {
                        Text("Tracks")
                    }
                    ArtistList().tabItem {
                        Text("Artists")
                    }
                    ComposerList().tabItem {
                        Text("Composers")
                    }
                }
            }
        }
        .frame(width: 800.0, height: 800.0)
    }
}
