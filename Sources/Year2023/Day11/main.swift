//
//  main.swift
//  Day11
//
//  Created by Marcin Chojnacki on 11/12/2023.
//

import Foundation
import Algorithms
import Shared

let example = """
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

func partOne(expansion: Int = 2) throws -> Int {
    let galaxies = lines.map { $0.map { $0 == "#" } }
    let transposedGalaxies = galaxies.transposed()

    let emptyRows = galaxies.indices.filter { galaxies[$0].allSatisfy { !$0 } }
    let emptyCols = transposedGalaxies.indices.filter { transposedGalaxies[$0].allSatisfy { !$0 } }

    let indicesOfGalaxies = galaxies.enumerated().flatMap { rowIndex, row in
        row.enumerated().compactMap { colIndex, col in
            col ? Coordinates(rowIndex, colIndex) : nil
        }
    }

    func distanceBetween(_ a: Coordinates, _ b: Coordinates, expansion: Int) -> Int {
        let emptyRowsInside = Set(min(a.row, b.row)...max(a.row, b.row)).intersection(emptyRows)
        let emptyColsInside = Set(min(a.col, b.col)...max(a.col, b.col)).intersection(emptyCols)

        let expandedRows = emptyRowsInside.count * (expansion - 1)
        let expandedCols = emptyColsInside.count * (expansion - 1)

        return abs(a.row - b.row) + expandedRows + abs(a.col - b.col) + expandedCols
    }

    return indicesOfGalaxies.combinations(ofCount: 2)
        .map { distanceBetween($0[0], $0[1], expansion: expansion) }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    try partOne(expansion: 1000000)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
