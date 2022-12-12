//
//  Day12.swift
//  AoC-Swift-Template
//  Forked from https://github.com/Dean151/AoC-Swift-Template
//
//  Created by Thomas DURAND.
//  Follow me on Twitter @deanatoire
//  Check my computing blog on https://www.thomasdurand.fr/
//

import Foundation

import AoC
import Common

@main
struct Day12: Puzzle {
    typealias Input = Map
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Map: Parsable {
    let elevations: [Coordinate2D: Int] // From 1 to 26
    let start: Coordinate2D
    let end: Coordinate2D

    static func parse(raw: String) throws -> Map {
        var start: Coordinate2D?
        var end: Coordinate2D?
        var elevations: [Coordinate2D: Int] = [:]
        for (y, line) in raw.components(separatedBy: .newlines).enumerated() {
            for (x, char) in line.enumerated() {
                let elevation: Int
                switch char {
                case "S":
                    start = .init(x: x, y: y)
                    elevation = 1
                case "E":
                    end = .init(x: x, y: y)
                    elevation = 26
                case "a"..."z":
                    elevation = Int(char.unicodeScalars.first!.utf8.last!) - 96
                default:
                    throw InputError.unexpectedInput(unrecognized: "\(char)")
                }
                elevations[Coordinate2D(x: x, y: y)] = elevation
            }
        }
        guard let start, let end else {
            throw InputError.unexpectedInput()
        }
        return .init(elevations: elevations, start: start, end: end)
    }

    /// Uses of Dijkstra
    func shortestPath(reversed: Bool = false) -> [Coordinate2D: Int] {
        // Initialization
        let start = reversed ? end : start
        var distances: [Coordinate2D: Int] = .init(minimumCapacity: elevations.count)
        var toVisit: Set<Coordinate2D> = .init(minimumCapacity: elevations.count)
        for coordinate in elevations.keys {
            distances[coordinate] = coordinate == start ? 0 : .max
        }

        toVisit.insert(start)
        while let current = toVisit.min(by: { distances[$0].unsafelyUnwrapped < distances[$1].unsafelyUnwrapped }) {
            let distance = distances[current].unsafelyUnwrapped
            toVisit.remove(current)
            for next in adjacents(from: current, reversed: reversed) {
                let new = distance + 1
                if distances[next].unsafelyUnwrapped > new {
                    toVisit.insert(next)
                    distances[next] = new
                }
            }
        }
        return distances
    }

    private func adjacents(from coordinate: Coordinate2D, reversed: Bool) -> [Coordinate2D] {
        coordinate.adjacents.filter {
            guard let elevation = elevations[$0] else {
                return false
            }
            if reversed {
                return elevation >= elevations[coordinate].unsafelyUnwrapped - 1
            } else {
                return elevation <= elevations[coordinate].unsafelyUnwrapped + 1
            }
        }
    }
}

// MARK: - PART 1

extension Day12 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 31, fromRaw: "Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.shortestPath()[input.end].unsafelyUnwrapped
    }
}

// MARK: - PART 2

extension Day12 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 29, fromRaw: "Sabqponm\nabcryxxl\naccszExk\nacctuvwj\nabdefghi")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.shortestPath(reversed: true).filter({ input.elevations[$0.key] == 1 }).map(by: \.value).min().unsafelyUnwrapped
    }
}
