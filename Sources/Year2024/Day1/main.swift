//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 01/12/2024.
//

import Foundation
import Shared

let input = PackageResources.input_txt.string
//let input = """
//3   4
//4   3
//2   5
//1   3
//3   9
//3   3
//"""

func partOne() -> Int {
    let (first, second) = input
        .lines()
        .map { $0.split(separator: " ").compactMap { Int($0) } }
        .filter { $0.count == 2 }
        .compactMap { ($0[0], $0[1]) }
        .unzip()

    return zip(first.sorted(), second.sorted())
        .map { abs($0.0 - $0.1) }
        .reduce(0, +)
}

func partTwo() -> Int {
    let (first, second) = input
        .lines()
        .map { $0.split(separator: " ").compactMap { Int($0) } }
        .filter { $0.count == 2 }
        .compactMap { ($0[0], $0[1]) }
        .unzip()

    let counts = second.reduce(into: [Int: Int]()) { result, current in
        result[current] = (result[current] ?? 0) + 1
    }

    return first
        .map { $0 * (counts[$0] ?? 0) }
        .reduce(0, +)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
