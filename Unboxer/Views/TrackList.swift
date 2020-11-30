//
//  TrackList.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-04.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct TrackList: View {
    
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        
        let orderedTracks = Array(self.userData.catalog!.tracks.values).sorted {
            $0.title == nil
                || ($1.title != nil && $0.title! < $1.title!) }
        
        return List(orderedTracks) { track in
            TrackView(track:track)
        }
    }
}
