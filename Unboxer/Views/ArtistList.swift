//
//  ArtistList.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct ArtistList: View {
    
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        let performers = Set(Array(self.userData.catalog!.tracks.values).filter {$0.artistId != nil}.map {$0.artistId})
        let orderedArtists = Array(self.userData.catalog!.artists.values).filter {performers.contains($0.id)}.sorted {$0.name < $1.name }
               
        return List(orderedArtists) { artist in
            ArtistView(artist:artist)
        }
    }
}
