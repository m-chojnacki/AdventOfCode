//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 13/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""

struct Instruction {
    let aX, aY: Int
    let bX, bY: Int
    let prizeX, prizeY: Int

    func goCrazy() -> Instruction {
        Instruction(
            aX: aX, aY: aY,
            bX: bX, bY: bY,
            prizeX: prizeX + 10000000000000, prizeY: prizeY + 10000000000000
        )
    }
}

let instructions = input
    .matches(of: /Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)/)
    .map {
        Instruction(
            aX: Int($0.output.1)!, aY: Int($0.output.2)!,
            bX: Int($0.output.3)!, bY: Int($0.output.4)!,
            prizeX: Int($0.output.5)!, prizeY: Int($0.output.6)!
        )
    }

func partOne(_ instructions: [Instruction] = instructions) -> Int {
    // prizeX = i * aX + j * bX
    // prizeY = i * aY + j * bY
    // tokens = i * 3 + j * 1

    func optimizeTokens(prizeX: Double, prizeY: Double, aX: Double, aY: Double, bX: Double, bY: Double) -> (i: Double, j: Double, tokens: Double)? {
        let tolerance = 0.001
        func isAlmostInteger(_ value: Double) -> Bool {
            abs(value - value.rounded()) < tolerance
        }

        let constants = [prizeX, prizeY]
        let determinant = aX * bY - aY * bX

        guard abs(determinant) >= tolerance else { return nil }

        let invMatrix = [
            [bY / determinant, -bX / determinant],
            [-aY / determinant, aX / determinant]
        ]

        let i = invMatrix[0][0] * constants[0] + invMatrix[0][1] * constants[1]
        let j = invMatrix[1][0] * constants[0] + invMatrix[1][1] * constants[1]

        guard isAlmostInteger(i), isAlmostInteger(j) else { return nil }

        let tokens = i * 3 + j * 1

        return (i, j, tokens)
    }

    func optimizeTokens(_ instruction: Instruction) -> (i: Int, j: Int, tokens: Int)? {
        guard let optimization = optimizeTokens(
            prizeX: Double(instruction.prizeX),
            prizeY: Double(instruction.prizeY),
            aX: Double(instruction.aX),
            aY: Double(instruction.aY),
            bX: Double(instruction.bX),
            bY: Double(instruction.bY)
        ) else {
            return nil
        }

        return (Int(optimization.i.rounded()), Int(optimization.j.rounded()), Int(optimization.tokens.rounded()))
    }

    return instructions
        .compactMap { instruction -> Int? in
            guard let optimization = optimizeTokens(instruction) else { return nil }

            return optimization.tokens
        }
        .reduce(0, +)
}

func partTwo() -> Int {
    partOne(instructions.map { $0.goCrazy() })
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
