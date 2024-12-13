//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 12/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
AAAA
BBCD
BBCC
EEEC
"""

let map = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .lines()
    .map(Array.init)

struct Pair: Hashable {
    let coordinate: Coordinates
    let direction: Coordinates
}

struct Region {
    let letter: Character
    let start: Coordinates
    let area: Int
    let perimeter: Int
}

func regions(calculatePerimeter: (Set<Pair>) -> Int) -> [Region] {
    func visitedWalls(on coordinate: Coordinates) -> (Set<Coordinates>, Set<Pair>) {
        var visited: Set<Coordinates> = []

        func visit(on coordinate: Coordinates) -> Set<Pair> {
            guard !visited.contains(coordinate) else { return [] }
            var walls = Set<Pair>()

            visited.insert(coordinate)

            for coord in [
                Coordinates(-1, 0),
                Coordinates(1, 0),
                Coordinates(0, -1),
                Coordinates(0, 1)
            ] {
                let next = Coordinates(coordinate.row + coord.row, coordinate.col + coord.col)
                if map[safe: next.row]?[safe: next.col] != map[coordinate.row][coordinate.col] {
                    walls.insert(Pair(coordinate: coordinate, direction: coord))
                } else {
                    walls.formUnion(visit(on: next))
                }
            }

            return walls
        }

        let pairs = visit(on: coordinate)

        return (visited, pairs)
    }

    var result = [Region]()
    var regionsStack = Set(map.indices.flatMap { row in map[row].indices.map { col in Coordinates(row, col) } })

    while !regionsStack.isEmpty {
        let regionToCheck = regionsStack.removeFirst()
        let (visited, walls) = visitedWalls(on: regionToCheck)
        let firstVisited = visited.first!

        result.append(
            Region(
                letter: map[firstVisited.row][firstVisited.col],
                start: firstVisited,
                area: visited.count,
                perimeter: calculatePerimeter(walls)
            )
        )
        regionsStack.subtract(visited)
    }

    return result
}

func partOne() -> Int {
    regions { $0.count }
        .map { $0.area * $0.perimeter }
        .reduce(0, +)
}

func partTwo() -> Int {
    regions { walls in
        var blacklisted = Set<Pair>()
        for wall in walls {
            var i = 1
            if wall.direction.col == 0 {
                while walls.contains(
                    Pair(
                        coordinate: Coordinates(wall.coordinate.row, wall.coordinate.col + i),
                        direction: wall.direction
                    )
                ) {
                    blacklisted.insert(
                        Pair(
                            coordinate: Coordinates(wall.coordinate.row, wall.coordinate.col + i),
                            direction: wall.direction
                        )
                    )
                    i += 1
                }
            } else {
                while walls.contains(
                    Pair(
                        coordinate: Coordinates(wall.coordinate.row + i, wall.coordinate.col),
                        direction: wall.direction
                    )
                ) {
                    blacklisted.insert(
                        Pair(
                            coordinate: Coordinates(wall.coordinate.row + i, wall.coordinate.col),
                            direction: wall.direction
                        )
                    )
                    i += 1
                }
            }
        }

        return walls.subtracting(blacklisted).count
    }
    .map { $0.area * $0.perimeter }
    .reduce(0, +)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
