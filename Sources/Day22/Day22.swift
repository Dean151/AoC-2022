//
//  Day22.swift
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
struct Day22: Puzzle {
    typealias Input = MapAndInstructions
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var rawInputTrimMode: RawInputTrimMode {
        .trim(set: .newlines)
    }

    private static var testRaw: String {
        "        ...#\n        .#..\n        #...\n        ....\n...#.......#\n........#...\n..#....#....\n..........#.\n        ...#....\n        .....#..\n        .#......\n        ......#.\n\n10R5L5R10L4R5L5"
    }
}

struct Position {
    var coordinate: Coordinate2D
    var direction: Direction

    var euristic: Int {
        return 1000 * (coordinate.y + 1) + 4 * (coordinate.x + 1) + direction.euristic
    }
}

extension Direction {
    var euristic: Int {
        switch self {
        case .east:
            return 0
        case .south:
            return 1
        case .west:
            return 2
        case .north:
            return 3
        }
    }
}

struct CubeMap: Parsable {
    enum Element {
        case empty
        case wall
    }

    enum WrapMode {
        case teleport
        case cube
    }

    enum FoldingMode {
        case test
        case puzzle
    }

    let coordinates: [Coordinate2D: Element]
    let foldingMode: FoldingMode

    func wrapAround(_ position: Position, mode: WrapMode) throws -> Position {
        switch mode {
        case .teleport:
            return try teleportWrapAround(position)
        case .cube:
            return try cubeWrapAround(position)
        }
    }

    func teleportWrapAround(_ position: Position) throws -> Position {
        let coordinate: Coordinate2D
        switch position.direction {
        case .north:
            coordinate = coordinates.keys.filter({ $0.x == position.coordinate.x }).max(by: \.y)!
        case .east:
            coordinate = coordinates.keys.filter({ $0.y == position.coordinate.y }).min(by: \.x)!
        case .south:
            coordinate = coordinates.keys.filter({ $0.x == position.coordinate.x }).min(by: \.y)!
        case .west:
            coordinate = coordinates.keys.filter({ $0.y == position.coordinate.y }).max(by: \.x)!
        }
        return .init(coordinate: coordinate, direction: position.direction)
    }

    func cubeWrapAround(_ position: Position) throws -> Position {
        switch foldingMode {
        case .test:
            switch position.direction {
            case .north, .south:
                switch position.coordinate.x {
                case 0...3:
                    return try teleportWrapAround(.init(coordinate: .init(x: 8 + position.coordinate.x, y: 0), direction: position.direction.after(turning: .around)))
                case 4...7:
                    if position.direction == .north {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: position.coordinate.x % 4), direction: position.direction.after(turning: .right)))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 11 - (position.coordinate.x % 4)), direction: position.direction.after(turning: .left)))
                    }
                case 8...11:
                    return try teleportWrapAround(.init(coordinate: .init(x: 3 - (position.coordinate.x % 4), y: 0), direction: position.direction.after(turning: .around)))
                case 12...15:
                    if position.direction == .north {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 7 - position.coordinate.x % 4), direction: position.direction.after(turning: .left)))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 7 - (position.coordinate.x % 4)), direction: position.direction.after(turning: .right)))
                    }
                default:
                    throw ExecutionError.unsolvable
                }
            case .east, .west:
                switch position.coordinate.y {
                case 0...3:
                    if position.direction == .west {
                        return try teleportWrapAround(.init(coordinate: .init(x: 4 + position.coordinate.y, y: 0), direction: position.direction.after(turning: .left)))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 7 - position.coordinate.y), direction: position.direction.after(turning: .around)))
                    }
                case 4...7:
                    return try teleportWrapAround(.init(coordinate: .init(x: 15 - position.coordinate.y % 4, y: 0), direction: position.direction.after(turning: .right)))
                case 8...11:
                    if position.direction == .west {
                        return try teleportWrapAround(.init(coordinate: .init(x: 7 - position.coordinate.y % 4, y: 0), direction: position.direction.after(turning: .left)))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 3 - position.coordinate.y % 4), direction: position.direction.after(turning: .around)))
                    }
                default:
                    throw ExecutionError.unsolvable
                }
            }
        case .puzzle:
            switch position.direction {
            case .north, .south:
                switch position.coordinate.x {
                case 0...49:
                    if position.direction == .north {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 50 + position.coordinate.x), direction: position.direction.after(turning: .right)))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: 100 + position.coordinate.x, y: 0), direction: position.direction))
                    }
                case 50...99:
                    if position.direction == .north {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 100 + position.coordinate.x), direction: position.direction.after(turning: .right)))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 100 + position.coordinate.x), direction: position.direction.after(turning: .right)))
                    }
                case 100...149:
                    if position.direction == .north {
                        return try teleportWrapAround(.init(coordinate: .init(x: position.coordinate.x - 100, y: 0), direction: position.direction))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: 0, y: position.coordinate.x - 50), direction: position.direction.after(turning: .right)))
                    }
                default:
                    throw ExecutionError.unsolvable
                }
            case .west, .east:
                switch position.coordinate.y {
                case 0...49:
                    return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 149 - position.coordinate.y), direction: position.direction.after(turning: .around)))
                case 50...99:
                    if position.direction == .east {
                        return try teleportWrapAround(.init(coordinate: .init(x: 50 + position.coordinate.y, y: 0), direction: position.direction.after(turning: .left)))
                    } else {
                        return try teleportWrapAround(.init(coordinate: .init(x: position.coordinate.y - 50, y: 0), direction: position.direction.after(turning: .left)))
                    }
                case 100...149:
                    return try teleportWrapAround(.init(coordinate: .init(x: 0, y: 149 - position.coordinate.y), direction: position.direction.after(turning: .around)))
                case 150...199:
                    return try teleportWrapAround(.init(coordinate: .init(x: position.coordinate.y - 100, y: 0), direction: position.direction.after(turning: .left)))
                default:
                    throw ExecutionError.unsolvable
                }
            }
        }
    }

    static func parse(raw: String) throws -> CubeMap {
        var coordinates: [Coordinate2D: Element] = [:]
        for (y, line) in raw.components(separatedBy: .newlines).enumerated() {
            for (x, char) in line.enumerated() {
                switch char {
                case ".":
                    coordinates[.init(x: x, y: y)] = .empty
                case "#":
                    coordinates[.init(x: x, y: y)] = .wall
                case " ":
                    break
                default:
                    throw InputError.unexpectedInput(unrecognized: String(char))
                }
            }
        }
        let mode: FoldingMode
        switch coordinates.count {
        case 96:
            mode = .test
        case 15_000:
            mode = .puzzle
        default:
            throw ExecutionError.notSolved
        }
        return .init(coordinates: coordinates, foldingMode: mode)
    }
}

