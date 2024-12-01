//
//  UInt8ArrayExtension.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 01/12/2023.
//

import Foundation

public extension [UInt8] {
    var string: String {
        String(data: Data(self), encoding: .utf8)!
    }
}
