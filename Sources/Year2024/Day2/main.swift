//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 02/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""

let levels = input
    .lines()
    .map { $0.split(separator: " ").compactMap { Int($0) } }

func isLevelValid(_ level: [Int]) -> Bool {
    let differences = level
        .indices
        .dropFirst()
        .map { level[$0 - 1] - level[$0] }

    let isIncreasing = differences.allSatisfy { (1...3).contains($0) }
    let isDecreasing = differences.allSatisfy { (-3...(-1)).contains($0) }
    let isValid = isIncreasing != isDecreasing

    return isValid
}

func partOne() -> Int {
    let validLevels = levels.map(isLevelValid)
    let numberOfValidLevels = validLevels.count(where: { $0 })

    return numberOfValidLevels
}

func partTwo() -> Int {
    let validLevels = levels.map { level in
        let isValid = isLevelValid(level)
        guard !isValid else { return true }

        //
        // Suboptimal because brings total to O(n^2)
        // But we don't care about it just yet...
        //
        for index in level.indices {
            var new = level
            new.remove(at: index)

            if isLevelValid(new) {
                return true
            }
        }

        return false
    }

    let numberOfValidLevels = validLevels.count(where: { $0 })

    return numberOfValidLevels
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
