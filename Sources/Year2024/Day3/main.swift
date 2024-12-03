//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 03/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

func partOne() -> Int {
    let regex = /mul\((\d+),(\d+)\)/
    let matches = input.matches(of: regex)

    let sum = matches
        .compactMap { match in
            if let x = Int(match.output.1),
               let y = Int(match.output.2) {
                x * y
            } else {
                nil
            }
        }
        .reduce(0, +)

    return sum
}

func partTwo() -> Int {
    let regex = /do\(\)|don't\(\)|mul\((\d+),(\d+)\)/
    let matches = input.matches(of: regex)

    var enabled = true
    var result = 0

    for match in matches {
        switch match.output.0 {
        case "do()":
            enabled = true
        case "don't()":
            enabled = false
        default:
            if enabled,
               let xString = match.output.1,
               let yString = match.output.2,
               let x = Int(xString),
               let y = Int(yString) {
                result += x * y
            }
        }
    }

    return result
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
