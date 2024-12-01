//
//  main.swift
//  Day23
//
//  Created by Marcin Chojnacki on 22/12/2023.
//

import Foundation
import Shared

let example = #"""
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
"""#.lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

let input = lines.map { Array($0) as [Character] }

enum Direction: Hashable {
    case up
    case down
    case left
    case right
}

extension Coordinates {
    func advanced(in direction: Direction) -> Coordinates {
        switch direction {
        case .up: Coordinates(row - 1, col)
        case .down: Coordinates(row + 1, col)
        case .left: Coordinates(row, col - 1)
        case .right: Coordinates(row, col + 1)
        }
    }
}

func partOne(notSloppy: Bool = false) throws -> Int {
    let startCord = Coordinates(input.indices.first ?? 0, input.first?.firstIndex(of: ".") ?? 0)
    let endCoord = Coordinates(input.indices.last ?? 0, input.last?.firstIndex(of: ".") ?? 0)

    struct TreeNode: Hashable {
        let coordinates: Coordinates
        let path: Set<Coordinates>
    }

    var tree = [TreeNode(coordinates: startCord, path: [])]
    var maxPath = 0

    while !tree.isEmpty {
        let current = tree.remove(at: tree.count - 1)

        if current.coordinates == endCoord {
            maxPath = max(maxPath, current.path.count)
            continue
        }

        let path = current.path.union([current.coordinates])

        func advance(in direction: Direction) {
            let target = current.coordinates.advanced(in: direction)
            let targetField = input[safe: target.row]?[safe: target.col]

            if !current.path.contains(target) && targetField != "#" && targetField != nil {
                tree.append(TreeNode(coordinates: target, path: path))
            }
        }

        let currentField = input[safe: current.coordinates.row]?[safe: current.coordinates.col]

        if currentField == "." || currentField == "^" || notSloppy {
            advance(in: .up)
        }

        if currentField == "." || currentField == "v" || notSloppy {
            advance(in: .down)
        }

        if currentField == "." || currentField == "<" || notSloppy {
            advance(in: .left)
        }

        if currentField == "." || currentField == ">" || notSloppy {
            advance(in: .right)
        }
    }

    return maxPath
}

func partTwo() throws -> Int {
    try partOne(notSloppy: true)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
