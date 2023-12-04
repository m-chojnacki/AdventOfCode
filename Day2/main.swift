//
//  main.swift
//  Day2
//
//  Created by Marcin Chojnacki on 01/12/2023.
//

import Foundation

let example = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
""".lines()
_ = example

let lines = InputHelper.readInput().lines()

enum Color: String {
    case red
    case green
    case blue
}

typealias Cubes = [Color: Int]

struct GameSet {
    let cubes: Cubes

    func isPossible(having initialCubes: Cubes) -> Bool {
        cubes.map { color, number in
            guard let initialCubesColor = initialCubes[color] else { return false }

            return initialCubesColor >= number
        }.allSatisfy { isPossible in
            isPossible
        }
    }
}

struct Game {
    let id: Int
    let sets: [GameSet]

    func isPossible(having initialCubes: Cubes) -> Bool {
        sets.map { set in
            set.isPossible(having: initialCubes)
        }.allSatisfy { isPossible in
            isPossible
        }
    }

    func minPossible() -> Cubes {
        sets.reduce(into: Cubes()) { result, set in
            for (color, value) in set.cubes {
                if let resultColor = result[color] {
                    result[color] = max(resultColor, value)
                } else {
                    result[color] = value
                }
            }
        }
    }
}

func parseLine(_ line: String) throws -> Game {
    let colonSeparatedParts = line.components(separatedBy: ":")
    guard colonSeparatedParts.count == 2,
          let idPart = colonSeparatedParts.first,
          let setsPart = colonSeparatedParts.last
    else { throw Error("Line \(line) does not contain colon separated elements") }

    let idPartElements = idPart.components(separatedBy: .whitespaces)
    guard idPartElements.count == 2,
          idPartElements.first == "Game",
          let idPartId = idPartElements.last,
          let id = Int(idPartId)
    else { throw Error("Game ID part is not valid in line \(line)") }

    let sets = try setsPart.components(separatedBy: ";").map { set in
        let cubes = try set.components(separatedBy: ",").map { cube in
            let cubeSplit = cube.split(separator: " ")
            guard cubeSplit.count == 2,
                  let numberPart = cubeSplit.first,
                  let number = Int(numberPart),
                  let colorPart = cubeSplit.last,
                  let color = Color(rawValue: String(colorPart))
            else { throw Error("Game sets part is not valid in line \(line)") }

            return (color, number)
        }

        return GameSet(cubes: Dictionary(uniqueKeysWithValues: cubes))
    }

    return Game(id: id, sets: sets)
}

let games = try lines.map(parseLine)

func partOne() throws -> Int {
    games
        .compactMap { game in
            if game.isPossible(having: [.red: 12, .green: 13, .blue: 14]) {
                return game.id
            } else {
                return nil
            }
        }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    games
        .map { game in
            game.minPossible().values.reduce(1, *)
        }
        .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
