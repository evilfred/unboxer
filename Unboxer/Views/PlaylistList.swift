//
//  PlaylistList.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct PlaylistList: View {
        
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        let orderedPlaylists = Array(self.userData.catalog!.playlists).sorted {$0.name < $1.name }
               
        return List(orderedPlaylists) { playlist in
            PlaylistView(playlist: playlist)
        }
    }
}
