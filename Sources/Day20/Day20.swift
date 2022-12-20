//
//  Day20.swift
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
struct Day20: Puzzle {
    typealias Input = [Int]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Value {
    let value: Int
    let sortOrder: Int
}

extension Day20 {
    static func mix(_ input: [Int], times: Int = 1) -> [Value] {
        let count = input.count
        var values = input.enumerated().map({ Value(value: $0.element, sortOrder: $0.offset) })
        for sortIndex in 0..<(count*times) {
            let currentIndex = values.firstIndex(where: { $0.sortOrder == (sortIndex % count) }).unsafelyUnwrapped
            let element = values.remove(at: currentIndex)
            var newIndex = (currentIndex + element.value) % (count - 1)
            if newIndex < 0 {
                newIndex += count - 1
            }
            values.insert(element, at: newIndex)
        }
        return values
    }
}

// MARK: - PART 1

extension Day20 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 3, fromRaw: "1\n2\n-3\n3\n-2\n0\n4")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let mixed = mix(input)
        let zeroIndex = mixed.firstIndex(where: { $0.value == 0 }).unsafelyUnwrapped
        return [1000,2000,3000].map({ mixed[(zeroIndex + $0) % input.count].value }).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day20 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 1623178306, fromRaw: "1\n2\n-3\n3\n-2\n0\n4")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let mixed = mix(input.map({ $0 * 811589153 }), times: 10)
        let zeroIndex = mixed.firstIndex(where: { $0.value == 0 }).unsafelyUnwrapped
        return [1000,2000,3000].map({ mixed[(zeroIndex + $0) % input.count].value }).reduce(0, +)
    }
}
