//
//  main.swift
//  Day15
//
//  Created by Marcin Chojnacki on 15/12/2023.
//

import Foundation
import Shared

let example = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
_ = example

let lines = PackageResources.input_txt.string.trimmingCharacters(in: .whitespacesAndNewlines)

let input = lines.components(separatedBy: ",")

func hash(_ string: String) -> Int {
    var hash = 0

    for ascii in Array(string).compactMap(\.asciiValue) {
        hash += Int(ascii)
        hash *= 17
        hash %= 256
    }

    return hash
}

struct Step {
    enum Operation {
        case set(Int)
        case remove
    }

    let label: String
    let operation: Operation
}

struct Slot: CustomStringConvertible {
    let label: String
    let value: Int

    var description: String {
        "\(label) \(value)"
    }
}

func partOne() throws -> Int {
    input
        .map { hash($0) }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    let steps = input.compactMap { step in
        if step.hasSuffix("-") {
            return Step(label: String(step.dropLast()), operation: .remove)
        } else {
            let components = step.components(separatedBy: "=")
            if components.count == 2,
               let first = components.first,
               let last = components.last,
               let value = Int(last) {
                return Step(label: first, operation: .set(value))
            } else {
                return nil
            }
        }
    }

    var boxes = Array(repeating: [Slot](), count: 256)

    for step in steps {
        let box = hash(step.label)

        switch step.operation {
        case .set(let value):
            let slot = Slot(label: step.label, value: value)
            if let existingLensIndex = boxes[box].firstIndex(where: { $0.label == step.label }) {
                boxes[box][existingLensIndex] = slot
            } else {
                boxes[box].append(slot)
            }

        case .remove:
            boxes[box].removeAll(where: { $0.label == step.label })
        }
    }

    return boxes
        .enumerated()
        .flatMap { boxIndex, box in
            box.enumerated().map { slotIndex, slot in
                (boxIndex + 1) * (slotIndex + 1) * slot.value
            }
        }
        .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
