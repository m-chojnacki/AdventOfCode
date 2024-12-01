//
//  main.swift
//  Day10
//
//  Created by Marcin Chojnacki on 09/12/2023.
//

import Foundation
import Accelerate
import Shared

struct Direction: OptionSet {
    let rawValue: UInt

    static let up = Direction(rawValue: 1 << 0)
    static let down = Direction(rawValue: 1 << 1)
    static let left = Direction(rawValue: 1 << 2)
    static let right = Direction(rawValue: 1 << 3)
}

enum PipeChar: Character, CustomStringConvertible {
    case vertical = "|"         // | is a vertical pipe connecting north and south.
    case horizontal = "-"       // - is a horizontal pipe connecting east and west.
    case upRightBend = "L"      // L is a 90-degree bend connecting north and east.
    case upLeftBend = "J"       // J is a 90-degree bend connecting north and west.
    case downLeftBend = "7"     // 7 is a 90-degree bend connecting south and west.
    case downRightBend = "F"    // F is a 90-degree bend connecting south and east.
    case ground = "."           // . is ground; there is no pipe in this tile.
    case start = "S"            // S is the starting position of the animal.

    var description: String {
        String(rawValue)
    }

    var connections: Direction {
        switch self {
        case .vertical:
            [.up, .down]
        case .horizontal:
            [.left, .right]
        case .upRightBend:
            [.up, .right]
        case .upLeftBend:
            [.up, .left]
        case .downLeftBend:
            [.down, .left]
        case .downRightBend:
            [.down, .right]
        case .ground:
            []
        case .start:
            [.up, .down, .left, .right]
        }
    }

    var shape: [[UInt8]] {
        switch self {
        case .vertical:
            [
                [0, 1, 0],
                [0, 1, 0],
                [0, 1, 0]
            ]
        case .horizontal:
            [
                [0, 0, 0],
                [1, 1, 1],
                [0, 0, 0]
            ]
        case .upRightBend:
            [
                [0, 1, 0],
                [0, 1, 1],
                [0, 0, 0]
            ]
        case .upLeftBend:
            [
                [0, 1, 0],
                [1, 1, 0],
                [0, 0, 0]
            ]
        case .downLeftBend:
            [
                [0, 0, 0],
                [1, 1, 0],
                [0, 1, 0]
            ]
        case .downRightBend:
            [
                [0, 0, 0],
                [0, 1, 1],
                [0, 1, 0]
            ]
        case .ground:
            [
                [0, 0, 0],
                [0, 0, 0],
                [0, 0, 0]
            ]
        case .start:
            [
                [0, 1, 0],
                [1, 1, 1],
                [0, 1, 0]
            ]
        }
    }
}

final class PipeNode {
    let char: PipeChar
    let coordinates: Coordinates
    var up: PipeNode?
    var down: PipeNode?
    var left: PipeNode?
    var right: PipeNode?

    init(
        char: PipeChar,
        coordinates: Coordinates,
        up: PipeNode? = nil,
        down: PipeNode? = nil,
        left: PipeNode? = nil,
        right: PipeNode? = nil
    ) {
        self.char = char
        self.coordinates = coordinates
        self.up = up
        self.down = down
        self.left = left
        self.right = right
    }
}

let lines = PackageResources.input_txt.string.lines()

func parseInput(_ input: [String]) -> [[PipeChar]] {
    input.map { $0.compactMap(PipeChar.init(rawValue:)) }
}

func buildNodesGraph(_ input: [[PipeChar]]) throws -> PipeNode {
    guard let startRowIndex = input.firstIndex(where: { $0.contains(.start) }),
          let startColumnIndex = input[startRowIndex].firstIndex(of: .start)
    else { throw Error("Input has no starting point") }

    var coordinatesMap: [Coordinates: PipeNode] = [:]

    for row in input.indices {
        for col in input[row].indices {
            let char = input[row][col]
            let coordinates = Coordinates(row, col)

            coordinatesMap[coordinates] = PipeNode(char: char, coordinates: coordinates)
        }
    }

    for row in input.indices {
        for col in input[row].indices {
            let coordinates = Coordinates(row, col)
            let upCoordinates = Coordinates(row - 1, col)
            let downCoordinates = Coordinates(row + 1, col)
            let leftCoordinates = Coordinates(row, col - 1)
            let rightCoordinates = Coordinates(row, col + 1)

            let current = coordinatesMap[coordinates]
            let upCurrent = coordinatesMap[upCoordinates]
            let downCurrent = coordinatesMap[downCoordinates]
            let leftCurrent = coordinatesMap[leftCoordinates]
            let rightCurrent = coordinatesMap[rightCoordinates]

            if current?.char.connections.contains(.up) == true,
               upCurrent?.char.connections.contains(.down) == true {
                current?.up = upCurrent
            }

            if current?.char.connections.contains(.down) == true,
               downCurrent?.char.connections.contains(.up) == true {
                current?.down = downCurrent
            }

            if current?.char.connections.contains(.left) == true,
               leftCurrent?.char.connections.contains(.right) == true {
                current?.left = leftCurrent
            }

            if current?.char.connections.contains(.right) == true,
               rightCurrent?.char.connections.contains(.left) == true {
                current?.right = rightCurrent
            }
        }
    }

    if let entry = coordinatesMap[Coordinates(startRowIndex, startColumnIndex)] {
        return entry
    } else {
        throw Error("Parsed coordinates have no starting point")
    }
}

