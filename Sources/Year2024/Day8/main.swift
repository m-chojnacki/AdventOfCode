//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 08/12/2024.
//

import Foundation
import Shared

let input = PackageResources.input_txt.string
//let input = """
//............
//........0...
//.....0......
//.......0....
//....0.......
//......A.....
//............
//............
//........A...
//.........A..
//............
//............
//"""

let map = input.lines().map(Array.init)
let coords = map.indices
    .flatMap { row in
        map[row].indices.compactMap { col in
            let item = map[row][col]
            if item != "." {
                return (item, Coordinates(row, col))
            } else {
                return nil
            }
        }
    }
    .reduce(into: [Character: [Coordinates]]()) { dict, pair in
        if dict[pair.0] == nil {
            dict[pair.0] = []
        }
        dict[pair.0]?.append(pair.1)
    }

func generateCombinations<T>(_ current: [T], _ remaining: [T], _ length: Int, _ block: ([T]) -> Void) {
    if current.count == length {
        block(current)
        return
    }

    for (index, element) in remaining.enumerated() {
        let newRemaining = Array(remaining[(index + 1)...])
        generateCombinations(current + [element], newRemaining, length, block)
    }
}

func countOfAntinodes(_ antinodes: (Coordinates, Coordinates) -> [Coordinates]) -> Int {
    var antinodesSet = Set<Coordinates>()

    for (_, value) in coords {
        generateCombinations([], Array(value.indices), 2) { index in
            for antinode in antinodes(value[index[0]], value[index[1]]) {
                antinodesSet.insert(antinode)
            }
        }
    }

    return antinodesSet.count
}

func partOne() -> Int {
    countOfAntinodes { first, second in
        let diff = Coordinates(second.row - first.row, second.col - first.col)

        return [
            Coordinates(first.row - diff.row, first.col - diff.col),
            Coordinates(second.row + diff.row, second.col + diff.col)
        ].filter {
            $0.row >= 0 && $0.row < map.count && $0.col >= 0 && $0.col < map[0].count
        }
    }
}

func partTwo() -> Int {
    countOfAntinodes { first, second in
        let diff = Coordinates(second.row - first.row, second.col - first.col)

        var result = [Coordinates]()

        var current = first
        while current.row >= 0 && current.row < map.count && current.col >= 0 && current.col < map[0].count {
            result.append(current)
            current = Coordinates(current.row - diff.row, current.col - diff.col)
        }

        current = second
        while current.row >= 0 && current.row < map.count && current.col >= 0 && current.col < map[0].count {
            result.append(current)
            current = Coordinates(current.row + diff.row, current.col + diff.col)
        }

        return result
    }
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
