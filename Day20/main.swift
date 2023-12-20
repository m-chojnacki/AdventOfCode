//
//  main.swift
//  Day20
//
//  Created by Marcin Chojnacki on 19/12/2023.
//

import Foundation

let example = #"""
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""#.lines()
_ = example

let lines = InputHelper.readInput().lines()

enum ModuleType {
    case broadcaster
    case flipFlop
    case conjunction
}

struct Input {
    let name: String
    let type: ModuleType
    let outputs: [String]
}

func parseInput(_ input: [String]) throws -> [Input] {
    try input.map { line in
        let split = line.split(separator: " -> ")
        guard split.count == 2, let first = split.first, let last = split.last
        else { throw Error("Malformed line: \(line)") }

        let name: String
        let type: ModuleType
        if first.hasPrefix("%") {
            name = String(first.dropFirst())
            type = .flipFlop
        } else if first.hasPrefix("&") {
            name = String(first.dropFirst())
            type = .conjunction
        } else if first == "broadcaster" {
            name = "broadcaster"
            type = .broadcaster
        } else {
            throw Error("Unknown module: \(first)")
        }

        let outputs = last
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        return Input(name: name, type: type, outputs: outputs)
    }
}

let input = try parseInput(lines)

struct BiInput {
    let name: String
    let type: ModuleType
    let inputs: [String]
    let outputs: [String]
}

func partOne() throws -> Int {
    let map = [String: BiInput](
        uniqueKeysWithValues: zip(
            input.map(\.name),
            input.map { item in
                BiInput(
                    name: item.name,
                    type: item.type,
                    inputs: input.filter { $0.outputs.contains(item.name) }.map(\.name),
                    outputs: item.outputs
                )
            }
        )
    )

    struct Pair {
        let source: String
        let target: String
        var pulse: Bool
    }

    var flipFlopStates: [String: Bool] = [:]
    var conjunctionStates: [String: [Pair]] = Dictionary(
        uniqueKeysWithValues: map
            .values
            .filter { $0.type == .conjunction }
            .map { ($0.name, $0.inputs.map { Pair(source: "", target: $0, pulse: false) }) }
     )

    var pulseQueue: [Pair] = []
    var low = 0
    var high = 0

    func pushButton() {
        pulseQueue.append(Pair(source: "button", target: "broadcaster", pulse: false))
        low += 1
    }

    func sendPulse(_ pair: Pair) {
        pulseQueue.append(pair)

        if pair.pulse {
            high += 1
        } else {
            low += 1
        }
    }

    func processPair(_ pair: Pair) throws {
        guard let module = map[pair.target] else { return }

        switch module.type {
        case .broadcaster:
            for output in module.outputs {
                sendPulse(Pair(source: module.name, target: output, pulse: pair.pulse))
            }

        case .flipFlop:
            if !pair.pulse {
                let currentState = flipFlopStates[module.name] ?? false
                flipFlopStates[module.name] = !currentState
                for output in module.outputs {
                    sendPulse(Pair(source: module.name, target: output, pulse: !currentState))
                }
            }

        case .conjunction:
            for index in conjunctionStates[module.name]?.indices ?? 0..<0 {
                if conjunctionStates[module.name]?[index].target == pair.source {
                    conjunctionStates[module.name]?[index].pulse = pair.pulse
                }
            }

            let allTrue = conjunctionStates[module.name]?.allSatisfy(\.pulse) == true

            for output in module.outputs {
                sendPulse(Pair(source: module.name, target: output, pulse: !allTrue))
            }
        }
    }

    func resolveQueue() throws {
        while !pulseQueue.isEmpty {
            let pair = pulseQueue.removeFirst()
            try processPair(pair)
        }
    }

    for i in 0..<1000 {
        pushButton()
        try resolveQueue()
    }

    return low * high
}

func partTwo() throws -> Int {
    return 0
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
