//
//  Day14.swift
//  AoC-Swift-Template
//  Forked from https://github.com/Dean151/AoC-Swift-Template
//
//  Created by Thomas DURAND.
//  Follow me on Twitter @deanatoire
//  Check my computing blog on https://www.thomasdurand.fr/
//

import Foundation

import Algorithms

import AoC
import Common

@main
struct Day14: Puzzle {
    typealias Input = Cave
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

extension Coordinate2D: Parsable {
    public static func parse(raw: String) throws -> Coordinate2D {
        let components = raw.components(separatedBy: ",").compactMap({ Int($0) })
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(x: components[0], y: components[1])
    }
}

struct Cave: Parsable {
    let rocks: Set<Coordinate2D>

    func fillWithSand(withFloor: Bool = false) -> Int {
        var sand: Set<Coordinate2D> = []
        let bottom = rocks.map({ $0.y }).max().unsafelyUnwrapped + 2

        func addSandGrain() -> Coordinate2D? {
            func next(from position: Coordinate2D) -> Coordinate2D? {
                func isOccupied(_ position: Coordinate2D) -> Bool {
                    sand.contains(position) || rocks.contains(position) || position.y == bottom
                }

                // Try down
                let down = position.adjacent(moving: .south)
                for attempt in [down, down.adjacent(moving: .west), down.adjacent(moving: .east)] {
                    if !isOccupied(attempt) {
                        return attempt
                    }
                }
                return nil
            }

            let start = Coordinate2D(x: 500, y: 0)
            var position = start
            while let next = next(from: position) {
                if !withFloor && next.y == bottom - 1 {
                    return nil
                }
                position = next
            }
            if position == start {
                sand.insert(start)
                return nil
            }
            return position
        }

        repeat {
            if let new = addSandGrain() {
                sand.insert(new)
            } else {
                break
            }
        } while true
        return sand.count
    }

    static func parse(raw: String) throws -> Cave {
        var rocks: Set<Coordinate2D> = []
        for line in raw.components(separatedBy: .newlines) {
            let corners = try line.components(separatedBy: " -> ").map({ try Coordinate2D.parse(raw: $0) })
            guard corners.count > 1 else {
                throw InputError.unexpectedInput(unrecognized: line)
            }
            for window in corners.windows(ofCount: 2) {
                let first = window.first.unsafelyUnwrapped
                let last = window.last.unsafelyUnwrapped
                try first.stride(to: last) {
                    rocks.insert($0)
                }
            }
        }
        return .init(rocks: rocks)
    }
}

// MARK: - PART 1

extension Day14 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 24, fromRaw: "498,4 -> 498,6 -> 496,6\n503,4 -> 502,4 -> 502,9 -> 494,9")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.fillWithSand()
    }
}

// MARK: - PART 2

extension Day14 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 93, fromRaw: "498,4 -> 498,6 -> 496,6\n503,4 -> 502,4 -> 502,9 -> 494,9")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.fillWithSand(withFloor: true)
    }
}

extension Cave: CustomStringConvertible {
    var description: String {
        let (minX,maxX) = rocks.map({ $0.x }).minAndMax().unsafelyUnwrapped
        let (minY,maxY) = rocks.map({ $0.y }).minAndMax().unsafelyUnwrapped

        var description = ""
        for y in minY...maxY {
            for x in minX...maxX {
                if rocks.contains(.init(x: x, y: y)) {
                    description += "#"
                } else {
                    description += "."
                }
            }
            description += "\n"
        }
        return description
    }
}
