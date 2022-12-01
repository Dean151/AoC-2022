//
//  Day01.swift
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
struct Day01: Puzzle {
    typealias Input = [ElveCalories]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var componentsSeparator: InputSeparator {
        .string(string: "\n\n")
    }
}

struct ElveCalories: Parsable {
    var calories: [Int]

    var total: Int {
        return calories.reduce(0, +)
    }

    static func parse(raw: String) throws -> ElveCalories {
        .init(calories: try raw.components(separatedBy: .newlines).map({ try .parse(raw: $0) }))
    }
}

// MARK: - PART 1

extension Day01 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 6000, fromRaw: "1000\n2000\n3000"),
            assert(expectation: 4000, fromRaw: "4000"),
            assert(expectation: 24000, fromRaw: "1000\n2000\n3000\n\n4000\n\n5000\n6000\n\n7000\n8000\n9000\n\n10000"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map(by: \.total).max() ?? 0
    }
}

// MARK: - PART 2

extension Day01 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 45000, fromRaw: "1000\n2000\n3000\n\n4000\n\n5000\n6000\n\n7000\n8000\n9000\n\n10000"),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.map(by: \.total).sorted().suffix(3).reduce(0, +)
    }
}
