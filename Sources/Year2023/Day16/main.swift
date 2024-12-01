//
//  main.swift
//  Day16
//
//  Created by Marcin Chojnacki on 16/12/2023.
//

import Foundation
import Shared

let example = #"""
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
"""#.lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

enum Tile: Character, CustomStringConvertible {
    case empty = "."
    case verticalSplitter = "|"
    case horizontalSplitter = "-"
    case leftRightMirror = "\\"
    case rightLeftMirror = "/"

    var description: String {
        String(rawValue)
    }
}

let input = lines.map { $0.compactMap(Tile.init) }

enum Direction: Hashable {
    case up
    case down
    case left
    case right
}

func countEnergizedTiles(coordinates: Coordinates, direction: Direction) -> Int {
    struct Visitation: Hashable {
        let coordinates: Coordinates
        let direction: Direction
    }

    var visited: Set<Visitation> = []

    func visit(coordinates: Coordinates, direction: Direction) {
        let visitation = Visitation(coordinates: coordinates, direction: direction)

        guard let current = input[safe: coordinates.row]?[safe: coordinates.col],
              !visited.contains(visitation)
        else { return }

        visited.insert(visitation)

        switch current {
        case .empty:
            switch direction {
            case .up: visit(coordinates: Coordinates(coordinates.row - 1, coordinates.col), direction: .up)
            case .down: visit(coordinates: Coordinates(coordinates.row + 1, coordinates.col), direction: .down)
            case .left: visit(coordinates: Coordinates(coordinates.row, coordinates.col - 1), direction: .left)
            case .right: visit(coordinates: Coordinates(coordinates.row, coordinates.col + 1), direction: .right)
            }

        case .verticalSplitter:
            switch direction {
            case .up: visit(coordinates: Coordinates(coordinates.row - 1, coordinates.col), direction: .up)
            case .down: visit(coordinates: Coordinates(coordinates.row + 1, coordinates.col), direction: .down)
            case .left, .right:
                visit(coordinates: Coordinates(coordinates.row - 1, coordinates.col), direction: .up)
                visit(coordinates: Coordinates(coordinates.row + 1, coordinates.col), direction: .down)
            }

        case .horizontalSplitter:
            switch direction {
            case .up, .down:
                visit(coordinates: Coordinates(coordinates.row, coordinates.col - 1), direction: .left)
                visit(coordinates: Coordinates(coordinates.row, coordinates.col + 1), direction: .right)
            case .left: visit(coordinates: Coordinates(coordinates.row, coordinates.col - 1), direction: .left)
            case .right: visit(coordinates: Coordinates(coordinates.row, coordinates.col + 1), direction: .right)
            }

        case .leftRightMirror:
            switch direction {
            case .up: visit(coordinates: Coordinates(coordinates.row, coordinates.col - 1), direction: .left)
            case .down: visit(coordinates: Coordinates(coordinates.row, coordinates.col + 1), direction: .right)
            case .left: visit(coordinates: Coordinates(coordinates.row - 1, coordinates.col), direction: .up)
            case .right: visit(coordinates: Coordinates(coordinates.row + 1, coordinates.col), direction: .down)
            }

        case .rightLeftMirror:
            switch direction {
            case .up: visit(coordinates: Coordinates(coordinates.row, coordinates.col + 1), direction: .right)
            case .down: visit(coordinates: Coordinates(coordinates.row, coordinates.col - 1), direction: .left)
            case .left: visit(coordinates: Coordinates(coordinates.row + 1, coordinates.col), direction: .down)
            case .right: visit(coordinates: Coordinates(coordinates.row - 1, coordinates.col), direction: .up)
            }
        }
    }

    visit(coordinates: coordinates, direction: direction)

    return Set(visited.map(\.coordinates)).count
}

func partOne() throws -> Int {
    countEnergizedTiles(coordinates: Coordinates(0, 0), direction: .right)
}

func partTwo() throws -> Int {
    guard !input.isEmpty else { return 0 }

    var energizedTiles: Set<Int> = []

    for row in input.indices {
        energizedTiles.insert(countEnergizedTiles(coordinates: Coordinates(row, 0), direction: .right))
        energizedTiles.insert(countEnergizedTiles(coordinates: Coordinates(row, input[0].count - 1), direction: .left))
    }

    for col in input[0].indices {
        energizedTiles.insert(countEnergizedTiles(coordinates: Coordinates(0, col), direction: .down))
        energizedTiles.insert(countEnergizedTiles(coordinates: Coordinates(input.count - 1, col), direction: .up))
    }

    if let maxEnergizedTiles = energizedTiles.max() {
        return maxEnergizedTiles
    } else {
        throw Error("Max value not found")
    }
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