func traversePipes(_ entry: PipeNode) throws -> [PipeNode] {
    var pipes: [PipeNode] = []
    var current = entry
    var previous: PipeNode?

    repeat {
        let loopCurrent = current

        if let up = current.up, up !== previous {
            current = up
        } else if let down = current.down, down !== previous {
            current = down
        } else if let left = current.left, left !== previous {
            current = left
        } else if let right = current.right, right !== previous {
            current = right
        } else {
            throw Error("Pipe has a dead end")
        }

        pipes.append(loopCurrent)
        previous = loopCurrent
    } while current !== entry

    return pipes
}

func partOne() throws -> Int {
    let example = """
    ..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...
    """.lines()
    _ = example

    return try traversePipes(buildNodesGraph(parseInput(lines))).count / 2
}

func partTwo() throws -> Int {
    let example = """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """.lines()
    _ = example

    let input = parseInput(lines)
    let pipeCoordinates = try Set(traversePipes(buildNodesGraph(input)).map(\.coordinates))

    var buffer = vImage_Buffer()
    vImageBuffer_Init(
        &buffer,
        vImagePixelCount(input.count * 3) + 2,      // height * shape size + 2 px border
        vImagePixelCount(input[0].count * 3) + 2,   // width * shape size + 2 px border
        8,                                          // 8 bpp is the least possible value
        vImage_Flags(kvImageNoFlags)
    )

    let bufferPointer = buffer.data.assumingMemoryBound(to: UInt8.self)
    bufferPointer.update(repeating: 0, count: Int(buffer.height) * buffer.rowBytes)

    // Let's paint pipes to the buffer: white is pipe, black is ground
    for y in input.indices {
        for x in input[y].indices {
            let current = input[y][x]
            let isPipe = pipeCoordinates.contains(Coordinates(y, x))

            for shapeY in 0..<3 {
                for shapeX in 0..<3 {
                    let globalY = y * 3 + shapeY + 1
                    let globalX = x * 3 + shapeX + 1

                    if isPipe {
                        let shape = current.shape[shapeY][shapeX]
                        bufferPointer[globalY * buffer.rowBytes + globalX] = shape == 1 ? 255 : 0
                    } else {
                        bufferPointer[globalY * buffer.rowBytes + globalX] = 0
                    }
                }
            }
        }
    }

    // Accelerate has super-performant flood-fill algorithm so let's use it
    vImageFloodFill_Planar8(&buffer, nil, 0, 0, 255, 8, vImage_Flags(kvImageNoFlags))

    // Let's paint pipes again, all white, to distinguish pipe from background
    for y in input.indices {
        for x in input[y].indices {
            let isPipe = pipeCoordinates.contains(Coordinates(y, x))

            for shapeY in 0..<3 {
                for shapeX in 0..<3 {
                    let globalY = y * 3 + shapeY + 1
                    let globalX = x * 3 + shapeX + 1

                    if isPipe {
                        bufferPointer[globalY * buffer.rowBytes + globalX] = 255
                    }
                }
            }
        }
    }

    // Every pixel not covered with flood-fill is inside the pipe
    var notFilledPixelsCount = 0
    for y in 0..<buffer.height {
        for x in 0..<buffer.width {
            if bufferPointer[Int(y) * buffer.rowBytes + Int(x)] == 0 {
                notFilledPixelsCount += 1
            }
        }
    }

    // 9 because shape is 3x3
    return notFilledPixelsCount / 9
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
