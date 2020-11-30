//
//  UserData.swift
//  Unboxer
//
//  Created by Chris Seymour on 2020-07-02.
//  Copyright © 2020 Chris Seymour. All rights reserved.
//

import Combine
import SwiftUI

final class UserData: ObservableObject {
    @Published var catalog: MusicCatalog? = nil
}
