//
//  main.swift
//  Day8
//
//  Created by Marcin Chojnacki on 07/12/2023.
//

import Foundation
import Shared

let lines = PackageResources.input_txt.string.lines()

struct Input {
    enum Direction: Character {
        case left = "L"
        case right = "R"
    }

    struct Node {
        let name: String
        let left: String
        let right: String
    }

    let instructions: [Direction]
    let nodes: [Node]

    private(set) lazy var nodeMap: [String: Node] = Dictionary(uniqueKeysWithValues: zip(nodes.map(\.name), nodes))
}

func parseInput(_ lines: [String]) throws -> Input {
    let headerAndBody = lines
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .split(separator: "")

    guard headerAndBody.count == 2, let header = headerAndBody.first?.first, let body = headerAndBody.last
    else { throw Error("Input does not contain one header and one body") }

    let instructions = header.compactMap(Input.Direction.init(rawValue:))
    guard instructions.count == header.count else { throw Error("Instructions contain invalid one") }

    let nodes = try body.map { line in
        let components = line
            .components(separatedBy: .whitespaces)
            .map { $0.trimmingCharacters(in: .alphanumerics.inverted) }
            .filter { !$0.isEmpty }

        guard components.count == 3 else { throw Error("Malformed node descriptor \(line)") }

        return Input.Node(name: components[0], left: components[1], right: components[2])
    }

    return Input(instructions: instructions, nodes: nodes)
}

func partOne() throws -> Int {
    let example = """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """.lines()
    _ = example

    var input = try parseInput(lines)

    var currentNode = input.nodeMap["AAA"]
    var steps = 0

    while currentNode != nil && currentNode?.name != "ZZZ" {
        let instruction = input.instructions[steps % input.instructions.count]

        switch instruction {
        case .left: currentNode = (currentNode?.left).flatMap { input.nodeMap[$0] }
        case .right: currentNode = (currentNode?.right).flatMap { input.nodeMap[$0] }
        }

        steps += 1
    }

    return steps
}

func partTwo() throws -> Int {
    let example = """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """.lines()
    _ = example

    var input = try parseInput(lines)

    func stepsForNode(_ currentNode: Input.Node?) -> Int {
        var currentNode = currentNode
        var steps = 0

        while currentNode != nil && currentNode?.name.last != "Z" {
            let instruction = input.instructions[steps % input.instructions.count]

            switch instruction {
            case .left: currentNode = (currentNode?.left).flatMap { input.nodeMap[$0] }
            case .right: currentNode = (currentNode?.right).flatMap { input.nodeMap[$0] }
            }

            steps += 1
        }

        return steps
    }

    let stepsForNodes = input.nodes
        .filter { $0.name.last == "A" }
        .map(stepsForNode)

    func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    func lcm(_ array: [Int]) -> Int {
        array.reduce(1) { result, current in
            (current * result) / gcd(current, result)
        }
    }

    return lcm(stepsForNodes)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
