//
//  main.swift
//  Day14
//
//  Created by Marcin Chojnacki on 14/12/2023.
//

import Foundation
import Shared

let example = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

enum Rock: Character, CustomStringConvertible {
    case rounded = "O"
    case cube = "#"
    case empty = "."

    var description: String {
        String(rawValue)
    }
}

func parseInput(_ input: [String]) -> [[Rock]] {
    input.map { $0.compactMap(Rock.init) }
}

let input = parseInput(lines)

extension [[Rock]] {
    mutating func tiltNorth() {
        for row in indices.dropLast() {
            for col in self[row].indices where self[row][col] == .empty {
                for searchedRow in (row + 1)..<count {
                    if self[searchedRow][col] == .rounded {
                        self[row][col] = .rounded
                        self[searchedRow][col] = .empty
                        break
                    } else if self[searchedRow][col] == .cube {
                        break
                    }
                }
            }
        }
    }

    mutating func tiltWest() {
        for row in indices {
            for col in self[row].indices.dropLast() where self[row][col] == .empty {
                for searchedCol in (col + 1)..<self[row].count {
                    if self[row][searchedCol] == .rounded {
                        self[row][col] = .rounded
                        self[row][searchedCol] = .empty
                        break
                    } else if self[row][searchedCol] == .cube {
                        break
                    }
                }
            }
        }
    }

    mutating func tiltSouth() {
        for row in indices.dropFirst().reversed() {
            for col in self[row].indices where self[row][col] == .empty {
                for searchedRow in (0..<row).reversed() {
                    if self[searchedRow][col] == .rounded {
                        self[row][col] = .rounded
                        self[searchedRow][col] = .empty
                        break
                    } else if self[searchedRow][col] == .cube {
                        break
                    }
                }
            }
        }
    }

    mutating func tiltEast() {
        for row in indices {
            for col in self[row].indices.dropFirst().reversed() where self[row][col] == .empty {
                for searchedCol in (0..<col).reversed() {
                    if self[row][searchedCol] == .rounded {
                        self[row][col] = .rounded
                        self[row][searchedCol] = .empty
                        break
                    } else if self[row][searchedCol] == .cube {
                        break
                    }
                }
            }
        }
    }

    mutating func spin() {
        tiltNorth()
        tiltWest()
        tiltSouth()
        tiltEast()
    }

    func calculateLoad() -> Int {
        enumerated()
            .map { index, row in
                let load = count - index
                return row.reduce(0, { result, current in result + (current == .rounded ? 1 : 0) }) * load
            }
            .reduce(0, +)
    }
}

extension Array where Element: Equatable {
    func findLongestRepeatingSequence() -> Self {
        for len in (1..<(count / 2)).reversed() {
            if self[0..<len] == self[len..<(len + len)] {
                return Array(self[0..<len])
            }
        }

        return []
    }
}

func partOne() throws -> Int {
    var input = input
    input.tiltNorth()

    return input.calculateLoad()
}

func partTwo() throws -> Int {
    // The following constants might need adjusting to fit bigger data set:
    let warmUpSpins = 200   // After n spins, arrangement of rocks starts to repeat...
    let maxSpinCycle = 50   // ...and repeats at most every x next spins.

    var input = input
    var loadsAfterWarmUp: [Int] = []

    for i in 0..<(warmUpSpins + maxSpinCycle) {
        if i >= warmUpSpins {
            loadsAfterWarmUp.append(input.calculateLoad())
        }

        input.spin()
    }

    let spinCycle = loadsAfterWarmUp.findLongestRepeatingSequence()

    // Let's approximate rocks pattern after n cycles using historical data.
    return spinCycle[(1000000000 - warmUpSpins) % spinCycle.count]
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
