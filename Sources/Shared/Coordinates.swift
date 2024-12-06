//
//  Coordinates.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 18/12/2023.
//

public struct Coordinates: Hashable, Sendable, CustomStringConvertible {
    public var row: Int
    public var col: Int

    public static let zero = Coordinates(0, 0)

    public var description: String {
        "(\(row), \(col))"
    }

    public init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
}
