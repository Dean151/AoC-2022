//
//  Day08.swift
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
struct Day08: Puzzle {
    typealias Input = TreeField
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct TreeField: Parsable {
    let size: Int // Input is a square
    let trees: [Coordinate2D: Int]

    static func parse(raw: String) throws -> TreeField {
        let lines = raw.components(separatedBy: .newlines)
        let size = lines.count
        var trees: [Coordinate2D: Int] = [:]
        for (y,line) in lines.enumerated() {
            guard line.count == size else {
                throw InputError.unexpectedInput(unrecognized: line)
            }
            for (x,char) in line.enumerated() {
                guard let code = char.utf8.last else {
                    throw InputError.unexpectedInput(unrecognized: char.description)
                }
                let height = Int(code - 48)
                guard height >= 0 && height < 10 else {
                    throw InputError.unexpectedInput(unrecognized: height.description)
                }
                trees[.init(x: x, y: y)] = height
            }
        }
        return .init(size: size, trees: trees)
    }
}

// MARK: - PART 1

extension TreeField {
    var visible: Set<Coordinate2D> {
        var visible: Set<Coordinate2D> = []
        for direction in Direction.allCases {
            for first in firsts(going: direction) {
                visible.insert(first)
                var position = first
                var height = trees[first].unsafelyUnwrapped
                repeat {
                    position = position.adjacent(moving: direction)
                    guard let newHeight = trees[position] else {
                        break
                    }
                    guard newHeight > height else {
                        continue
                    }
                    visible.insert(position)
                    height = newHeight
                } while true
            }
        }
        return visible
    }

    func firsts(going direction: Direction) -> [Coordinate2D] {
        switch direction {
        case .north:
            return (0..<size).map { Coordinate2D(x: $0, y: size - 1) }
        case .east:
            return (0..<size).map { Coordinate2D(x: 0, y: $0) }
        case .south:
            return (0..<size).map { Coordinate2D(x: $0, y: 0) }
        case .west:
            return (0..<size).map { Coordinate2D(x: size - 1, y: $0) }
        }
    }
}

extension Day08 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 21, fromRaw: "30373\n25512\n65332\n33549\n35390")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.visible.count
    }
}

// MARK: - PART 2

extension TreeField {
    var highestScenicScore: Int {
        var score = 0
        for x in 1..<size-1 {
            for y in 1..<size-1 {
                let new = scenicScore(at: .init(x: x, y: y))
                if new > score {
                    score = new
                }
            }
        }
        return score
    }

    private func scenicScore(at position: Coordinate2D) -> Int {
        Direction.allCases.map { direction in
            var visible = 0
            let ref = trees[position].unsafelyUnwrapped
            var position = position.adjacent(moving: direction)
            repeat {
                guard let height = trees[position] else {
                    break
                }
                visible += 1
                guard height < ref else {
                    break
                }
                position = position.adjacent(moving: direction)
            } while true
            return visible
        }.reduce(1, *)
    }
}

extension Day08 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 8, fromRaw: "30373\n25512\n65332\n33549\n35390")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.highestScenicScore
    }
}
