//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 11/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = "125 17"

let stones = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .components(separatedBy: .whitespaces)
    .compactMap(Int.init)

func partOne() -> Int {
    // Naive iterative solution
    func blink(_ stones: [Int]) -> [Int] {
        stones.flatMap { stone in
            if stone == 0 {
                return [1]
            } else {
                let stringStone = String(stone)

                if stringStone.count % 2 == 0  {
                    let middleIndex = stringStone.index(stringStone.startIndex, offsetBy: stringStone.count / 2)
                    let firstHalf = stringStone[..<middleIndex]
                    let secondHalf = stringStone[middleIndex...]

                    return [Int(firstHalf)!, Int(secondHalf)!]
                } else {
                    return [stone * 2024]
                }
            }
        }
    }

    var blinked = stones
    for _ in 0..<25 {
        blinked = blink(blinked)
    }

    return blinked.count
}

func partTwo() -> Int {
    // Resursive DP variant
    var cache = [Coordinates: Int]()

    func countStones(_ stones: [Int], depth: Int) -> Int {
        guard depth > 0 else { return stones.count }

        var count = 0
        for stone in stones {
            let key = Coordinates(stone, depth)
            let increment: Int

            if let cached = cache[key] {
                increment = cached
            } else {
                if stone == 0 {
                    increment = countStones([1], depth: depth - 1)
                } else {
                    let stringStone = String(stone)

                    if stringStone.count % 2 == 0  {
                        let middleIndex = stringStone.index(stringStone.startIndex, offsetBy: stringStone.count / 2)
                        let firstHalf = stringStone[..<middleIndex]
                        let secondHalf = stringStone[middleIndex...]

                        increment = countStones([Int(firstHalf)!, Int(secondHalf)!], depth: depth - 1)
                    } else {
                        increment = countStones([stone * 2024], depth: depth - 1)
                    }
                }

                cache[key] = increment
            }

            count += increment
        }

        return count
    }

    return countStones(stones, depth: 75)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
