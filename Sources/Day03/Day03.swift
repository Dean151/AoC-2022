//
//  Day03.swift
//  AoC-Swift-Template
//  Forked from https://github.com/Dean151/AoC-Swift-Template
//
//  Created by Thomas DURAND.
//  Follow me on Twitter @deanatoire
//  Check my computing blog on https://www.thomasdurand.fr/
//

import Algorithms
import Foundation

import AoC
import Common

@main
struct Day03: Puzzle {
    typealias Input = [Rucksack]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

extension Character {
    func priority() throws -> Int {
        guard let scalar = unicodeScalars.first, unicodeScalars.count == 1 else {
            throw InputError.unexpectedInput(unrecognized: "\(self)")
        }
        guard let base = scalar.utf8.last else {
            throw InputError.unexpectedInput(unrecognized: "\(self)")
        }
        if CharacterSet.lowercaseLetters.contains(scalar) {
            return Int(base) - 96
        }
        if CharacterSet.uppercaseLetters.contains(scalar) {
            return Int(base) - 38
        }
        throw InputError.unexpectedInput(unrecognized: "\(self)")
    }
}

extension RandomAccessCollection where Element == Rucksack {
    func common() throws -> Character {
        guard count == 3 else {
            throw ExecutionError.unsolvable
        }
        let first = self[startIndex].content
        let second = self[index(after: startIndex)].content
        let third = self[index(startIndex, offsetBy: 2)].content
        guard let char = first.first(where: { second.contains($0) && third.contains($0) }) else {
            throw ExecutionError.unsolvable
        }
        return char
    }
}

struct Rucksack: Parsable {
    let content: String

    func common() throws -> Character {
        let count = content.count
        guard count > 0, count % 2 == 0 else {
            throw InputError.unexpectedInput(unrecognized: content)
        }
        let middle = content.index(content.startIndex, offsetBy: count/2)
        let first = String(content[content.startIndex..<middle])
        let second = String(content[middle..<content.endIndex])
        guard let char = first.first(where: { second.contains($0) }) else {
            throw ExecutionError.unsolvable
        }
        return char
    }

    static func parse(raw: String) throws -> Rucksack {
        .init(content: raw)
    }
}

// MARK: - PART 1

extension Day03 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 16, fromRaw: "vJrwpWtwJgWrhcsFMMfFFhFp"),
            assert(expectation: 38, fromRaw: "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"),
            assert(expectation: 157, fromRaw: "vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try input.map({ try $0.common().priority() }).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day03 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 18, fromRaw: "vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg"),
            assert(expectation: 52, fromRaw: "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw"),
            assert(expectation: 70, fromRaw: "vJrwpWtwJgWrhcsFMMfFFhFp\njqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL\nPmmdzqPrVvPwwTWBwg\nwMqvLMZHhHMvwLHjbvcjnnSBnvTQFn\nttgJtRGJQctTZtZT\nCrZsJsPPZsGzwwsLwLmpwMDw"),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.chunks(ofCount: 3).map({ try $0.common().priority() }).reduce(0, +)
    }
}
