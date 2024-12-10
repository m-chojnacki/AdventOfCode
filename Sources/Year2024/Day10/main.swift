//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 10/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"""

let map = input.lines().map { Array($0).compactMap { Int(String($0)) } }

let startPoints = map.indices.flatMap { row in
    map[row].indices
        .filter { map[row][$0] == 0 }
        .map { col in Coordinates(row, col) }
}

func pathsForTrailhead(_ start: Coordinates) -> Set<[Coordinates]> {
    var paths: Set<[Coordinates]> = []

    func walk(_ coord: Coordinates, value: Int, path: [Coordinates]) {
        let current = map[safe: coord.row]?[safe: coord.col]
        guard current == value else { return }

        if current == 9 {
            paths.insert(path + [coord])
        } else {
            for dir in [
                Coordinates(coord.row - 1, coord.col),
                Coordinates(coord.row + 1, coord.col),
                Coordinates(coord.row, coord.col - 1),
                Coordinates(coord.row, coord.col + 1)
            ] {
                walk(dir, value: value + 1, path: path + [coord])
            }
        }
    }

    walk(start, value: 0, path: [])

    return paths
}

func partOne() -> Int {
    startPoints.map { Set(pathsForTrailhead($0).map { $0.last! }).count }.reduce(0, +)
}

func partTwo() -> Int {
    startPoints.map { Set(pathsForTrailhead($0)).count }.reduce(0, +)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
