//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 09/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = "2333133121414131402"

func parse() -> [Int?] {
    var disk = [Int?]()
    var isFile = true
    var nextFile = 0

    for char in input.trimmingCharacters(in: .decimalDigits.inverted) {
        let size = Int(String(char))!

        for _ in 0..<size {
            disk.append(isFile ? nextFile : nil)
        }

        if isFile {
            nextFile += 1
        }

        isFile.toggle()
    }

    return disk
}

func partOne() -> Int {
    var disk = parse()
    var freeIndex = 0

    while freeIndex < disk.count {
        while freeIndex < disk.count && disk[freeIndex] != nil {
            freeIndex += 1
        }

        if freeIndex < disk.count, let lastItem = disk.removeLast() {
            disk[freeIndex] = lastItem
        }
    }

    return disk.indices.map { $0 * (disk[$0] ?? 0) }.reduce(0, +)
}

func partTwo() -> Int {
    var disk = parse()

    // We could save some time by doing sparse array
    // but I wanted to keep the parsing consistent
    for id in (0...disk.last!!).reversed() {
        if let lastIndex = disk.lastIndex(of: id) {
            var startIndex = lastIndex
            while disk[safe: startIndex - 1] == id { startIndex -= 1 }
            let range = startIndex...lastIndex

            if let emptySpace = disk.firstRange(of: Array(repeating: nil, count: range.count)),
               emptySpace.lowerBound < range.lowerBound {
                for index in emptySpace {
                    disk[index] = id
                }

                for index in range {
                    disk[index] = nil
                }
            }
        }
    }

    return disk.indices.map { $0 * (disk[$0] ?? 0) }.reduce(0, +)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
