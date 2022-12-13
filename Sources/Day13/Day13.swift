//
//  Day13.swift
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
struct Day13: Puzzle {
    typealias Input = [Pair]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var componentsSeparator: InputSeparator {
        .string(string: "\n\n")
    }
}

struct Pair: Parsable {
    enum Element: Parsable, Comparable {
        case integer(value: Int)
        case list(value: [Element])

        static func < (lhs: Pair.Element, rhs: Pair.Element) -> Bool {
            switch (lhs, rhs) {
            case (.integer(let left), .integer(let right)):
                return left < right
            case (.list(let left), .list(let right)):
                for index in left.indices {
                    if index >= right.endIndex {
                        return false
                    }
                    if left[index] == right[index] {
                        continue
                    }
                    return left[index] < right[index]
                }
                return true
            case (.integer(let left), .list(value: let right)):
                return .list(value: [.integer(value: left)]) < .list(value: right)
            case (.list(let left), .integer(value: let right)):
                return .list(value: left) < .list(value: [.integer(value: right)])
            }
        }

        static func parse(raw: String) throws -> Pair.Element {
            if let value = Int(raw) {
                return .integer(value: value)
            }
            if raw.hasPrefix("[") && raw.hasSuffix("]") {
                if raw.count == 2 {
                    return .list(value: [])
                }
                var inner = raw
                inner.removeFirst()
                inner.removeLast()
                inner.append(",")
                var components: [String] = []
                var buffer = ""
                var counter = 0
                charLoop: for char in inner {
                    switch char {
                    case ",":
                        if counter == 0 {
                            components.append(buffer)
                            buffer = ""
                            continue charLoop
                        }
                    case "[":
                        counter += 1
                    case "]":
                        counter -= 1
                    default:
                        break
                    }
                    buffer.append(char)
                }
                return .list(value: try components.map({ try .parse(raw: $0) }))
            }

            throw InputError.unexpectedInput(unrecognized: raw)
        }
    }

    let left: Element
    let right: Element

    static func parse(raw: String) throws -> Pair {
        let components = raw.components(separatedBy: .newlines)
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(left: try .parse(raw: components[0]), right: try .parse(raw: components[1]))
    }
}

// MARK: - PART 1

extension Day13 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 13, fromRaw: "[1,1,3,1,1]\n[1,1,5,1,1]\n\n[[1],[2,3,4]]\n[[1],4]\n\n[9]\n[[8,7,6]]\n\n[[4,4],4,4]\n[[4,4],4,4,4]\n\n[7,7,7,7]\n[7,7,7]\n\n[]\n[3]\n\n[[[]]]\n[[]]\n\n[1,[2,[3,[4,[5,6,7]]]],8,9]\n[1,[2,[3,[4,[5,6,0]]]],8,9]"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.enumerated().filter({ $0.element.left < $0.element.right }).map({ $0.offset + 1 }).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day13 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 140, fromRaw: "[1,1,3,1,1]\n[1,1,5,1,1]\n\n[[1],[2,3,4]]\n[[1],4]\n\n[9]\n[[8,7,6]]\n\n[[4,4],4,4]\n[[4,4],4,4,4]\n\n[7,7,7,7]\n[7,7,7]\n\n[]\n[3]\n\n[[[]]]\n[[]]\n\n[1,[2,[3,[4,[5,6,7]]]],8,9]\n[1,[2,[3,[4,[5,6,0]]]],8,9]"),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let divider1: Pair.Element = .list(value: [.list(value: [.integer(value: 2)])])
        let divider2: Pair.Element = .list(value: [.list(value: [.integer(value: 6)])])
        let sorted = (input.map(by: \.left) + input.map(by: \.right) + [divider1, divider2]).sorted()
        let first = sorted.firstIndex(of: divider1).unsafelyUnwrapped + 1
        let second = sorted.firstIndex(of: divider2).unsafelyUnwrapped + 1
        return first * second
    }
}

extension Pair.Element: CustomStringConvertible {
    var description: String {
        switch self {
        case .integer(value: let value):
            return "\(value)"
        case .list(value: let list):
            return "[" + list.map({ $0.description }).joined(separator: ",") + "]"
        }
    }
}
