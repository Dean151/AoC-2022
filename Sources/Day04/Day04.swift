//
//  Day04.swift
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
struct Day04: Puzzle {
    typealias Input = [Assignment]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Assignment: Parsable {
    let first: ClosedRange<Int>
    let second: ClosedRange<Int>

    var overlaps: Bool {
        first.overlaps(second)
    }

    var fullyContained: Bool {
        guard overlaps else {
            return false
        }
        let clamped = first.clamped(to: second)
        return clamped == first || clamped == second
    }

    static func parse(raw: String) throws -> Assignment {
        let components = raw.components(separatedBy: ",")
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(first: try .parse(raw: components[0]), second: try .parse(raw: components[1]))
    }
}

extension ClosedRange<Int>: Parsable {
    public static func parse(raw: String) throws -> ClosedRange<Int> {
        let components = raw.components(separatedBy: "-").compactMap({ Int($0) })
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(uncheckedBounds: (components[0], components[1]))
    }
}

// MARK: - PART 1

extension Day04 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 2, fromRaw: "2-4,6-8\n2-3,4-5\n5-7,7-9\n2-8,3-7\n6-6,4-6\n2-6,4-8"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.filter(by: \.fullyContained).count
    }
}

// MARK: - PART 2

extension Day04 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 4, fromRaw: "2-4,6-8\n2-3,4-5\n5-7,7-9\n2-8,3-7\n6-6,4-6\n2-6,4-8"),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.filter(by: \.overlaps).count
    }
}
