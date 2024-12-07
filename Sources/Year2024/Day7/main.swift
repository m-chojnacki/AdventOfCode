//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 07/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""

let equations = input
    .lines()
    .compactMap { line -> (Int, [Int])? in
        let split = line.split(separator: ":")
        guard split.count == 2, let test = Int(split[0]) else { return nil }

        let values = split[1]
            .split(separator: " ")
            .compactMap { Int($0) }

        return (test, values)
    }

func generateCombinations(
    current: [Character] = [],
    depth: Int = 0,
    length: Int,
    characters: [Character],
    found: ([Character]) -> Bool
) -> Bool {
    if depth == length {
        return found(current)
    }

    for char in characters {
        if generateCombinations(
            current: current + [char],
            depth: depth + 1,
            length: length,
            characters: characters,
            found: found
        ) {
            return true
        }
    }

    return false
}

func partOne(characters: [Character] = ["+", "*"]) -> Int {
    equations
        .map { equation in
            generateCombinations(
                length: equation.1.count - 1,
                characters: characters
            ) { ops in
                var result = equation.1[0]
                var ops = ops

                for num in equation.1.dropFirst() {
                    let current = ops.removeLast()

                    switch current {
                    case "+":
                        result += num
                    case "*":
                        result *= num
                    case "|":
                        result = Int("\(result)\(num)")!
                    default:
                        fatalError("Unrecognized operator")
                    }

                    if result > equation.0 {
                        return false
                    }
                }

                return result == equation.0
            } ? equation.0 : 0
        }
        .reduce(0, +)
}

func partTwo() -> Int {
    partOne(characters: ["+", "*", "|"])
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
