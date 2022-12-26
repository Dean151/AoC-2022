//
//  Day25.swift
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
struct Day25: Puzzle {
    typealias Input = [SnafuNumber]
    typealias OutputPartOne = String
    typealias OutputPartTwo = Void
}

struct SnafuNumber: Parsable, CustomStringConvertible, ExpressibleByIntegerLiteral {
    enum Digit: Int, CustomStringConvertible {
        case double = 2, simple = 1, zero = 0, minus = -1, doubleMinus = -2

        var description: String {
            switch self {
            case .double:
                return "2"
            case .simple:
                return "1"
            case .zero:
                return "0"
            case .minus:
                return "-"
            case .doubleMinus:
                return "="
            }
        }

        static func parse(raw: Character) throws -> SnafuNumber.Digit {
            switch raw {
            case "2":
                return .double
            case "1":
                return .simple
            case "0":
                return .zero
            case "-":
                return .minus
            case "=":
                return .doubleMinus
            default:
                throw InputError.unexpectedInput(unrecognized: String(raw))
            }
        }
    }

    var digits: [Digit]

    var description: String {
        var description = ""
        for digit in digits.reversed() {
            description += digit.description
        }
        return description
    }

    var intValue: Int {
        var value = 0
        for (power, amount) in digits.enumerated() {
            value += Int(pow(Double(5), Double(power))) * amount.rawValue
        }
        return value
    }

    init(digits: [Digit]) {
        self.digits = digits
    }

    init(integerLiteral value: Int) {
        var digits: [Digit] = []
        var number = value
        while number != 0 {
            let rest = number % 5
            if rest > 2 {
                number += rest
                digits.append(.init(rawValue: rest - 5)!)
            } else {
                digits.append(.init(rawValue: rest)!)
            }
            number /= 5
        }
        self.digits = digits
    }

    static func parse(raw: String) throws -> SnafuNumber {
        var digits: [Digit] = []
        for char in raw.reversed() {
            digits.append(try Digit.parse(raw: char))
        }
        return .init(digits: digits)
    }
}

// MARK: - PART 1

extension Day25 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            // 4890
            assert(expectation: "2=-1=0", fromRaw: "1=-0-2\n12111\n2=0=\n21\n2=01\n111\n20012\n112\n1=-1=\n1-12\n12\n1=\n122"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        SnafuNumber(integerLiteral: input.map({ $0.intValue }).reduce(0, +)).description
    }
}

// MARK: No Part 2 ; Merry Christmas!

extension Day25 {
    static func solvePartTwo(_ input: [SnafuNumber]) async throws -> Void {}
}
