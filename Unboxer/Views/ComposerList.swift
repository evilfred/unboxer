//
//  AlbumView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-05.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct ComposerList: View {
    
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        let composers = Set(Array(self.userData.catalog!.tracks.values).filter {$0.composerId != nil}.map {$0.composerId})
        let orderedComposers = Array(self.userData.catalog!.artists.values).filter {composers.contains($0.id)}.sorted {$0.name < $1.name }
                  
        return List(orderedComposers) { composer in
            ComposerView(composer: composer)
        }
    }
}
