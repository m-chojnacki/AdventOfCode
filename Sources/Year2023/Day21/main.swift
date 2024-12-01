//
//  main.swift
//  Day21
//
//  Created by Marcin Chojnacki on 21/12/2023.
//

import Foundation
import Shared

let example = #"""
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
"""#.lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

struct Input {
    let map: [[Bool]]
    let start: Coordinates

    subscript(row: Int, col: Int) -> Bool {
        var repeatedRow = row % map.count

        if repeatedRow < 0 {
            repeatedRow = map.count + repeatedRow
        }

        var repeatedCol = col % map[repeatedRow].count

        if repeatedCol < 0 {
            repeatedCol = map[repeatedRow].count + repeatedCol
        }

        return map[repeatedRow][repeatedCol]
    }
}

func parseInput(_ input: [String]) throws -> Input {
    let array = input.map(Array.init)

    guard let row = array.firstIndex(where: { $0.contains("S") }),
          let col = array[row].firstIndex(of: "S")
    else { throw Error("No starting position") }

    return Input(map: array.map { $0.map { $0 == "#" } }, start: Coordinates(row, col))
}

let input = try parseInput(lines)

func partOne() throws -> Int {
    var start: Set<Coordinates> = [input.start]

    for _ in 0..<64 {
        start = Set(start.flatMap {
            [
                input.map[safe: $0.row - 1]?[safe: $0.col] == false ? Coordinates($0.row - 1, $0.col) : nil,
                input.map[safe: $0.row + 1]?[safe: $0.col] == false ? Coordinates($0.row + 1, $0.col) : nil,
                input.map[safe: $0.row]?[safe: $0.col - 1] == false ? Coordinates($0.row, $0.col - 1) : nil,
                input.map[safe: $0.row]?[safe: $0.col + 1] == false ? Coordinates($0.row, $0.col + 1) : nil,
            ].compactMap { $0 }
        })
    }

    return start.count
}

func partTwo() throws -> Int {
    return 0
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
