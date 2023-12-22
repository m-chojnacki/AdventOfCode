//
//  main.swift
//  Day22
//
//  Created by Marcin Chojnacki on 22/12/2023.
//

import Foundation

let example = #"""
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
"""#.lines()
_ = example

let lines = InputHelper.readInput().lines()

struct Coord: Hashable, CustomStringConvertible {
    let x, y, z: Int

    var description: String {
        "(\(x), \(y), \(z)"
    }

    func moved(_ other: Coord) -> Coord {
        Coord(x: x + other.x, y: y + other.y, z: z + other.z)
    }
}

struct Input: Equatable {
    let first: Coord
    let second: Coord

    static var floor: Input {
        Input(
            first: Coord(x: .min, y: .min, z: 0),
            second: Coord(x: .max - 1, y: .max - 1, z: 0)
        )
    }

    var correctedSecond: Coord {
        Coord(x: second.x + 1, y: second.y + 1, z: second.z + 1)
    }

    func colidesWith(_ other: Input) -> Bool {
        first.x < other.correctedSecond.x &&
        correctedSecond.x > other.first.x &&
        first.y < other.correctedSecond.y &&
        correctedSecond.y > other.first.y &&
        first.z < other.correctedSecond.z &&
        correctedSecond.z > other.first.z
    }

    func moved(_ other: Coord) -> Input {
        Input(first: first.moved(other), second: second.moved(other))
    }
}

func parseInput(_ input: [String]) throws -> [Input] {
    try input.map { line in
        let parts = line.components(separatedBy: "~")
        guard parts.count == 2, let first = parts.first, let last = parts.last
        else { throw Error("No tilde separated parts in line: \(line)") }

        let firstInts = first.components(separatedBy: ",").compactMap(Int.init)
        let lastInts = last.components(separatedBy: ",").compactMap(Int.init)
        guard firstInts.count == 3, lastInts.count == 3
        else { throw Error("No integer coordinates in line: \(line)") }

        return Input(
            first: Coord(x: firstInts[0], y: firstInts[1], z: firstInts[2]),
            second: Coord(x: lastInts[0], y: lastInts[1], z: lastInts[2])
        )
    }
}

let input = try parseInput(lines)

func fallingBricksDown(_ zSorted: [Input]) -> [Input] {
    var zSorted = zSorted

    for i in zSorted.indices {
        var noCollision = true

        while noCollision {
            zSorted[i] = zSorted[i].moved(Coord(x: 0, y: 0, z: -1))

            noCollision = (zSorted + [.floor])
                .enumerated()
                .filter { index, _ in index != i }
                .allSatisfy { !zSorted[i].colidesWith($0.element) }
        }

        // Move up one layer because one check moves it down one layer and we check at least once
        zSorted[i] = zSorted[i].moved(Coord(x: 0, y: 0, z: 1))
    }

    return zSorted
}

func partOne() throws -> Int {
    var zSorted = input.sorted(by: { $0.first.z < $1.first.z })
    zSorted = fallingBricksDown(zSorted)

    return zSorted
        .indices
        .map { i in
            let withoutCurrent = zSorted
                .enumerated()
                .filter { index, _ in index != i }
                .map(\.element)

            let fallen = fallingBricksDown(withoutCurrent)

            return fallen == withoutCurrent ? 1 : 0
        }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    var zSorted = input.sorted(by: { $0.first.z < $1.first.z })
    zSorted = fallingBricksDown(zSorted)

    return zSorted.indices.map { i in
        let withoutCurrent = zSorted
            .enumerated()
            .filter { index, _ in index != i }
            .map(\.element)

        let fallen = fallingBricksDown(withoutCurrent)

        return zip(fallen, withoutCurrent)
            .map { $0.0 != $0.1 ? 1 : 0 }
            .reduce(0, +)
    }
    .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
