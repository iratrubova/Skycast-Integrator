//
//  Item.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 24.03.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
