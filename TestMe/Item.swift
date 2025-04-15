//
//  Item.swift
//  TestMe
//
//  Created by Анастасия Берчик on 4/15/25.
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
