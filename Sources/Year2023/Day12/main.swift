//
//  main.swift
//  Day12
//
//  Created by Marcin Chojnacki on 11/12/2023.
//

import Foundation
import Algorithms
import Shared

let example = """
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

struct Input {
    enum Spring: Character, CustomStringConvertible {
        case unknown = "?"
        case operational = "."
        case damaged = "#"

        var description: String {
            String(rawValue)
        }
    }

    let springs: [Spring]
    let backup: [Int]

    func unfolded(count: Int) -> Input {
        Input(
            springs: Array(Array(repeating: springs, count: count).joined(by: .unknown)),
            backup: Array(Array(repeating: backup, count: count).joined())
        )
    }
}

func parseInput(_ input: [String]) throws -> [Input] {
    try input.map { line in
        let parts = line.components(separatedBy: .whitespaces)
        guard parts.count == 2 else { throw Error("Line \(line) has no two parts") }

        let springs = parts[0].compactMap(Input.Spring.init(rawValue:))
        let backup = parts[1].components(separatedBy: ",").compactMap(Int.init)

        return Input(springs: springs, backup: backup)
    }
}

let input = try parseInput(example)

func findPossibleArrangements(for input: Input) -> Int {
    let hashesPlaced = input.springs.lazy.filter { $0 == .damaged }.count
    let hashesExpected = input.backup.reduce(0, +)
    let hashesLeft = hashesExpected - hashesPlaced
    let unknownPlaced = input.springs.lazy.filter { $0 == .unknown }.count

    let damagedToPlace = Array(repeating: Input.Spring.damaged, count: hashesLeft)
    let operationalToPlace = Array(repeating: Input.Spring.operational, count: unknownPlaced - hashesLeft)
    let allToPlace = damagedToPlace + operationalToPlace

    return allToPlace.uniquePermutations(ofCount: allToPlace.count)
        .lazy
        .compactMap { permutation -> [Input.Spring]? in
            var permutationIndex = 0
            var filledSprings = input.springs

            for i in filledSprings.indices where filledSprings[i] == .unknown {
                filledSprings[i] = permutation[permutationIndex]
                permutationIndex += 1
            }

            return filledSprings
        }
        .map { filledSprings in
            filledSprings
                .chunked(by: { $0 == $1 })
                .filter { $0.first == .damaged }
                .map { $0.count }
        }
        .filter { $0 == input.backup }
        .count
}

func partOne() throws -> Int {
    input
        .map(findPossibleArrangements)
        .reduce(0, +)
}

func partTwo() throws -> Int {
    let foldedArrangements = input.map(findPossibleArrangements)
    let onceUnfoldedArrangements = input.map { findPossibleArrangements(for: $0.unfolded(count: 2)) }

    let nextFoldMultipliers = zip(onceUnfoldedArrangements, foldedArrangements).map { $0 / $1 }
    let finalFoldMultipliers = nextFoldMultipliers.map { Int(pow(Double($0), 4)) }

    return zip(foldedArrangements, finalFoldMultipliers)
        .map { $0 * $1 }
        .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
