//
//  Day09.swift
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
struct Day09: Puzzle {
    typealias Input = [Move]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Move: Parsable {
    let direction: Direction
    let distance: Int

    static func parse(raw: String) throws -> Move {
        let components = raw.components(separatedBy: .whitespaces)
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        guard let distance = Int(components[1]) else {
            throw InputError.unexpectedInput(unrecognized: components[1])
        }
        switch components[0] {
        case "U":
            return .init(direction: .north, distance: distance)
        case "D":
            return .init(direction: .south, distance: distance)
        case "L":
            return .init(direction: .west, distance: distance)
        case "R":
            return .init(direction: .east, distance: distance)
        default:
            throw InputError.unexpectedInput(unrecognized: components[0])
        }
    }
}

class Rope {
    var parts: [Coordinate2D]

    var head: Coordinate2D {
        get {
            parts[0]
        }
        set {
            parts[0] = newValue
        }
    }

    var visitedByLastTail: Set<Coordinate2D> = [.zero]

    init(numberOfTails: Int = 1) {
        parts = .init(repeating: .zero, count: numberOfTails + 1)
    }

    func after(_ moves: [Move]) throws -> Self {
        for move in moves {
            for _ in 0..<move.distance {
                head = head.adjacent(moving: move.direction)
                for index in (parts.startIndex+1)..<parts.endIndex {
                    try resolveTail(&parts[index], comparedTo: parts[index-1])
                }
                visitedByLastTail.insert(parts[parts.endIndex-1])
            }
        }
        return self
    }

    private func resolveTail(_ tail: inout Coordinate2D, comparedTo reference: Coordinate2D) throws {
        let distance = reference.manhattanDistance(to: tail)
        if distance < 2 {
            return
        }
        switch distance {
        case 2:
            if tail.x == reference.x {
                tail = tail.adjacent(moving: tail.y < reference.y ? .south : .north)
            }
            if tail.y == reference.y {
                tail = tail.adjacent(moving: tail.x < reference.x ? .east : .west)
            }
        case 3:
            switch abs(tail.x - reference.x) {
            case 1:
                tail = .init(x: reference.x, y: reference.y < tail.y ? reference.y + 1 : reference.y - 1)
            case 2:
                tail = .init(x: reference.x < tail.x ? reference.x + 1 : reference.x - 1, y: reference.y)
            default:
                throw ExecutionError.unsolvable
            }
        case 4:
            tail = .init(x: reference.x < tail.x ? reference.x + 1 : reference.x - 1, y: reference.y < tail.y ? reference.y + 1 : reference.y - 1)
        default:
            throw ExecutionError.unsolvable
        }
    }
}

// MARK: - PART 1

extension Day09 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 13, fromRaw: "R 4\nU 4\nL 3\nD 1\nR 4\nD 1\nL 5\nR 2"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try Rope().after(input).visitedByLastTail.count
    }
}

// MARK: - PART 2

extension Day09 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 1, fromRaw: "R 4\nU 4\nL 3\nD 1\nR 4\nD 1\nL 5\nR 2"),
            assert(expectation: 36, fromRaw: "R 5\nU 8\nL 8\nD 3\nR 17\nD 10\nL 25\nU 20"),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try Rope(numberOfTails: 9).after(input).visitedByLastTail.count
    }
}

// MARK: - CustomStringConvertible

extension Move: CustomStringConvertible {
    var description: String {
        switch direction {
        case .north:
            return "U \(distance)"
        case .south:
            return "D \(distance)"
        case .east:
            return "R \(distance)"
        case .west:
            return "L \(distance)"
        }
    }
}

extension Rope: CustomStringConvertible {
    var description: String {
        let (minX,maxX) = parts.map({ $0.x }).minAndMax().unsafelyUnwrapped
        let (minY,maxY) = parts.map({ $0.y }).minAndMax().unsafelyUnwrapped
        var description = ""
        for y in min(minY, 0)...max(0, maxY) {
            for x in min(minX, 0)...max(0, maxX) {
                guard let index = parts.firstIndex(of: .init(x: x, y: y)) else {
                    if x == 0 && y == 0 {
                        description += "s"
                    } else {
                        description += "."
                    }
                    continue
                }
                if index == 0 {
                    description += "H"
                } else {
                    description += "\(index)"
                }
            }
            description += "\n"
        }
        return description
    }
}
