//
//  main.swift
//  Day17
//
//  Created by Marcin Chojnacki on 17/12/2023.
//

import Shared

let example = #"""
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""#.lines()
_ = example

let lines = PackageResources.input_txt.string.lines()

let input = lines.map { $0.compactMap { Int(String($0)) } }.filter { !$0.isEmpty }

func partOne() throws -> Int {
    return 0
}

func partTwo() throws -> Int {
    return 0
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
