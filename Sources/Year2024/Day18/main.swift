//
//  main.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 18/12/2024.
//

import Foundation
import Shared

//let input = PackageResources.input_txt.string
//let gridSize = 70
//let bytes = 1024

let input = """
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
"""
let gridSize = 6
let bytes = 12

let incoming = input
    .lines()
    .compactMap { line -> Coordinates? in
        let splitLine = line.split(separator: ",")
        guard
            splitLine.count == 2,
            let x = Int(splitLine[0]),
            let y = Int(splitLine[1])
        else {
            return nil
        }

        return Coordinates(y, x)
    }

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

func buildWalkingGraph(num: Int) -> Graph<Coordinates> {
    let walls = Set(incoming[0..<num])
    let graph = Graph<Coordinates>()

    func walk(pos: Coordinates, prev: Coordinates?) {
        guard
            (0...gridSize).contains(pos.row),
            (0...gridSize).contains(pos.col),
            !walls.contains(pos)
        else { return }

        if let prev {
            graph.addEdge(from: prev, to: pos, weight: 1)
        }

        if !graph.hasNode(pos) {
            graph.addNode(pos)

            walk(pos: Coordinates(pos.row - 1, pos.col), prev: pos)
            walk(pos: Coordinates(pos.row + 1, pos.col), prev: pos)
            walk(pos: Coordinates(pos.row, pos.col - 1), prev: pos)
            walk(pos: Coordinates(pos.row, pos.col + 1), prev: pos)
        }
    }

    walk(pos: .zero, prev: nil)

    return graph
}

func partOne() -> Int {
    let graph = buildWalkingGraph(num: bytes)
    let (result, _) = dijkstra(graph: graph, source: .zero)
    let shortestPath = result[Coordinates(gridSize, gridSize)]

    return shortestPath ?? -1
}

func partTwo() -> String {
    for i in bytes..<input.count {
        let graph = buildWalkingGraph(num: i)

        if !graph.hasNode(Coordinates(gridSize, gridSize)) {
            let lastByte = incoming[i - 1]

            return "\(lastByte.col),\(lastByte.row)"
        }
    }

    return "?"
}

print("Part 1:", partOne())
print("Part 2:", partTwo())
