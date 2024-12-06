//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 06/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""

let map = input.lines().map(Array.init)

enum Direction: Hashable {
    case left
    case right
    case up
    case down
}

struct Tuple<A: Hashable, B: Hashable>: Hashable {
    var a: A
    var b: B
}

guard let row = map.firstIndex(where: { $0.contains("^") }),
      let col = map[row].firstIndex(of: "^")
else { fatalError("No security guard!") }

let initial = Coordinates(row, col)

func partOne() -> Int {
    var direction = Direction.up
    var position = initial
    var visited = Set<Coordinates>()

    while position.row >= 0 && position.row < map.count && position.col >= 0 && position.col < map[0].count {
        visited.insert(position)

        switch direction {
        case .left:
            if map[safe: position.row]?[safe: position.col - 1] == "#" {
                direction = .up
                position.row -= 1
            } else {
                position.col -= 1
            }
        case .right:
            if map[safe: position.row]?[safe: position.col + 1] == "#" {
                direction = .down
                position.row += 1
            } else {
                position.col += 1
            }
        case .up:
            if map[safe: position.row - 1]?[safe: position.col] == "#" {
                direction = .right
                position.col += 1
            } else {
                position.row -= 1
            }
        case .down:
            if map[safe: position.row + 1]?[safe: position.col] == "#" {
                direction = .left
                position.col -= 1
            } else {
                position.row += 1
            }
        }
    }

    return visited.count
}

func partTwo() -> Int {
    map.indices
        .flatMap { row in map[row].indices.map { col in Coordinates(row, col) } }
        .filter { map[$0.row][$0.col] == "." }
        .count { obstacle in
            var direction = Direction.up
            var position = initial
            var outOfBounds = false
            var visited = Set<Tuple<Coordinates, Direction>>()

            while true {
                if position.row < 0 || position.row >= map.count || position.col < 0 || position.col >= map[0].count {
                    outOfBounds = true
                    break
                }

                let current = Tuple(a: position, b: direction)
                if visited.contains(current) {
                    break
                } else {
                    visited.insert(current)
                }

                switch direction {
                case .left:
                    if map[safe: position.row]?[safe: position.col - 1] == "#" || obstacle == Coordinates(position.row, position.col - 1) {
                        direction = .up
                    } else {
                        position.col -= 1
                    }
                case .right:
                    if map[safe: position.row]?[safe: position.col + 1] == "#" || obstacle == Coordinates(position.row, position.col + 1) {
                        direction = .down
                    } else {
                        position.col += 1
                    }
                case .up:
                    if map[safe: position.row - 1]?[safe: position.col] == "#" || obstacle == Coordinates(position.row - 1, position.col) {
                        direction = .right
                    } else {
                        position.row -= 1
                    }
                case .down:
                    if map[safe: position.row + 1]?[safe: position.col] == "#" || obstacle == Coordinates(position.row + 1, position.col) {
                        direction = .left
                    } else {
                        position.row += 1
                    }
                }
            }

            return !outOfBounds
        }
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
