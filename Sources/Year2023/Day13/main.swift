//
//  main.swift
//  Day13
//
//  Created by Marcin Chojnacki on 13/12/2023.
//

import Foundation
import Shared

let example = """
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

enum Equality {
    case equal
    case almostEqual
    case notEqual
}

func equality<T: Equatable>(_ a: [T], _ b: [T]) -> Equality {
    guard a.count == b.count else { return .notEqual }

    var equal = 0
    for (x, y) in zip(a, b) where x == y {
        equal += 1
    }

    return switch equal {
    case a.count: .equal
    case a.count - 1: .almostEqual
    default: .notEqual
    }
}

func findReflection(in pattern: [[Character]], allowedSmudges: Int) -> Int? {
    for rowsBeforeMirror in 1..<(pattern.count) {
        var almostEqual = 0
        var notEqual = 0

        for offset in 0..<rowsBeforeMirror {
            if let reflection = pattern[safe: rowsBeforeMirror + offset] {
                switch equality(pattern[rowsBeforeMirror - offset - 1], reflection) {
                case .equal: break
                case .almostEqual: almostEqual += 1
                case .notEqual: notEqual += 1
                }
            }
        }

        if notEqual == 0 && almostEqual == allowedSmudges {
            return rowsBeforeMirror
        }
    }

    return nil
}

func partOne(allowedSmudges: Int = 0) throws -> Int {
    lines
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .split(separator: "")
        .map { $0.map(Array.init) }
        .map {
            (findReflection(in: $0.transposed(), allowedSmudges: allowedSmudges) ?? 0) +
                (findReflection(in: $0, allowedSmudges: allowedSmudges) ?? 0) * 100
        }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    try partOne(allowedSmudges: 1)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
