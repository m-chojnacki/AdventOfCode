//
//  main.swift
//  Day18
//
//  Created by Marcin Chojnacki on 18/12/2023.
//

import Foundation

let example = #"""
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
"""#.lines()
_ = example

let lines = InputHelper.readInput().lines()

enum Direction: Character {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
}

struct Command {
    let direction: Direction
    let steps: Int
    let color: String

    func treatingColorAsCommand() throws -> Command {
        var color = color

        let direction: Direction = switch color.removeLast() {
        case "0": .right
        case "1": .down
        case "2": .left
        case "3": .up
        default: throw Error("Color \(self.color) has no direction information")
        }

        guard let steps = Int(color, radix: 16)
        else { throw Error("Color \(self.color) has no steps number information") }

        return Command(direction: direction, steps: steps, color: self.color)
    }
}

func parseInput(_ input: [String]) throws -> [Command] {
    try input.map { line in
        let components = line.components(separatedBy: .whitespaces)
        guard components.count == 3 else { throw Error("Line \(line) malformed") }

        guard let direction = Direction(rawValue: Character(components[0]))
        else { throw Error("Direction \(components[0]) is not valid") }

        guard let steps = Int(components[1])
        else { throw Error("Steps number \(components[1]) is not valid") }

        let color = components[2]
            .trimmingCharacters(in: .alphanumerics.inverted)
            .lowercased()

        guard color.count == 6
        else { throw Error("Color \(color) has wrong number of components") }

        return Command(direction: direction, steps: steps, color: color)
    }
}

let input = try parseInput(lines)

func calculatePolygonArea(_ vertices: [Coordinates]) -> Int {
    let yy = vertices.map(\.row)
    let xx = vertices.map(\.col)
    let overlace = zip(xx, yy.dropFirst() + yy.prefix(1)).map({ $0.0 * $0.1 }).reduce(0, +)
    let underlace = zip(yy, xx.dropFirst() + xx.prefix(1)).map({ $0.0 * $0.1 }).reduce(0, +)

    return abs(overlace - underlace) / 2
}

func partOne(input: [Command] = input) throws -> Int {
    var current: Coordinates = .zero
    var vertices: [Coordinates] = []
    var perimeter = 0

    for command in input {
        current = switch command.direction {
        case .up: Coordinates(current.row - command.steps, current.col)
        case .down: Coordinates(current.row + command.steps, current.col)
        case .left: Coordinates(current.row, current.col - command.steps)
        case .right: Coordinates(current.row, current.col + command.steps)
        }

        vertices.append(current)
        perimeter += command.steps
    }

    return calculatePolygonArea(vertices) + perimeter / 2 + 1
}

func partTwo() throws -> Int {
    try partOne(input: input.map { try $0.treatingColorAsCommand() })
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
