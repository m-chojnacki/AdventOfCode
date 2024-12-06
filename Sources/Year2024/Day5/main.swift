//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 05/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""

let lines = input.trimmingCharacters(in: .whitespacesAndNewlines).lines()
let splitIndex = lines.firstIndex(of: "")!
let topLines = lines[0..<splitIndex]
let bottomLines = lines[(splitIndex + 1)...]

let orderingRules = Set(topLines.compactMap { line -> Coordinates? in
    let components = line.components(separatedBy: "|")
    guard components.count == 2,
          let first = Int(components[0]),
          let second = Int(components[1])
    else { return nil }

    return Coordinates(first, second)
})

let pageNumbers = bottomLines.map { line -> [Int] in
    line.components(separatedBy: ",").compactMap(Int.init)
}

func isPagesCorrect(_ pages: [Int]) -> Bool {
    var currentCorrect = true

    for index in pages.indices {
        let before = pages[0..<index]
        let this = pages[index]
        let after = pages[(index + 1)...]

        let beforeCorrect = !before
            .map { orderingRules.contains(Coordinates($0, this)) }
            .contains(false)

        let afterCorrect = !after
            .map { orderingRules.contains(Coordinates(this, $0)) }
            .contains(false)

        currentCorrect = currentCorrect && beforeCorrect && afterCorrect
    }

    return currentCorrect
}

func partOne() -> Int {
    pageNumbers
        .map { pages in isPagesCorrect(pages) ? pages[pages.count / 2] : 0 }
        .reduce(0, +)
}

func partTwo() -> Int {
    pageNumbers
        .filter { !isPagesCorrect($0) }
        .map { pages in
            var pages = pages
            var new = [Int]()
            new.reserveCapacity(pages.count)

            while !pages.isEmpty {
                let current = pages.removeLast()
                var whereToInsert = 0

                for index in new.indices {
                    if orderingRules.contains(Coordinates(current, new[index])) {
                        whereToInsert = index + 1
                    } else {
                        break
                    }
                }

                new.insert(current, at: whereToInsert)
            }

            return Array(new.reversed())
        }
        .map { pages in pages[pages.count / 2] }
        .reduce(0, +)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
