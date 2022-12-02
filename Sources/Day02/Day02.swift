//
//  Day02.swift
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
struct Day02: Puzzle {
    typealias Input = [Round]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Round: Parsable {
    enum Shape: Int {
        case rock = 1, paper = 2, scissors = 3

        var overcome: Shape {
            switch self {
            case .rock:
                return .scissors
            case .paper:
                return .rock
            case .scissors:
                return .paper
            }
        }

        var weakAgainst: Shape {
            switch self {
            case .rock:
                return .paper
            case .paper:
                return .scissors
            case .scissors:
                return .rock
            }
        }
    }

    enum Outcome: Int {
        case won = 6
        case draw = 3
        case lost = 0
    }

    let opponent: Shape
    let strategyForPartOne: Shape
    let outcomeForPartTwo: Outcome

    var outcomeForPartOne: Outcome {
        if strategyForPartOne == opponent {
            return .draw
        }
        if strategyForPartOne.weakAgainst == opponent {
            return .lost
        }
        return .won
    }

    var scoreForPartOne: Int {
        outcomeForPartOne.rawValue + strategyForPartOne.rawValue
    }

    var strategyForPartTwo: Shape {
        switch outcomeForPartTwo {
        case .draw:
            return opponent
        case .won:
            return opponent.weakAgainst
        case .lost:
            return opponent.overcome
        }
    }

    var scoreForPartTwo: Int {
        outcomeForPartTwo.rawValue + strategyForPartTwo.rawValue
    }

    static func parse(raw: String) throws -> Round {
        let components = raw.components(separatedBy: .whitespaces)
        guard components.count == 2 else {
            throw InputError.unexpectedInput()
        }
        let opponent: Shape
        switch components[0] {
        case "A":
            opponent = .rock
        case "B":
            opponent = .paper
        case "C":
            opponent = .scissors
        default:
            throw InputError.unexpectedInput(unrecognized: components[0])
        }

        let us: Shape
        let outcome: Outcome
        switch components[1] {
        case "X":
            us = .rock
            outcome = .lost
        case "Y":
            us = .paper
            outcome = .draw
        case "Z":
            us = .scissors
            outcome = .won
            default:
                throw InputError.unexpectedInput(unrecognized: components[0])
        }

        return .init(opponent: opponent, strategyForPartOne: us, outcomeForPartTwo: outcome)
    }
}

// MARK: - PART 1

extension Day02 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 15, fromRaw: "A Y\nB X\nC Z")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map { $0.scoreForPartOne }.reduce(0, +)
    }
}

// MARK: - PART 2

extension Day02 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 12, fromRaw: "A Y\nB X\nC Z")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.map { $0.scoreForPartTwo }.reduce(0, +)
    }
}
