//
//  main.swift
//  Day5
//
//  Created by Marcin Chojnacki on 04/12/2023.
//

import Foundation
import Shared

let example = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
""".lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

struct Input {
    enum Map: String, CaseIterable {
        case seedToSoil = "seed-to-soil"
        case soilToFertilizer = "soil-to-fertilizer"
        case fertilizerToWater = "fertilizer-to-water"
        case waterToLight = "water-to-light"
        case lightToTemperature = "light-to-temperature"
        case temperatureToHumidity = "temperature-to-humidity"
        case humidityToLocation = "humidity-to-location"
    }

    struct Ranges {
        let destination: Int
        let source: Int
        let length: Int

        var sourceRange: ClosedRange<Int> {
            source...(source + length)
        }

        var offset: Int {
            destination - source
        }
    }

    let seeds: [Int]
    let maps: [Map: [Ranges]]

    func map(seed: Int, to map: Map) -> Int {
        if let ranges = maps[map]?.first(where: { $0.sourceRange.contains(seed) }) {
            seed + ranges.offset
        } else {
            seed
        }
    }

    func map(seed: Int, to maps: [Map]) -> Int {
        maps.reduce(seed) { value, map in
            input.map(seed: value, to: map)
        }
    }

    func mapAllSeeds(to maps: [Map] = Input.Map.allCases) -> [Int] {
        seeds.map { map(seed: $0, to: maps) }
    }
}

extension Array where Element == Int {
    func everySecondRanges() -> [ClosedRange<Int>] {
        (0..<(count / 2)).map { everySecondIndex in
            let index = everySecondIndex * 2
            let value = self[index]

            return value...(value + self[index + 1] - 1)
        }
    }
}

func parseInput() throws -> Input {
    let groups = lines
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .split(separator: "")

    guard let seedsGroup = groups.first(where: { $0.first?.hasPrefix("seeds") == true })?.first
    else { throw Error("Input has no seeds group") }

    let seeds = seedsGroup
        .components(separatedBy: .whitespaces)
        .compactMap(Int.init)

    let maps = try Input.Map.allCases.compactMap { map in
        guard let currentGroup = groups.first(where: { $0.first?.hasPrefix(map.rawValue) == true })
        else { throw Error("Input has no \(map.rawValue) group") }

        let ranges = try currentGroup
            .dropFirst()
            .map { ranges in
                let intRanges = ranges.components(separatedBy: .whitespaces).compactMap(Int.init)
                guard intRanges.count == 3 else { throw Error("Ranges \(ranges) have components != 3") }

                return Input.Ranges(destination: intRanges[0], source: intRanges[1], length: intRanges[2])
            }

        return (map, ranges)
    }

    return Input(seeds: seeds, maps: Dictionary(uniqueKeysWithValues: maps))
}

let input = try parseInput()

func partOne() throws -> Int? {
    input
        .mapAllSeeds()
        .min()
}

func partTwo() throws -> Int? {
    // Trivial solution mapping all ranges to single elements
    input.seeds
        .everySecondRanges()
        .lazy
        .flatMap(Array.init)
        .map { input.map(seed: $0, to: Input.Map.allCases) }
        .min()
}

print("Part 1:", try partOne() as Any)
print("Part 2:", try partTwo() as Any)
