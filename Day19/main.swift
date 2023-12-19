//
//  main.swift
//  Day19
//
//  Created by Marcin Chojnacki on 18/12/2023.
//

import Foundation

let example = #"""
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
"""#.lines()
_ = example

let lines = InputHelper.readInput().lines()

struct Input {
    enum Category: Character {
        case x = "x"
        case m = "m"
        case a = "a"
        case s = "s"
    }

    struct Rule {
        enum Condition {
            case lessThan(Category, Int)
            case greaterThan(Category, Int)
        }

        enum Target {
            case accept
            case reject
            case name(String)
        }

        let condition: Condition?
        let target: Target
    }

    let workflows: [String: [Rule]]
    let ratings: [[Category: Int]]
}

func parseInput(_ input: [String]) throws -> Input {
    let components = input
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .trimmingPrefix(while: \.isEmpty)
        .drop(while: \.isEmpty)
        .split(separator: "")

    guard components.count == 2, let workflowsComponent = components.first, let ratingsComponent = components.last
    else { throw Error("No components and ratings separated by an empty line") }

    let workflows = Dictionary(uniqueKeysWithValues: try workflowsComponent.map { workflow in
        let workflowComponents = workflow.components(separatedBy: "{")

        guard workflowComponents.count == 2,
              let name = workflowComponents.first,
              let rest = workflowComponents.last?.trimmingCharacters(in: ["}"])
        else { throw Error("Malformed workflow: \(workflow)") }

        let rules = try rest
            .components(separatedBy: ",")
            .map { rule in
                let parts = rule.components(separatedBy: ":")

                guard parts.count <= 2, let first = parts.first, let last = parts.last
                else { throw Error("Malformed rule: \(rule)") }

                let condition: Input.Rule.Condition?
                if first != last {
                    let conditionals: CharacterSet = ["<", ">"]
                    let conditionalComponents = first.components(separatedBy: conditionals)
                    let conditional = first.trimmingCharacters(in: conditionals.inverted)

                    guard conditionalComponents.count == 2,
                          let firstConditional = conditionalComponents.first,
                          let firstCategory = Input.Category(rawValue: Character(firstConditional)),
                          let lastConditional = conditionalComponents.last,
                          let lastValue = Int(lastConditional)
                    else { throw Error("Malformed conditional: \(first)") }

                    condition = switch conditional {
                    case "<": .lessThan(firstCategory, lastValue)
                    case ">": .greaterThan(firstCategory, lastValue)
                    default: throw Error("Unknown condition: \(conditional)")
                    }
                } else {
                    condition = nil
                }

                let target: Input.Rule.Target = switch last {
                case "A": .accept
                case "R": .reject
                default: .name(last)
                }

                return Input.Rule(condition: condition, target: target)
            }

        return (name, rules)
    })

    let ratings = try ratingsComponent.map { rating in
        Dictionary(uniqueKeysWithValues: try rating
            .trimmingCharacters(in: ["{", "}"])
            .components(separatedBy: ",")
            .map { expression in
                let expressionComponents = expression.components(separatedBy: "=")

                guard expressionComponents.count == 2,
                      let categoryString = expressionComponents.first,
                      let category = Input.Category(rawValue: Character(categoryString)),
                      let valueString = expressionComponents.last,
                      let value = Int(valueString)
                else { throw Error("Malformed expression: \(expression)") }

                return (category, value)
            }
        )
    }

    return Input(workflows: workflows, ratings: ratings)
}

let input = try parseInput(lines)

func partOne() throws -> Int {
    func isAccepted(_ rating: [Input.Category: Int]) throws -> Bool {
        var accepted: Bool?
        var current = input.workflows["in"]

        while current != nil {
            var running = true

            for rule in current ?? [] where running {
                running = false

                func ifConditionIsMet(_ block: () -> Void) {
                    switch rule.condition {
                    case .lessThan(let category, let value):
                        if let cond = rating[category], cond < value {
                            block()
                        } else {
                            running = true
                        }

                    case .greaterThan(let category, let value):
                        if let cond = rating[category], cond > value {
                            block()
                        } else {
                            running = true
                        }

                    case .none:
                        block()
                    }
                }

                switch rule.target {
                case .accept:
                    ifConditionIsMet {
                        accepted = true
                        current = nil
                    }
                case .reject:
                    ifConditionIsMet {
                        accepted = false
                        current = nil
                    }
                case .name(let name):
                    ifConditionIsMet {
                        current = input.workflows[name]
                    }
                }
            }
        }

        if let accepted {
            return accepted
        } else {
            throw Error("Answer not found")
        }
    }

    return try input.ratings
        .map { try isAccepted($0) ? $0.values.reduce(0, +) : 0 }
        .reduce(0, +)
}

func partTwo() throws -> Int {
    let possibleRange = 1...4000

    indirect enum TreeNode {
        case condition(Input.Category, ClosedRange<Int>, yes: TreeNode, no: TreeNode)
        case accepted
        case rejected
    }

    func treeForWorkflow(_ workflow: String) throws -> TreeNode {
        if let rules = input.workflows[workflow] {
            try treeForWorkflow(rules)
        } else {
            throw Error("Failed to find workflow \(workflow)")
        }
    }

    func treeForWorkflow(_ rules: [Input.Rule]) throws -> TreeNode {
        guard let currentRule = rules.first else {
            throw Error("Failed to resolve workflow")
        }

        let passed: TreeNode = switch currentRule.target {
        case .accept:
            .accepted
        case .reject:
            .rejected
        case .name(let name):
            try treeForWorkflow(name)
        }

        return switch currentRule.condition {
        case .lessThan(let category, let value):
            .condition(
                category,
                possibleRange.lowerBound...(value - 1),
                yes: passed,
                no: try treeForWorkflow(Array(rules.dropFirst()))
            )
        case .greaterThan(let category, let value):
            .condition(
                category,
                (value + 1)...possibleRange.upperBound,
                yes: passed,
                no: try treeForWorkflow(Array(rules.dropFirst()))
            )
        case .none:
            passed
        }
    }

    func reversedRange(_ range: ClosedRange<Int>) throws -> ClosedRange<Int> {
        if range.lowerBound == possibleRange.lowerBound {
            (range.upperBound + 1)...possibleRange.upperBound
        } else if range.upperBound == possibleRange.upperBound {
            possibleRange.lowerBound...(range.lowerBound - 1)
        } else {
            throw Error("Range \(range) is irreversible")
        }
    }

    struct Combinations {
        let x: Set<Int>
        let m: Set<Int>
        let a: Set<Int>
        let s: Set<Int>
    }

    func acceptedCombinations(_ workflow: String) throws -> [Combinations] {
        var combinations: [Combinations] = []

        func traverse(_ tree: TreeNode, x: [Int], m: [Int], a: [Int], s: [Int]) throws {
            switch tree {
            case .condition(let category, let range, let yes, let no):
                let rev = try reversedRange(range)
                switch category {
                case .x:
                    try traverse(yes, x: x.filter { range.contains($0) }, m: m, a: a, s: s)
                    try traverse(no, x: x.filter { rev.contains($0) }, m: m, a: a, s: s)
                case .m:
                    try traverse(yes, x: x, m: m.filter { range.contains($0) }, a: a, s: s)
                    try traverse(no, x: x, m: m.filter { rev.contains($0) }, a: a, s: s)
                case .a:
                    try traverse(yes, x: x, m: m, a: a.filter { range.contains($0) }, s: s)
                    try traverse(no, x: x, m: m, a: a.filter { rev.contains($0) }, s: s)
                case .s:
                    try traverse(yes, x: x, m: m, a: a, s: s.filter { range.contains($0) })
                    try traverse(no, x: x, m: m, a: a, s: s.filter { rev.contains($0) })
                }

            case .accepted:
                combinations.append(Combinations(x: Set(x), m: Set(m), a: Set(a), s: Set(s)))

            case .rejected:
                break
            }
        }

        let tree = try treeForWorkflow(workflow)
        let range = Array(possibleRange)
        try traverse(tree, x: range, m: range, a: range, s: range)

        return combinations
    }

    return try acceptedCombinations("in")
        .map { $0.x.count * $0.m.count * $0.a.count * $0.s.count }
        .reduce(0, +)
}

print("Part 1:", try partOne())
print("Part 2:", try partTwo())
