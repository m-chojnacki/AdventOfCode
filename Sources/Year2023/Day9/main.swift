//
//  main.swift
//  Day9
//
//  Created by Marcin Chojnacki on 09/12/2023.
//

import Foundation
import Shared

let example = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

let input = lines.map {
    $0.components(separatedBy: .whitespaces).compactMap(Int.init)
}

func differences(_ history: [Int]) -> [Int] {
    history.indices.dropFirst().map { index in
        history[index] - history[index - 1]
    }
}

func differencesUntilAllZeros(_ history: [Int]) -> [[Int]] {
    var current = history
    var result = [current]

    while !current.allSatisfy({ $0 == 0 }) {
        current = differences(current)
        result.append(current)
    }

    return result
}

func partOne() throws -> Int {
    func extrapolate(_ report: [[Int]]) -> [[Int]] {
        var report = report

        report.indices.reversed().forEach { line in
            let lastElementOfCurrentLine = report[safe: line]?.last ?? 0
            let lastElementOfNextLine = report[safe: line + 1]?.last ?? 0

            report[safe: line]?.append(lastElementOfCurrentLine + lastElementOfNextLine)
        }

        return report
    }

    return input
        .map { extrapolate(differencesUntilAllZeros($0)).first?.last ?? 0 }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    func extrapolate(_ report: [[Int]]) -> [[Int]] {
        var report = report

        report.indices.reversed().forEach { line in
            let lastElementOfCurrentLine = report[safe: line]?.first ?? 0
            let lastElementOfNextLine = report[safe: line + 1]?.first ?? 0

            report[safe: line]?.insert(lastElementOfCurrentLine - lastElementOfNextLine, at: 0)
        }

        return report
    }

    return input
        .map { extrapolate(differencesUntilAllZeros($0)).first?.first ?? 0 }
        .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
