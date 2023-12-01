//
//  main.swift
//  Day1
//
//  Created by Marcin Chojnacki on 30/11/2023.
//

import Foundation

let lines = InputHelper.readInput().lines()

func partOne() throws -> Int {
    let example = """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """.lines()
    _ = example

    return try lines
        .map { line in
            let onlyNumbers = line.filter(\.isNumber)

            guard let firstNumber = onlyNumbers.first,
                  let lastNumber = onlyNumbers.last,
                  let number = Int("\(firstNumber)\(lastNumber)")
            else { throw Error("Line \(line) does not contain any numbers") }

            return number
        }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    let example = """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """.lines()
    _ = example

    let decimalDigits = [
        "zero": 0,
        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9
    ]

    return try lines
        .map { line in
            let numbersInLine = line.indices.lazy.compactMap { index in
                let substring = line[index...]

                if let firstCharacter = substring.first, let firstNumber = Int(String(firstCharacter)) {
                    return firstNumber
                } else if let key = decimalDigits.keys.first(where: substring.starts) {
                    return decimalDigits[key]
                } else {
                    return nil
                }
            }

            guard let firstNumber = numbersInLine.first,
                  let lastNumber = numbersInLine.last,
                  let number = Int("\(firstNumber)\(lastNumber)")
            else { throw Error("Line \(line) does not contain any numbers") }

            return number
        }
        .reduce(0, +)
}

doOrPrintError {
    print("Part 1:", try partOne())
    print("Part 2:", try partTwo())
}
