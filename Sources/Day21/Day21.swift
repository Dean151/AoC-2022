//
//  Day21.swift
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
struct Day21: Puzzle {
    typealias Input = [String: Operation]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static func transform(raw: String) async throws -> [String: Operation] {
        var operations: [String: Operation] = [:]
        try raw.components(separatedBy: .newlines).forEach { line in
            let components = line.components(separatedBy: ": ")
            guard components.count == 2 else {
                throw InputError.unexpectedInput(unrecognized: line)
            }
            let identifier = components[0]
            operations[identifier] = try .parse(raw: components[1])
        }
        return operations
    }
}

enum Operation: Parsable {
    case unknown
    case raw(value: Int)
    case add(left: String, right: String)
    case multiply(left: String, right: String)
    case substract(left: String, right: String)
    case divide(left: String, right: String)

    var left: String {
        switch self {
        case .raw, .unknown:
            fatalError("No left operant for raw value")
        case .add(let left, _), .multiply(let left, _), .substract(let left, _), .divide(let left, _):
            return left
        }
    }

    var right: String {
        switch self {
        case .raw, .unknown:
            fatalError("No right operant for raw value")
        case .add(_, let right), .multiply(_, let right), .substract(_, let right), .divide(_, let right):
            return right
        }
    }

    var operation: String {
        switch self {
        case .raw, .unknown:
            fatalError("No left operation for raw value")
        case .add:
            return "+"
        case .multiply:
            return "*"
        case .substract:
            return "-"
        case .divide:
            return "/"
        }
    }

    func resolve(using operations: [String: Operation]) throws -> Int {
        if case let .raw(value) = self {
            return value
        }

        if case .unknown = self {
            throw ExecutionError.unsolvable
        }

        guard let left = operations[left], let right = operations[right] else {
            throw ExecutionError.unsolvable
        }

        switch self {
        case .add:
            return try left.resolve(using: operations) + right.resolve(using: operations)
        case .multiply:
            return try left.resolve(using: operations) * right.resolve(using: operations)
        case .substract:
            return try left.resolve(using: operations) - right.resolve(using: operations)
        case .divide:
            return try left.resolve(using: operations) / right.resolve(using: operations)
        case .unknown, .raw:
            fatalError("Impossible!")
        }
    }

    func findValue(using operations: [String: Operation]) throws -> (value: Int, other: KeyPath<Self, String>) {
        var value: Int
        var other: KeyPath<Self, String>
        do {
            guard operations[left] != nil else {
                throw ExecutionError.unsolvable
            }
            value = try operations[left]!.resolve(using: operations)
            other = \.right
        } catch {
            do {
                guard operations[right] != nil else {
                    throw ExecutionError.unsolvable
                }
                value = try operations[right]!.resolve(using: operations)
                other = \.left
            } catch {
                throw ExecutionError.unsolvable
            }
        }
        return (value, other)
    }

    func equalify(using operations: [String: Operation]) throws -> Int {
        let (value, other) = try findValue(using: operations)
        return try operations[self[keyPath: other]]!.resolveEquality(value: value, using: operations)
    }

    func resolveEquality(value: Int, using operations: [String: Operation]) throws -> Int {
        if case .unknown = self {
            return value
        }
        let (innerValue, other) = try findValue(using: operations)
        switch self {
        case .add:
            return try operations[self[keyPath: other]]!.resolveEquality(value: value - innerValue, using: operations)
        case .multiply:
            return try operations[self[keyPath: other]]!.resolveEquality(value: value / innerValue, using: operations)
        case .substract:
            if other == \.left {
                return try operations[self[keyPath: other]]!.resolveEquality(value: value + innerValue, using: operations)
            } else {
                return try operations[self[keyPath: other]]!.resolveEquality(value: innerValue - value, using: operations)
            }
        case .divide:
            if other == \.left {
                return try operations[self[keyPath: other]]!.resolveEquality(value: value * innerValue, using: operations)
            } else {
                return try operations[self[keyPath: other]]!.resolveEquality(value: innerValue / value, using: operations)
            }
        case .raw, .unknown:
            throw ExecutionError.unsolvable
        }
    }

    static func parse(raw: String) throws -> Operation {
        if let value = Int(raw) {
            return .raw(value: value)
        }
        let components = raw.components(separatedBy: " ")
        guard components.count == 3 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        switch components[1] {
        case "+":
            return .add(left: components[0], right: components[2])
        case "*":
            return .multiply(left: components[0], right: components[2])
        case "-":
            return .substract(left: components[0], right: components[2])
        case "/":
            return .divide(left: components[0], right: components[2])
        default:
            throw InputError.unexpectedInput(unrecognized: raw)
        }
    }
}

// MARK: - PART 1

extension Day21 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 152, fromRaw: "root: pppw + sjmn\ndbpl: 5\ncczh: sllz + lgvd\nzczc: 2\nptdq: humn - dvpt\ndvpt: 3\nlfqf: 4\nhumn: 5\nljgn: 2\nsjmn: drzm * dbpl\nsllz: 4\npppw: cczh / lfqf\nlgvd: ljgn * ptdq\ndrzm: hmdt - zczc\nhmdt: 32")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        guard let root = input["root"] else {
            throw ExecutionError.unsolvable
        }
        return try root.resolve(using: input)
    }
}

// MARK: - PART 2

extension Day21 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 301, fromRaw: "root: pppw + sjmn\ndbpl: 5\ncczh: sllz + lgvd\nzczc: 2\nptdq: humn - dvpt\ndvpt: 3\nlfqf: 4\nhumn: 5\nljgn: 2\nsjmn: drzm * dbpl\nsllz: 4\npppw: cczh / lfqf\nlgvd: ljgn * ptdq\ndrzm: hmdt - zczc\nhmdt: 32")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var input = input
        input["humn"] = .unknown
        guard let root = input["root"] else {
            throw ExecutionError.unsolvable
        }
        return try root.equalify(using: input)
    }
}
