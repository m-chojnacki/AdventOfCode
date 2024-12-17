//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 17/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
"""

struct Computer {
    var regA: Int
    var regB: Int
    var regC: Int
    var program: [Int]
    var ip = 0
}

enum Opcode: Int {
    case adv = 0
    case bxl = 1
    case bst = 2
    case jnz = 3
    case bxc = 4
    case out = 5
    case bdv = 6
    case cdv = 7
}

func parse() -> Computer {
    let match = input.firstMatch(of: /Register A: (\d+)\nRegister B: (\d+)\nRegister C: (\d+)\n\nProgram: ([\d,]+)/)!

    return Computer(
        regA: Int(match.output.1)!,
        regB: Int(match.output.2)!,
        regC: Int(match.output.3)!,
        program: match.output.4.split(separator: ",").map { Int($0)! }
    )
}

func runProgram(_ computer: inout Computer) -> [Int]? {
    var output = [Int]()
    output.reserveCapacity(32)

    func combo(_ operand: Int) -> Int {
        switch operand {
        case 0...3: operand
        case 4: computer.regA
        case 5: computer.regB
        case 6: computer.regC
        default: fatalError("Invalid operand \(operand)")
        }
    }

    while computer.ip < computer.program.count {
        let opcode = Opcode(rawValue: computer.program[computer.ip])!
        let operand = computer.program[computer.ip + 1]

        switch opcode {
        case .adv:
            let div = 1 << combo(operand)
            guard div != 0 else { return nil }
            computer.regA = computer.regA / div
        case .bxl:
            computer.regB = computer.regB ^ operand
        case .bst:
            computer.regB = combo(operand) % 8
        case .jnz:
            if computer.regA != 0 {
                computer.ip = operand - 2
            }
        case .bxc:
            computer.regB = computer.regB ^ computer.regC
        case .out:
            output.append(combo(operand) % 8)
        case .bdv:
            let div = 1 << combo(operand)
            guard div != 0 else { return nil }
            computer.regB = computer.regA / div
        case .cdv:
            let div = 1 << combo(operand)
            guard div != 0 else { return nil }
            computer.regC = computer.regA / div
        }

        computer.ip += 2
    }

    return output
}

func partOne() -> String {
    var computer = parse()
    let output = runProgram(&computer)

    return output!
        .map(String.init)
        .joined(separator: ",")
}

func partTwo() -> Int {
    let ogComputer = parse()
    let program = ogComputer.program

    func tryValue(_ i: Int) -> [Int]? {
        var computer = ogComputer
        computer.regA = i

        return runProgram(&computer)
    }

    // Some manual bisection action here...
    //  1. I found a range in which count of output == 16 (count of program).
    //  2. I strided through this range trying to find each next digit.
    //  3. I brute-forced the result on the last matching stride.
    for i in 0... {
        if tryValue(i) == program {
            return i
        }
    }

    return -1
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
