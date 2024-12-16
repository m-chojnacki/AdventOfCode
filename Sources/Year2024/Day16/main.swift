//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 16/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
let input = """
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
"""

enum Map: Character, CustomStringConvertible {
    case wall = "#"
    case empty = "."
    case start = "S"
    case end = "E"

    var description: String {
        String(rawValue)
    }
}

enum Direction {
    case up
    case down
    case left
    case right

    var offset: Coordinates {
        switch self {
        case .up:
            Coordinates(-1, 0)
        case .down:
            Coordinates(1, 0)
        case .left:
            Coordinates(0, -1)
        case .right:
            Coordinates(0, 1)
        }
    }

    var ccw: Direction {
        switch self {
        case .up:
            .left
        case .down:
            .right
        case .left:
            .down
        case .right:
            .up
        }
    }

    var cw: Direction {
        switch self {
        case .up:
            .right
        case .down:
            .left
        case .left:
            .up
        case .right:
            .down
        }
    }
}

let map = input
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .lines()
    .map { Array($0).compactMap(Map.init(rawValue:)) }

struct Edge<T: Hashable>: Hashable {
    let destination: T
    let weight: Int
}

final class Graph<T: Hashable> {
    private var adjacencyList: [T: Set<Edge<T>>] = [:]

    func addNode(_ node: T) {
        adjacencyList[node] = []
    }

    func addEdge(from source: T, to destination: T, weight: Int) {
        adjacencyList[source]?.insert(Edge(destination: destination, weight: weight))
    }

    func getNeighbors(of node: T) -> Set<Edge<T>> {
        adjacencyList[node] ?? []
    }

    func getAllNodes() -> Set<T> {
        Set(adjacencyList.keys)
    }

    func hasNode(_ node: T) -> Bool {
        adjacencyList.keys.contains(node)
    }
}

func dijkstra<T: Hashable>(graph: Graph<T>, source: T) -> ([T: Int], [T: Set<T>]) {
    var distances: [T: Int] = [:]
    var previousNodes: [T: Set<T>] = [:]
    var priorityQueue: [(node: T, distance: Int)] = []
    var visited: Set<T> = []

    for node in graph.getAllNodes() {
        distances[node] = Int.max
        previousNodes[node] = []
    }
    distances[source] = 0

    priorityQueue.append((node: source, distance: 0))

    while !priorityQueue.isEmpty {
        priorityQueue.sort { $0.distance < $1.distance } // Sorting to simulate a min-heap
        let current = priorityQueue.removeFirst()

        let currentNode = current.node
        let currentDistance = current.distance

        if visited.contains(currentNode) {
            continue
        }

        visited.insert(currentNode)

        for edge in graph.getNeighbors(of: currentNode) {
            let newDistance = currentDistance + edge.weight
            if newDistance < distances[edge.destination] ?? .max {
                distances[edge.destination] = newDistance
                previousNodes[edge.destination] = [currentNode]
                priorityQueue.append((node: edge.destination, distance: newDistance))
            } else if newDistance == distances[edge.destination] {
                previousNodes[edge.destination]?.insert(currentNode)
            }
        }
    }

    return (distances, previousNodes)
}

func getAllPaths<T: Hashable>(to destination: T, previousNodes: [T: Set<T>]) -> [[T]] {
    var allPaths: [[T]] = []

    func buildPaths(currentNode: T, path: [T]) {
        var newPath = path
        newPath.insert(currentNode, at: 0)

        if previousNodes[currentNode]?.isEmpty ?? true {
            allPaths.append(newPath)
        } else {
            for predecessor in previousNodes[currentNode]! {
                buildPaths(currentNode: predecessor, path: newPath)
            }
        }
    }

    buildPaths(currentNode: destination, path: [])

    return allPaths
}

extension Array where Element: Collection, Element.Index == Int {
    func find(_ block: (Element.Element) -> Bool) -> [Coordinates] {
        indices.flatMap { row in
            self[row].indices.compactMap { col in
                if block(self[row][col]) {
                    Coordinates(row, col)
                } else {
                    nil
                }
            }
        }
    }
}

func partOne(allPaths: Bool = false) -> Int {
    let start = map.find { $0 == .start }.first!
    let end = map.find { $0 == .end }.first!

    struct Pair: Hashable, CustomStringConvertible {
        let coordinate: Coordinates
        let direction: Direction

        var description: String {
            coordinate.description
        }
    }

    let graph = Graph<Pair>()

    func walk(_ pair: Pair, last: Pair?) {
        if let last {
            graph.addEdge(from: last, to: pair, weight: pair.direction == last.direction ? 1 : 1000)
        }

        guard map[pair.coordinate.row][pair.coordinate.col] != .wall, !graph.hasNode(pair) else { return }

        graph.addNode(pair)

        walk(
            Pair(
                coordinate: Coordinates(
                    pair.coordinate.row + pair.direction.offset.row,
                    pair.coordinate.col + pair.direction.offset.col
                ),
                direction: pair.direction
            ),
            last: pair
        )

        walk(
            Pair(
                coordinate: pair.coordinate,
                direction: pair.direction.ccw
            ),
            last: pair
        )

        walk(
            Pair(
                coordinate: pair.coordinate,
                direction: pair.direction.cw
            ),
            last: pair
        )
    }

    walk(Pair(coordinate: start, direction: .right), last: nil)

    let (result, prevNodes) = dijkstra(graph: graph, source: Pair(coordinate: start, direction: .right))

    let best = [
        Pair(coordinate: end, direction: .up),
        Pair(coordinate: end, direction: .down),
        Pair(coordinate: end, direction: .left),
        Pair(coordinate: end, direction: .right)
    ]
    .compactMap {
        if let result = result[$0] {
            return (result, $0)
        } else {
            return nil
        }
    }
    .min {
        $0.0 < $1.0
    }!

    if allPaths {
        let paths = getAllPaths(to: Pair(coordinate: end, direction: best.1.direction), previousNodes: prevNodes)

        return Set(paths.flatMap { $0.map(\.coordinate) }).count
    } else {
        return best.0
    }
}

func partTwo() -> Int {
    partOne(allPaths: true)
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
