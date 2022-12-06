//
//  Day06.swift
//  AoC-Swift-Template
//  Forked from https://github.com/Dean151/AoC-Swift-Template
//
//  Created by Thomas DURAND.
//  Follow me on Twitter @deanatoire
//  Check my computing blog on https://www.thomasdurand.fr/
//

import Foundation

import Algorithms

import AoC
import Common

@main
struct Day06: Puzzle {
    typealias Input = String
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static func findStartOfMessageMarker(in input: String, ofSize size: Int) throws -> Int {
        let windows = input.windows(ofCount: size)
        guard let index = windows.firstIndex(where: { !$0.haveDoublons }) else {
            throw ExecutionError.unsolvable
        }
        return windows.distance(from: windows.startIndex, to: index) + size
    }
}

extension StringProtocol {
    var haveDoublons: Bool {
        String(uniqued()).count < count
    }
}

// MARK: - PART 1

extension Day06 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 7, from: "mjqjpqmgbljsphdztnvjfqwrcgsmlb"),
            assert(expectation: 5, from: "bvwbjplbgvbhsrlpgdmjqwftvncz"),
            assert(expectation: 6, from: "nppdvjthqldpwncqszvftbrmjlhg"),
            assert(expectation: 10, from: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"),
            assert(expectation: 11, from: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try findStartOfMessageMarker(in: input, ofSize: 4)
    }
}

// MARK: - PART 2

extension Day06 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 19, from: "mjqjpqmgbljsphdztnvjfqwrcgsmlb"),
            assert(expectation: 23, from: "bvwbjplbgvbhsrlpgdmjqwftvncz"),
            assert(expectation: 23, from: "nppdvjthqldpwncqszvftbrmjlhg"),
            assert(expectation: 29, from: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"),
            assert(expectation: 26, from: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try findStartOfMessageMarker(in: input, ofSize: 14)
    }
}
