//
//  main.swift
//  Day3
//
//  Created by Marcin Chojnacki on 02/12/2023.
//

import Foundation
import Shared

let example = """
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

let schematic = lines.map(Array.init)

struct MatrixIndex: Hashable {
    let y: Array.Index
    let x: Array.Index

    var adjacent: [MatrixIndex] {
        [
            MatrixIndex(y: y, x: x - 1),
            MatrixIndex(y: y, x: x + 1),
            MatrixIndex(y: y - 1, x: x - 1),
            MatrixIndex(y: y - 1, x: x),
            MatrixIndex(y: y - 1, x: x + 1),
            MatrixIndex(y: y + 1, x: x - 1),
            MatrixIndex(y: y + 1, x: x),
            MatrixIndex(y: y + 1, x: x + 1)
        ]
    }
}

extension Collection where Index == Array.Index, Element: Collection, Element.Index == Index {
    subscript(_ matrixIndex: MatrixIndex) -> Element.Element? {
        self[safe: matrixIndex.y]?[safe: matrixIndex.x]
    }
}

func partOne() throws -> Int {
    var sumOfPartNumbers = 0

    for y in schematic.indices {
        var currentNumber: [String.Element] = []
        var adjacentParts: [String.Element] = []

        for x in schematic[y].indices {
            let currentValue = schematic[y][x]

            if currentValue.isNumber {
                let adjacent = MatrixIndex(y: y, x: x)
                    .adjacent
                    .compactMap { schematic[$0] }
                    .filter { !$0.isNumber && $0 != "." }

                currentNumber.append(currentValue)
                adjacentParts.append(contentsOf: adjacent)
            }

            if !currentNumber.isEmpty && (!currentValue.isNumber || x == schematic[y].indices.last) {
                let currentNumberString = currentNumber.map(String.init).joined()
                guard let currentInt = Int(currentNumberString)
                else { throw Error("\(currentNumberString) is not a number") }

                if !adjacentParts.isEmpty {
                    sumOfPartNumbers += currentInt
                }

                currentNumber.removeAll(keepingCapacity: true)
                adjacentParts.removeAll(keepingCapacity: true)
            }
        }
    }

    return sumOfPartNumbers
}

func partTwo() throws -> Int {
    var partsAdjacentToGears: [MatrixIndex: Set<Int>] = [:]

    for y in schematic.indices {
        var currentNumber: [String.Element] = []
        var indicesOfGears: [MatrixIndex] = []

        for x in schematic[y].indices {
            let currentValue = schematic[y][x]

            if currentValue.isNumber {
                let indicesOfGear = MatrixIndex(y: y, x: x)
                    .adjacent
                    .filter { schematic[$0] == "*" }

                currentNumber.append(currentValue)
                indicesOfGears.append(contentsOf: indicesOfGear)
            }

            if !currentNumber.isEmpty && (!currentValue.isNumber || x == schematic[y].indices.last) {
                let currentNumberString = currentNumber.map(String.init).joined()
                guard let currentInt = Int(currentNumberString)
                else { throw Error("\(currentNumberString) is not a number") }

                for indicesOfGear in indicesOfGears {
                    if partsAdjacentToGears[indicesOfGear] == nil {
                        partsAdjacentToGears[indicesOfGear] = [currentInt]
                    } else {
                        partsAdjacentToGears[indicesOfGear]?.insert(currentInt)
                    }
                }

                currentNumber.removeAll(keepingCapacity: true)
                indicesOfGears.removeAll(keepingCapacity: true)
            }
        }
    }

    return partsAdjacentToGears.values
        .compactMap { parts in
            parts.count == 2 ? parts.reduce(1, *) : nil
        }
        .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