enum Instruction {
    case left, right
    case forward(unit: Int)
}

struct MapAndInstructions: Parsable {
    var map: CubeMap
    var instructions: [Instruction]

    func finalPosition(mode: CubeMap.WrapMode) throws -> Position {
        var position = try map.wrapAround(.init(coordinate: .init(x: 0, y: 0), direction: .east), mode: .teleport)
        for instruction in instructions {
            switch instruction {
            case .left:
                position.direction = position.direction.after(turning: .left)
            case .right:
                position.direction = position.direction.after(turning: .right)
            case .forward(let unit):
                moveLoop: for _ in 1...unit {
                    let adjacent = position.coordinate.adjacent(moving: position.direction)
                    if map.coordinates[adjacent] == .wall {
                        break moveLoop
                    }
                    if map.coordinates[adjacent] == nil {
                        let wrapped = try map.wrapAround(position, mode: mode)
                        if map.coordinates[wrapped.coordinate] == .wall {
                            break moveLoop
                        }
                        position = wrapped
                    } else {
                        position.coordinate = adjacent
                    }
                }
            }
        }
        return position
    }

    static func parse(raw: String) throws -> MapAndInstructions {
        let components = raw.components(separatedBy: "\n\n")
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(map: try .parse(raw: components[0]), instructions: try parseInstructions(components[1]))
    }

    private static func parseInstructions(_ raw: String) throws -> [Instruction] {
        var instructions: [Instruction] = []
        for sub in raw.components(separatedBy: "R") {
            for subsub in sub.components(separatedBy: "L") {
                guard let value = Int(subsub) else {
                    throw InputError.unexpectedInput(unrecognized: subsub)
                }
                instructions.append(.forward(unit: value))
                instructions.append(.left)
            }
            instructions.removeLast()
            instructions.append(.right)
        }
        instructions.removeLast()
        return instructions
    }
}

// MARK: - PART 1

extension Day22 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 6032, fromRaw: testRaw)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try input.finalPosition(mode: .teleport).euristic
    }
}

// MARK: - PART 2

extension Day22 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 5031, fromRaw: testRaw)
        ]
    }

    // 2357 Too low
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.finalPosition(mode: .cube).euristic
    }
}
