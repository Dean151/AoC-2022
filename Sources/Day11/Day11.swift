//
//  Day11.swift
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
import BigNumber

@main
struct Day11: Puzzle {
    typealias Input = [Monkey]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var componentsSeparator: InputSeparator {
        .string(string: "\n\n")
    }
}

struct KeepAway {
    let monkeys: [Monkey]
    let divider: UInt64
    var inspected: [Int]

    init(monkeys: [Monkey], divider: UInt64 = 1, inspected: [Int]? = nil) {
        self.monkeys = monkeys
        self.divider = divider
        self.inspected = inspected ?? .init(repeating: 0, count: monkeys.count)
    }

    func after(rounds: Int) -> Self {
        var monkeys = monkeys
        var inspected = inspected
        for round in 0..<rounds {
            if round % 100 == 0 {
                print(round)
            }
            for index in monkeys.startIndex..<monkeys.endIndex {
                let monkey = monkeys[index]
                for item in monkeys[index].items {
                    let value: UInt64
                    switch monkey.operation {
                    case .add(value: let new):
                        value = (item + new) / divider
                    case .multiply(factor: let new):
                        value = (item * new) / divider
                    case .square:
                        value = (item * item) / divider
                    }
                    if value % monkey.divisorTest == 0 {
                        monkeys[monkey.throwTo.whenTrue].items.append(value)
                    } else {
                        monkeys[monkey.throwTo.whenFalse].items.append(value)
                    }
                }
                inspected[index] += monkey.items.count
                monkeys[index].items.removeAll(keepingCapacity: true)
            }
        }
        return .init(monkeys: monkeys, inspected: inspected)
    }
}

struct Monkey: Parsable {
    enum Operation: Parsable {
        case add(value: UInt64)
        case multiply(factor: UInt64)
        case square

        static func parse(raw: String) throws -> Monkey.Operation {
            let string = raw.suffix(from: raw.index(raw.startIndex, offsetBy: 23))
            if string == "* old" {
                return .square
            }
            let components = string.components(separatedBy: .whitespaces)
            guard components.count == 2, let value = UInt64(components[1]) else {
                throw InputError.unexpectedInput(unrecognized: raw)
            }
            switch components[0] {
            case "+":
                return .add(value: value)
            case "*":
                return .multiply(factor: value)
            default:
                throw InputError.unexpectedInput(unrecognized: raw)
            }
        }
    }

    var items: [UInt64]
    let operation: Operation
    let divisorTest: UInt64
    let throwTo: (whenTrue: Int, whenFalse: Int)

    static func parse(raw: String) throws -> Monkey {
        let components = raw.components(separatedBy: .newlines)
        let items = components[1].suffix(from: components[1].index(components[1].startIndex, offsetBy: 18)).components(separatedBy: ", ").compactMap({ UInt64($0) })
        if items.isEmpty {
            throw InputError.unexpectedInput(unrecognized: components[1])
        }
        guard let divisorTest = UInt64(String(components[3].suffix(from: components[3].index(components[3].startIndex, offsetBy: 21)))) else {
            throw InputError.unexpectedInput(unrecognized: components[3])
        }
        guard let whenTrue = Int(components[4].suffix(from: components[4].index(components[4].startIndex, offsetBy: 29))) else {
            throw InputError.unexpectedInput(unrecognized: components[4])
        }
        guard let whenFalse = Int(components[5].suffix(from: components[5].index(components[5].startIndex, offsetBy: 30))) else {
            throw InputError.unexpectedInput(unrecognized: components[5])
        }
        return .init(
            items: items,
            operation: try .parse(raw: components[2]),
            divisorTest: divisorTest,
            throwTo: (whenTrue, whenFalse)
        )
    }
}

// MARK: - PART 1

extension Day11 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 10605, fromRaw: "Monkey 0:\n  Starting items: 79, 98\n  Operation: new = old * 19\n  Test: divisible by 23\n    If true: throw to monkey 2\n    If false: throw to monkey 3\n\nMonkey 1:\n  Starting items: 54, 65, 75, 74\n  Operation: new = old + 6\n  Test: divisible by 19\n    If true: throw to monkey 2\n    If false: throw to monkey 0\n\nMonkey 2:\n  Starting items: 79, 60, 97\n  Operation: new = old * old\n  Test: divisible by 13\n    If true: throw to monkey 1\n    If false: throw to monkey 3\n\nMonkey 3:\n  Starting items: 74\n  Operation: new = old + 3\n  Test: divisible by 17\n    If true: throw to monkey 0\n    If false: throw to monkey 1")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        KeepAway(monkeys: input, divider: 3).after(rounds: 20).inspected.sorted().suffix(2).reduce(1, *)
    }
}

// MARK: - PART 2

extension Day11 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 2713310158, fromRaw: "Monkey 0:\n  Starting items: 79, 98\n  Operation: new = old * 19\n  Test: divisible by 23\n    If true: throw to monkey 2\n    If false: throw to monkey 3\n\nMonkey 1:\n  Starting items: 54, 65, 75, 74\n  Operation: new = old + 6\n  Test: divisible by 19\n    If true: throw to monkey 2\n    If false: throw to monkey 0\n\nMonkey 2:\n  Starting items: 79, 60, 97\n  Operation: new = old * old\n  Test: divisible by 13\n    If true: throw to monkey 1\n    If false: throw to monkey 3\n\nMonkey 3:\n  Starting items: 74\n  Operation: new = old + 3\n  Test: divisible by 17\n    If true: throw to monkey 0\n    If false: throw to monkey 1")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        KeepAway(monkeys: input).after(rounds: 10_000).inspected.sorted().suffix(2).reduce(1, *)
    }
}
