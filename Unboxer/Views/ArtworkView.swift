//
//  ArtworkView.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-04.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct ArtworkView: View {
    
    @EnvironmentObject private var userData: UserData
    
    var artworkId: Int
    
    func getImage() -> Image? {
        let catalog = self.userData.catalog!
        
        if let artworkPath = catalog.artworks[artworkId] {
            let fullPath = "\(catalog.basePath)\(artworkPath)"
            if let nsImage = NSImage(contentsOfFile:fullPath) {
                return Image(nsImage:nsImage)
            }
        }
        
        return nil
    }
    
    var body: some View {
        let innerView: Image? = getImage()
        
        return VStack {
            if innerView != nil {
                innerView!
            }
            Spacer()
        }.frame(width:120)
    }
}
