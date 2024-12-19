//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 19/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
"""

typealias Pattern = Array<Character>
typealias PatternSlice = ArraySlice<Character>
typealias PatternsPath = Array<Pattern>

func parse() -> ([Pattern], [Pattern]) {
    var lines = input.lines()

    let patterns = lines
        .removeFirst()
        .split(separator: ", ")
        .map(Array.init)

    lines.removeFirst()

    let actual = lines.map(Array.init)

    return (patterns, actual)
}

func partOne() -> Int {
    let (patterns, all) = parse()

    func hasPatterns(for remainingTowels: PatternSlice) -> Bool {
        for testedPattern in patterns where remainingTowels.starts(with: testedPattern) {
            let newRemaining = remainingTowels[(remainingTowels.startIndex + testedPattern.count)...]

            if newRemaining.isEmpty || hasPatterns(for: newRemaining) {
                return true
            }
        }

        return false
    }

    return all
        .map { hasPatterns(for: PatternSlice($0)) }
        .count(where: { $0 })
}

func partTwo() -> Int {
    let (patterns, all) = parse()

    var cache = [PatternSlice: Int]()

    func findPatterns(for remainingTowels: PatternSlice) -> Int {
        if remainingTowels.isEmpty {
            return 1
        }

        if let cached = cache[remainingTowels] {
            return cached
        }

        var arrangements = 0

        for testedPattern in patterns where remainingTowels.starts(with: testedPattern) {
            let newRemaining = remainingTowels[(remainingTowels.startIndex + testedPattern.count)...]

            arrangements += findPatterns(for: newRemaining)
        }

        cache[remainingTowels] = arrangements

        return arrangements
    }

    return all
        .map { findPatterns(for: PatternSlice($0)) }
        .reduce(0, +)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
