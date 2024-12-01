//
//  main.swift
//  Day6
//
//  Created by Marcin Chojnacki on 05/12/2023.
//

import Foundation
import Shared

let example = """
Time:      7  15   30
Distance:  9  40  200
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

struct Race {
    let time: Int
    let distance: Int

    func waysOfWinning() -> Int {
        (0...time)
            .lazy
            .map { $0 * (time - $0) }
            .filter { $0 > distance}
            .count
    }
}

func parseInput(_ lines: [String]) throws -> [Race] {
    guard let timeLine = lines.first(where: { $0.hasPrefix("Time") }),
          let distanceLine = lines.first(where: { $0.hasPrefix("Distance") })
    else { throw Error("Input has no time or distance") }

    let time = timeLine.split(separator: " ").map(String.init).compactMap(Int.init)
    let distance = distanceLine.split(separator: " ").map(String.init).compactMap(Int.init)

    return zip(time, distance).map { Race(time: $0.0, distance: $0.1) }
}

let input = try parseInput(lines)

func partOne() throws -> Int {
    input
        .map { $0.waysOfWinning() }
        .reduce(1, *)
}

func partTwo() throws -> Int {
    let kerningFixed = input.reduce(("", "")) { result, race in
        ("\(result.0)\(race.time)", "\(result.1)\(race.distance)")
    }
    guard let time = Int(kerningFixed.0), let distance = Int(kerningFixed.1)
    else { throw Error("Time or distance malformed in input") }

    let race = Race(time: time, distance: distance)

    return race.waysOfWinning()
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
