//
//  Day17.swift
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
struct Day17: Puzzle {
    typealias Input = [Move]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var componentsSeparator: InputSeparator {
        .breakAll
    }
}

enum Move: String, Parsable {
    case left = "<", right = ">"

    var direction: Direction {
        switch self {
        case .left:
            return .west
        case .right:
            return .east
        }
    }

    static func parse(raw: String) throws -> Move {
        guard let move = Self(rawValue: raw) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return move
    }
}

enum RockShape: Int, CaseIterable {
    case minus = 0, plus, corner, pillar, square

    var height: Int {
        switch self {
        case .minus:
            return 1
        case .plus:
            return 3
        case .corner:
            return 3
        case .pillar:
            return 4
        case .square:
            return 2
        }
    }

    var coordinates: Set<Coordinate2D> {
        switch self {
        case .minus:
            return [.init(x: 0, y: 0), .init(x: 1, y: 0), .init(x: 2, y: 0), .init(x: 3, y: 0)]
        case .plus:
            return [.init(x: 1, y: 0), .init(x: 0, y: 1), .init(x: 1, y: 1), .init(x: 2, y: 1), .init(x: 1, y: 2)]
        case .corner:
            return [.init(x: 0, y: 0), .init(x: 1, y: 0), .init(x: 2, y: 0), .init(x: 2, y: 1), .init(x: 2, y: 2)]
        case .pillar:
            return [.init(x: 0, y: 0), .init(x: 0, y: 1), .init(x: 0, y: 2), .init(x: 0, y: 3)]
        case .square:
            return [.init(x: 0, y: 0), .init(x: 1, y: 0), .init(x: 0, y: 1), .init(x: 1, y: 1)]
        }
    }

    var left: Set<Coordinate2D> {
        switch self {
        case .minus:
            return [.init(x: -1, y: 0)]
        case .plus:
            return [.init(x: 0, y: 0), .init(x: -1, y: 1), .init(x: 0, y: 2)]
        case .corner:
            return [.init(x: -1, y: 0), .init(x: 1, y: 1), .init(x: 1, y: 2)]
        case .pillar:
            return [.init(x: -1, y: 0), .init(x: -1, y: 1), .init(x: -1, y: 2), .init(x: -1, y: 3)]
        case .square:
            return [.init(x: -1, y: 0), .init(x: -1, y: 1)]
        }
    }

    var right: Set<Coordinate2D> {
        switch self {
        case .minus:
            return [.init(x: 4, y: 0)]
        case .plus:
            return [.init(x: 2, y: 0), .init(x: 3, y: 1), .init(x: 2, y: 2)]
        case .corner:
            return [.init(x: 3, y: 0), .init(x: 3, y: 1), .init(x: 3, y: 2)]
        case .pillar:
            return [.init(x: 1, y: 0), .init(x: 1, y: 1), .init(x: 1, y: 2), .init(x: 1, y: 3)]
        case .square:
            return [.init(x: 2, y: 0), .init(x: 2, y: 1)]
        }
    }

    var bottom: Set<Coordinate2D> {
        switch self {
        case .minus:
            return [.init(x: 0, y: -1), .init(x: 1, y: -1), .init(x: 2, y: -1), .init(x: 3, y: -1)]
        case .plus:
            return [.init(x: 0, y: 0), .init(x: 1, y: -1), .init(x: 2, y: 0)]
        case .corner:
            return [.init(x: 0, y: -1), .init(x: 1, y: -1), .init(x: 2, y: -1)]
        case .pillar:
            return [.init(x: 0, y: -1)]
        case .square:
            return [.init(x: 0, y: -1), .init(x: 1, y: -1)]
        }
    }

    func side(for move: Move) -> Set<Coordinate2D> {
        switch move {
        case .left:
            return left
        case .right:
            return right
        }
    }
}

struct Chamber {
    let moves: [Move]

    func heightAfterLandslide(of amount: Int) -> Int {
        let types = RockShape.allCases
        var occupied: Set<Coordinate2D> = []
        var height = 0
        var step = 0
        var rock = 0
        var indexes: [Int] = []
        var heights: [Int: Int] = [:]
        var heightOffset: Int?
        rockLoop: while true {
            if rock % types.count == 0 && heightOffset == nil {
                // Keep track of height
                let moveIndex = step % moves.count
                if let lastHeight = heights[moveIndex] {
                    // Pattern found!
                    let heightIncrement = height - lastHeight
                    let index = indexes.firstIndex(of: moveIndex).unsafelyUnwrapped
                    let rocksPerPattern = (indexes.count - index) * 5
                    let numberOfRocksToGo = (amount - (rock - 1))
                    let numberOfCycleLeft = numberOfRocksToGo / rocksPerPattern
                    rock += numberOfCycleLeft * rocksPerPattern
                    heightOffset = numberOfCycleLeft * heightIncrement
                } else {
                    heights[moveIndex] = height
                    indexes.append(moveIndex)
                }
            }

            if rock == amount {
                break rockLoop
            }

            // Pick the rock
            let current = types[rock % types.count]
            rock += 1
            
            var position = Coordinate2D(x: 2, y: height + 3)
            fallLoop: while true {
                let move = moves[step % moves.count]
                step += 1

                // Can we do the move?
                if !current.side(for: move).map({ position.translated(by: $0) }).contains(where: { $0.x < 0 || $0.x >= 7 || occupied.contains($0) }) {
                    // Perform a move
                    position = position.adjacent(moving: move.direction)
                }

                // Can we go down?
                if current.bottom.map({ position.translated(by: $0) }).contains(where: { $0.y < 0 || occupied.contains($0) }) {
                    // Mark places as "occupied"
                    current.coordinates.forEach {
                        occupied.insert(position.translated(by: $0))
                    }
                    // calculate new height
                    height = max(height, position.y + current.height)
                    // new rock!
                    continue rockLoop
                }

                // Go down
                position.y -= 1
            }
        }
        return height + (heightOffset ?? 0)
    }
}

// MARK: - PART 1

extension Day17 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 3068, fromRaw: ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        Chamber(moves: input).heightAfterLandslide(of: 2022)
    }
}

// MARK: - PART 2

extension Day17 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 1_514_285_714_288, fromRaw: ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        Chamber(moves: input).heightAfterLandslide(of: 1_000_000_000_000)
    }
}
