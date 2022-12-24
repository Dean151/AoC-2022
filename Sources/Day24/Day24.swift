//
//  Day24.swift
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
struct Day24: Puzzle {
    typealias Input = Valley
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var testRawInput: String {
        "#.######\n#>>.<^<#\n#.<..<<#\n#>v.><>#\n#<^v^^>#\n######.#"
    }
}

struct Blizzards {
    var blizzards: [Direction: [Coordinate2D]] = [.north: [], .south: [], .east: [], .west: []]

    mutating func append(_ direction: Direction, at coordinate: Coordinate2D) {
        blizzards[direction]!.append(coordinate)
    }

    func contains(_ coordinate: Coordinate2D) -> Bool {
        for direction in Direction.allCases {
            if blizzards[direction]!.contains(coordinate) {
                return true
            }
        }
        return false
    }

    func directions(at coordinate: Coordinate2D) -> Set<Direction> {
        Set(Direction.allCases.filter({ blizzards[$0]!.contains(coordinate) }))
    }

    func next(bounds width: Int, _ height: Int) -> Blizzards {
        var new = Blizzards()
        for (direction, coords) in blizzards {
            new.blizzards[direction] = coords.map({
                var next = $0.adjacent(moving: direction)
                if next.x < 1 {
                    next.x = width
                }
                if next.x > width {
                    next.x = 1
                }
                if next.y < 1 {
                    next.y = height
                }
                if next.y > height {
                    next.y = 1
                }
                return next
            })
        }
        return new
    }
}

struct Valley: Parsable {
    // Limits
    let width: Int
    let height: Int

    // Start & End
    let start: Coordinate2D
    let end: Coordinate2D

    // Blizzards
    let blizzards: Blizzards

    func findPath(withRoundTrip: Bool = false) throws -> Int {
        var minutes = 0
        var currents: Set<Coordinate2D> = [start]
        var blizzards = self.blizzards
        var isGoingBack = false
        var haveGoneBack = false
        while !currents.isEmpty {
            let upcoming = blizzards.next(bounds: width, height)
            // Find possible movements
            var possibilities: Set<Coordinate2D> = []
            for current in currents {
                let adjacents = ([current] + current.adjacents).filter({
                    isInBoard($0) && !upcoming.contains($0)
                })
                for adjacent in adjacents {
                    possibilities.insert(adjacent)
                }
            }
            // Blizzards have now moved
            blizzards = upcoming
            minutes += 1
            // Are we done?
            if possibilities.contains(end) && !isGoingBack {
                if !withRoundTrip || haveGoneBack {
                    return minutes
                }
                isGoingBack = true
                possibilities = [end]
            }
            if isGoingBack && possibilities.contains(start) {
                isGoingBack = false
                haveGoneBack = true
                possibilities = [start]
            }
            currents = possibilities
        }
        throw ExecutionError.unsolvable
    }

    func isInBoard(_ coordinate: Coordinate2D) -> Bool {
        coordinate == start || coordinate == end || (1...width).contains(coordinate.x) && (1...height).contains(coordinate.y)
    }

    static func parse(raw: String) throws -> Valley {
        let lines = raw.components(separatedBy: .newlines)
        let height = lines.count - 2
        let width = lines.first.unsafelyUnwrapped.count - 2
        var blizzards = Blizzards()
        for (y,line) in lines.enumerated() {
            for (x,char) in line.enumerated() {
                switch char {
                case "#", ".":
                    break
                case "^":
                    blizzards.append(.north, at: .init(x: x, y: y))
                case "v":
                    blizzards.append(.south, at: .init(x: x, y: y))
                case "<":
                    blizzards.append(.west, at: .init(x: x, y: y))
                case ">":
                    blizzards.append(.east, at: .init(x: x, y: y))
                default:
                    throw InputError.unexpectedInput(unrecognized: String(char))
                }
            }
        }
        return .init(width: width, height: height, start: .init(x: 1, y: 0), end: .init(x: width, y: height + 1), blizzards: blizzards)
    }
}

// MARK: - PART 1

extension Day24 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 18, fromRaw: testRawInput),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try input.findPath()
    }
}

// MARK: - PART 2

extension Day24 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 54, fromRaw: testRawInput),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.findPath(withRoundTrip: true)
    }
}
