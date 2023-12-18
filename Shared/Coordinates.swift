//
//  Coordinates.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 18/12/2023.
//

struct Coordinates: Hashable, CustomStringConvertible {
    let row: Int
    let col: Int

    static var zero = Coordinates(0, 0)

    var description: String {
        "(\(row), \(col))"
    }

    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
}
