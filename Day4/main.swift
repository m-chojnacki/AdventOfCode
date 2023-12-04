//
//  main.swift
//  Day4
//
//  Created by Marcin Chojnacki on 03/12/2023.
//

import Foundation

let example = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
""".lines()
_ = example

let lines = InputHelper.readInput().lines()

struct Card {
    let number: Int
    let winning: Set<Int>
    let yours: Set<Int>

    func wins() -> Int {
        yours.intersection(winning).count
    }

    func points() -> Int {
        2 << (wins() - 2)
    }
}

func parseLine(_ line: String) throws -> Card {
    let colonSeparatedParts = line.components(separatedBy: ":")
    guard colonSeparatedParts.count == 2,
          let cardPart = colonSeparatedParts.first,
          let numbersPart = colonSeparatedParts.last
    else { throw Error("Line \(line) does not contain colon separated elements") }

    let cardPartElements = cardPart.split(separator: " ")
    guard cardPartElements.count == 2,
          cardPartElements.first == "Card",
          let cardPartNumber = cardPartElements.last,
          let number = Int(cardPartNumber)
    else { throw Error("Card number part is not valid in line \(line)") }

    let numbersPartElements = numbersPart.components(separatedBy: "|")
    guard numbersPartElements.count == 2,
          let winningNumbersElements = numbersPartElements.first,
          let yoursNumbersElements = numbersPartElements.last
    else { throw Error("Numbers part is not valid in line \(line)") }

    let winning = Set(winningNumbersElements.components(separatedBy: .whitespaces).compactMap(Int.init))
    let yours = Set(yoursNumbersElements.components(separatedBy: .whitespaces).compactMap(Int.init))

    return Card(number: number, winning: winning, yours: yours)
}

let cards = try lines.map(parseLine)

func partOne() throws -> Int {
    cards
        .map { $0.points() }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    var cardsCount = Dictionary(uniqueKeysWithValues: cards.map { ($0.number, 1) })

    for card in cards {
        let wins = card.wins()

        if wins > 0 {
            let wonCardNumbers = (card.number + 1)...(card.number + wins)
            let cardCount = cardsCount[card.number] ?? 1

            for wonCardNumber in wonCardNumbers {
                cardsCount[wonCardNumber] = cardsCount[wonCardNumber]?.advanced(by: cardCount)
            }
        }
    }

    return cardsCount
        .values
        .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
