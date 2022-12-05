//
//  Day05.swift
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
struct Day05: Puzzle {
    typealias Input = CargoCrane
    typealias OutputPartOne = String
    typealias OutputPartTwo = String
}

struct CargoCrane: Parsable {
    struct Move: Parsable {
        let amount: Int
        let from: Int
        let to: Int

        static func parse(raw: String) throws -> CargoCrane.Move {
            let components = raw.components(separatedBy: .whitespaces)
            guard components.count == 6 else {
                throw InputError.unexpectedInput(unrecognized: raw)
            }
            guard let amount = Int(components[1]) else {
                throw InputError.unexpectedInput(unrecognized: components[1])
            }
            guard let from = Int(components[3]) else {
                throw InputError.unexpectedInput(unrecognized: components[3])
            }
            guard let to = Int(components[5]) else {
                throw InputError.unexpectedInput(unrecognized: components[5])
            }
            return .init(amount: amount, from: from, to: to)
        }
    }
    struct Stacks: Parsable {
        let stacks: [Array<Character>]

        var upperWord: String {
            var word = ""
            for stack in stacks {
                guard let char = stack.last else {
                    continue
                }
                word.append(char)
            }
            return word
        }

        func after(_ moves: [Move], multipleAtOnce: Bool) throws -> Stacks {
            var stacks = stacks
            for move in moves {
                if multipleAtOnce {
                    let chars = stacks[move.from-1].suffix(move.amount)
                    stacks[move.from-1].removeLast(move.amount)
                    stacks[move.to-1] += chars
                } else {
                    for _ in 0..<move.amount {
                        let char = stacks[move.from-1].removeLast()
                        stacks[move.to-1].append(char)
                    }
                }
            }
            return .init(stacks: stacks)
        }

        static func parse(raw: String) throws -> CargoCrane.Stacks {
            let offsets = [1, 5, 9, 13, 17, 21, 25, 29, 33]
            var stacks: [Array<Character>] = .init(repeating: [], count: 9)
            var lines = raw.components(separatedBy: .newlines)
            _ = lines.removeLast()
            lineLoop: for line in lines.reversed() {
                offsetLoop: for (index, offset) in offsets.enumerated() {
                    guard offset < line.count else {
                        continue lineLoop
                    }
                    let char = line[line.index(line.startIndex, offsetBy: offset)]
                    guard char.isLetter else {
                        continue offsetLoop
                    }
                    stacks[index].append(char)
                }
            }
            return .init(stacks: stacks)
        }
    }

    let stacks: Stacks
    let moves: [Move]

    static func parse(raw: String) throws -> CargoCrane {
        let components = raw.components(separatedBy: "\n\n")
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(
            stacks: try .parse(raw: components[0]),
            moves: try components[1].components(separatedBy: .newlines).map({ try .parse(raw: $0) })
        )
    }
}

// MARK: - PART 1

extension Day05 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: "CMZ", fromRaw: "    [D]\n[N] [C]\n[Z] [M] [P]\n 1   2   3\n\nmove 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try input.stacks.after(input.moves, multipleAtOnce: false).upperWord
    }
}

// MARK: - PART 2

extension Day05 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: "MCD", fromRaw: "    [D]\n[N] [C]\n[Z] [M] [P]\n 1   2   3\n\nmove 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.stacks.after(input.moves, multipleAtOnce: true).upperWord
    }
}
