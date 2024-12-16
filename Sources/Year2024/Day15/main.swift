//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 15/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
"""

enum Map: Character, CustomStringConvertible {
    case wall = "#"
    case box = "O"
    case bigBoxL = "["
    case bigBoxR = "]"
    case robot = "@"
    case empty = "."

    var description: String {
        String(rawValue)
    }
}

enum Direction: Character, CustomStringConvertible {
    case up = "^"
    case down = "v"
    case left = "<"
    case right = ">"

    var description: String {
        String(rawValue)
    }

    var offset: Coordinates {
        switch self {
        case .up:
            Coordinates(-1, 0)
        case .down:
            Coordinates(1, 0)
        case .left:
            Coordinates(0, -1)
        case .right:
            Coordinates(0, 1)
        }
    }
}

func parse() -> ([[Map]], [Coordinates], [Direction]) {
    let twoParts = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: "\n\n")

    guard twoParts.count == 2 else { fatalError("Input has no two parts") }

    var top = twoParts[0]
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lines()
        .map { Array($0).compactMap(Map.init(rawValue:)) }

    let robots = top.indices
        .flatMap { row in
            top[row].indices.compactMap { col in
                if top[row][col] == .robot {
                    Coordinates(row, col)
                } else {
                    nil
                }
            }
        }

    for robot in robots {
        top[robot.row][robot.col] = .empty
    }

    let bottom = twoParts[1]
        .compactMap(Direction.init(rawValue:))

    return (top, robots, bottom)
}

func sum(_ map: [[Map]]) -> Int {
    map.indices
        .flatMap { row in
            map[row].indices.compactMap { col in
                if map[row][col] == .box || map[row][col] == .bigBoxL {
                    Coordinates(row, col)
                } else {
                    nil
                }
            }
        }
        .map {
            100 * $0.row + $0.col
        }
        .reduce(0, +)
}

func partOne() -> Int {
    var (map, robots, directions) = parse()
    var robot = robots.first!

    for direction in directions {
        let offset = direction.offset

        switch map[robot.row + offset.row][robot.col + offset.col] {
        case .empty, .robot:
            robot.row += offset.row
            robot.col += offset.col
        case .box, .bigBoxL, .bigBoxR:
            var box = Coordinates(robot.row + offset.row, robot.col + offset.col)
            while map[box.row][box.col] == .box {
                box.row += offset.row
                box.col += offset.col
            }
            if map[box.row][box.col] == .empty {
                map[robot.row + offset.row][robot.col + offset.col] = .empty
                map[box.row][box.col] = .box
                robot.row += offset.row
                robot.col += offset.col
            }
        case .wall:
            break
        }
    }

    return sum(map)
}

func partTwo() -> Int {
    let (originalMap, robots, directions) = parse()
    var robot = robots.map { Coordinates($0.row, $0.col * 2) }.first!
    var map = originalMap.map { row in
        row.flatMap { tile -> [Map] in
            switch tile {
            case .wall:
                [.wall, .wall]
            case .box:
                [.bigBoxL, .bigBoxR]
            case .bigBoxL:
                [.bigBoxL]
            case .bigBoxR:
                [.bigBoxR]
            case .robot:
                [.robot, .empty]
            case .empty:
                [.empty, .empty]
            }
        }
    }

    func printMap() {
        for y in map.indices {
            for x in map[y].indices {
                print(robot.row == y && robot.col == x ? "@" : map[y][x], terminator: "")
            }
            print()
        }
    }

    for direction in directions {
        let offset = direction.offset

        switch map[robot.row + offset.row][robot.col + offset.col] {
        case .empty, .robot:
            robot.row += offset.row
            robot.col += offset.col
        case .box, .bigBoxL, .bigBoxR:
            if direction == .left || direction == .right {
                var box = Coordinates(robot.row + offset.row, robot.col + offset.col)
                while map[box.row][box.col] == .bigBoxL || map[box.row][box.col] == .bigBoxR {
                    box.col += offset.col
                }
                if map[box.row][box.col] == .empty {
                    map[robot.row + offset.row][robot.col + offset.col] = .empty
                    robot.col += offset.col

                    var leftSide = true
                    while box.col != robot.col {
                        map[box.row][box.col] = leftSide != (offset.col > 0) ? .bigBoxL : .bigBoxR
                        leftSide.toggle()
                        box.col -= offset.col
                    }
                }
            } else {
                var boxSet = Set<Coordinates>()

                func moveBox(_ box: Coordinates) {
                    var box = box
                    if map[box.row][box.col] == .bigBoxR {
                        box.col -= 1
                    }

                    boxSet.insert(box)

                    // one box directly above or on the left side
                    if map[box.row + offset.row][box.col] == .bigBoxL || map[box.row + offset.row][box.col] == .bigBoxR {
                        moveBox(Coordinates(box.row + offset.row, box.col))
                    }

                    // additional box on the right side
                    if map[box.row + offset.row][box.col + 1] == .bigBoxL {
                        moveBox(Coordinates(box.row + offset.row, box.col + 1))
                    }
                }

                moveBox(Coordinates(robot.row + offset.row, robot.col + offset.col))

                let canMove = !boxSet
                    .map { box in
                        map[box.row + offset.row][box.col] != .wall && map[box.row + offset.row][box.col + 1] != .wall
                    }
                    .contains(false)

                if canMove {
                    for box in boxSet {
                        map[box.row][box.col] = .empty
                        map[box.row][box.col + 1] = .empty
                    }
                    for box in boxSet {
                        map[box.row + offset.row][box.col] = .bigBoxL
                        map[box.row + offset.row][box.col + 1] = .bigBoxR
                    }
                    robot.row += offset.row
                }
            }
        case .wall:
            break
        }
    }

    return sum(map)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
