//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 14/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
//let spaceX = 101
//let spaceY = 103

let input = """
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
"""
let spaceX = 11
let spaceY = 7

struct Robot: CustomStringConvertible {
    var pX, pY: Int
    let vX, vY: Int

    var description: String {
        "p=\(pX),\(pY) v=\(vX),\(vY)"
    }
}

let robots = input
    .matches(of: /p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/)
    .map {
        Robot(
            pX: Int($0.output.1)!, pY: Int($0.output.2)!,
            vX: Int($0.output.3)!, vY: Int($0.output.4)!
        )
    }

func moveRobots(_ robots: inout [Robot]) {
    for index in robots.indices {
        robots[index].pX += robots[index].vX
        robots[index].pY += robots[index].vY

        if robots[index].pX < 0 {
            robots[index].pX = spaceX + robots[index].pX % spaceX
        } else if robots[index].pX >= spaceX {
            robots[index].pX %= spaceX
        }

        if robots[index].pY < 0 {
            robots[index].pY = spaceY + robots[index].pY % spaceY
        } else if robots[index].pY >= spaceY {
            robots[index].pY %= spaceY
        }
    }
}

func partOne() -> Int {
    var robots = robots

    for _ in 0..<100 {
        moveRobots(&robots)
    }

    let q1 = robots.count(where: { $0.pX < spaceX / 2 && $0.pY < spaceY / 2 })
    let q2 = robots.count(where: { $0.pX > spaceX / 2 && $0.pY < spaceY / 2 })
    let q3 = robots.count(where: { $0.pX < spaceX / 2 && $0.pY > spaceY / 2 })
    let q4 = robots.count(where: { $0.pX > spaceX / 2 && $0.pY > spaceY / 2 })

    return q1 * q2 * q3 * q4
}

func partTwo() -> Int {
    var robots = robots

    func printRobots() -> String {
        var string = ""

        for x in 0..<spaceX {
            for y in 0..<spaceY {
                if robots.contains(where: { $0.pX == x && $0.pY == y }) {
                    string += "█"
                } else {
                    string += " "
                }
            }
            string += "\n"
        }

        return string
    }

    // X-mas tree will probably have solid elements
    var i = 0
    while !printRobots().contains("██████████") {
        moveRobots(&robots)
        i += 1
    }

    return i
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
