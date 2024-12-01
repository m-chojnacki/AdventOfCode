//
//  main.swift
//  Day7
//
//  Created by Marcin Chojnacki on 06/12/2023.
//

import Foundation
import Shared

let example = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

enum HandType {
    case fiveOfKind
    case fourOfKind
    case fullHouse
    case threeOfKind
    case twoPair
    case onePair
    case highCard

    var strength: Int {
        switch self {
        case .fiveOfKind: 7
        case .fourOfKind: 6
        case .fullHouse: 5
        case .threeOfKind: 4
        case .twoPair: 3
        case .onePair: 2
        case .highCard: 1
        }
    }
}

struct Input: CustomStringConvertible {
    enum Card: Character {
        case cardA = "A"
        case cardK = "K"
        case cardQ = "Q"
        case cardT = "T"
        case card9 = "9"
        case card8 = "8"
        case card7 = "7"
        case card6 = "6"
        case card5 = "5"
        case card4 = "4"
        case card3 = "3"
        case card2 = "2"
        case cardJ = "J"

        func strength(jIsJoker: Bool) -> Int {
            switch self {
            case .cardA: 14
            case .cardK: 13
            case .cardQ: 12
            case .cardJ: jIsJoker ? 1 : 11
            case .cardT: 10
            case .card9: 9
            case .card8: 8
            case .card7: 7
            case .card6: 6
            case .card5: 5
            case .card4: 4
            case .card3: 3
            case .card2: 2
            }
        }
    }

    let hand: [Card]
    let bid: Int

    var description: String {
        "(hand: \(hand.map(\.rawValue).map(String.init).joined()), bid: \(bid))"
    }

    var handMap: [Card: Int] {
        Dictionary(hand.map { ($0, 1) }, uniquingKeysWith: { $0 + $1 })
    }

    func handType(jIsJoker: Bool) throws -> HandType {
        switch handMap.filter({ jIsJoker ? $0.key != .cardJ : true }).values.sorted() {
        case [5], [4], [3], [2], [1], []: return .fiveOfKind       // 0, 1, 2, 3, 4, 5 jokers
        case [1, 4], [1, 3], [1, 2], [1, 1]: return .fourOfKind    // 0, 1, 2, 3 jokers
        case [2, 3], [2, 2]: return .fullHouse                     // 0, 1 jokers - better go with `.fourOfKind`
        case [1, 1, 3], [1, 1, 2], [1, 1, 1]: return .threeOfKind  // 0, 1, 2 jokers
        case [1, 2, 2]: return .twoPair                            // 0 jokers - better go with `.threeOfKind`
        case [1, 1, 1, 2], [1, 1, 1, 1]: return .onePair           // 0, 1 jokers
        case [1, 1, 1, 1, 1]: return .highCard                     // 0 jokers
        default: throw Error("Unhandled hand type")
        }
    }

    func strength(jIsJoker: Bool) throws -> Int {
        try handType(jIsJoker: jIsJoker).strength * 10000000000 +
            hand[0].strength(jIsJoker: jIsJoker) * 100000000 +
            hand[1].strength(jIsJoker: jIsJoker) * 1000000 +
            hand[2].strength(jIsJoker: jIsJoker) * 10000 +
            hand[3].strength(jIsJoker: jIsJoker) * 100 +
            hand[4].strength(jIsJoker: jIsJoker)
    }
}

func parseInput(_ lines: [String]) throws -> [Input] {
    try lines.map { line in
        let array = line.components(separatedBy: .whitespaces)
        guard array.count == 2, let handString = array.first, let bid = array.last.flatMap(Int.init)
        else { throw Error("Line \(line) is malformed") }

        let hand = handString.compactMap(Input.Card.init(rawValue:))
        guard hand.count == 5 else { throw Error("Hand \(hand) has wrong cards") }

        return Input(hand: hand, bid: bid)
    }
}

let input = try parseInput(lines)

func partOne(jIsJoker: Bool = false) throws -> Int {
    try input
        .sorted(by: { try $0.strength(jIsJoker: jIsJoker) > $1.strength(jIsJoker: jIsJoker) })
        .enumerated()
        .map { index, value in (input.count - index) * value.bid }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    try partOne(jIsJoker: true)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
