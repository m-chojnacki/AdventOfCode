//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 04/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""

let chars = input.lines().map(Array.init)

func partOne() -> Int {
    var count = 0

    for y in chars.indices {
        for x in chars[y].indices {
            let horizontalForward =
                chars[safe: y]?[safe: x] == "X" &&
                chars[safe: y]?[safe: x + 1] == "M" &&
                chars[safe: y]?[safe: x + 2] == "A" &&
                chars[safe: y]?[safe: x + 3] == "S"

            let horizontalBackward =
                chars[safe: y]?[safe: x] == "S" &&
                chars[safe: y]?[safe: x + 1] == "A" &&
                chars[safe: y]?[safe: x + 2] == "M" &&
                chars[safe: y]?[safe: x + 3] == "X"

            let verticalForward =
                chars[safe: y]?[safe: x] == "X" &&
                chars[safe: y + 1]?[safe: x] == "M" &&
                chars[safe: y + 2]?[safe: x] == "A" &&
                chars[safe: y + 3]?[safe: x] == "S"

            let verticalBackward =
                chars[safe: y]?[safe: x] == "S" &&
                chars[safe: y + 1]?[safe: x] == "A" &&
                chars[safe: y + 2]?[safe: x] == "M" &&
                chars[safe: y + 3]?[safe: x] == "X"

            let leftDiagonalForward =
                chars[safe: y]?[safe: x] == "X" &&
                chars[safe: y + 1]?[safe: x - 1] == "M" &&
                chars[safe: y + 2]?[safe: x - 2] == "A" &&
                chars[safe: y + 3]?[safe: x - 3] == "S"

            let leftDiagonalBackward =
                chars[safe: y]?[safe: x] == "S" &&
                chars[safe: y + 1]?[safe: x - 1] == "A" &&
                chars[safe: y + 2]?[safe: x - 2] == "M" &&
                chars[safe: y + 3]?[safe: x - 3] == "X"

            let rightDiagonalForward =
                chars[safe: y]?[safe: x] == "X" &&
                chars[safe: y + 1]?[safe: x + 1] == "M" &&
                chars[safe: y + 2]?[safe: x + 2] == "A" &&
                chars[safe: y + 3]?[safe: x + 3] == "S"

            let rightDiagonalBackward =
                chars[safe: y]?[safe: x] == "S" &&
                chars[safe: y + 1]?[safe: x + 1] == "A" &&
                chars[safe: y + 2]?[safe: x + 2] == "M" &&
                chars[safe: y + 3]?[safe: x + 3] == "X"

            count += [
                horizontalForward,
                horizontalBackward,
                verticalForward,
                verticalBackward,
                leftDiagonalForward,
                leftDiagonalBackward,
                rightDiagonalForward,
                rightDiagonalBackward
            ].count(where: { $0 })
        }
    }

    return count
}

func partTwo() -> Int {
    var count = 0

    for y in chars.indices {
        for x in chars[y].indices {
            guard chars[y][x] == "A" else { continue }

            let msms =
                chars[safe: y - 1]?[safe: x - 1] == "M" &&
                chars[safe: y + 1]?[safe: x + 1] == "S" &&
                chars[safe: y - 1]?[safe: x + 1] == "M" &&
                chars[safe: y + 1]?[safe: x - 1] == "S"

            let smsm =
                chars[safe: y - 1]?[safe: x - 1] == "S" &&
                chars[safe: y + 1]?[safe: x + 1] == "M" &&
                chars[safe: y - 1]?[safe: x + 1] == "S" &&
                chars[safe: y + 1]?[safe: x - 1] == "M"

            let smms =
                chars[safe: y - 1]?[safe: x - 1] == "S" &&
                chars[safe: y + 1]?[safe: x + 1] == "M" &&
                chars[safe: y - 1]?[safe: x + 1] == "M" &&
                chars[safe: y + 1]?[safe: x - 1] == "S"

            let mssm =
                chars[safe: y - 1]?[safe: x - 1] == "M" &&
                chars[safe: y + 1]?[safe: x + 1] == "S" &&
                chars[safe: y - 1]?[safe: x + 1] == "S" &&
                chars[safe: y + 1]?[safe: x - 1] == "M"

            if msms || smsm || smms || mssm {
                count += 1
            }
        }
    }

    return count
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
