//
//  PdbLoader.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-04.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import SwiftUI

struct PdbLoader: View {
    
    @EnvironmentObject private var userData: UserData
    
    @State private var loading = false
    
    let DEFAULTS_PDB_URL_KEY = "pdbUrl"
    
    init() {
        /*if let pdbUrlStr = UserDefaults.standard.object(forKey: DEFAULTS_PDB_URL_KEY) as! String? {
            let initialUrl = URL(string: pdbUrlStr)
            loadPdb(initialUrl)
        }*/
    }
    
    func loadPdb(_ pdbUrl: URL)  {
        DispatchQueue.global().async {
            if let pdb = readPdbFile(filename: pdbUrl.path) {
                let basePath = self.getBasePath(pdbUrl)
                let catalog = MusicCatalog(basePath: basePath, pdb: pdb)
                
                UserDefaults.standard.set(pdbUrl.absoluteString, forKey: self.DEFAULTS_PDB_URL_KEY)
                
                DispatchQueue.main.async {
                    self.userData.catalog = catalog
                }
            }
        }
    }

    func getBasePath(_ url: URL) -> String {
        
        // This is fragile
        // Skip back over 3 path components: PIONEER/rekordbox/blah.pdb
        let cmpCount = url.pathComponents.count
        let baseCmps = Array(url.pathComponents[..<(cmpCount - 3)])
        return NSString.path(withComponents:baseCmps)
    }
    
    var body: some View {
        if (self.loading) {
            return AnyView(Text("Loading...")
                .font(.title))
        } else {
            return AnyView(
              Button(action: {
               let dialog = NSOpenPanel();
               dialog.title                   = "Choose a .pdb file";
               dialog.showsResizeIndicator    = true;
               dialog.showsHiddenFiles        = false;
               dialog.canChooseDirectories    = true;
               dialog.canCreateDirectories    = true;
               dialog.allowsMultipleSelection = false;
               dialog.allowedFileTypes        = ["pdb"];

               if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                   if let result = dialog.url {
                       self.loading = true
                       self.loadPdb(result)
                   }
               }
           }) {
            Text("Load PDB")
            })
        }
    }
}
