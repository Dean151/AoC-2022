//
//  Day23.swift
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
struct Day23: Puzzle {
    typealias Input = Elves
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static var exampleRawInput: String {
        "....#..\n..###.#\n#...#.#\n.#...##\n#.###..\n##.#.##\n.#..#.."
    }
}

enum ProposedElves {
    case one(Coordinate2D)
    case multiple(Set<Coordinate2D>)
}

extension ProposedElves? {
    func compose(with new: Coordinate2D) -> ProposedElves {
        switch self {
        case .none:
            return .one(new)
        case .one(let old):
            return .multiple([old, new])
        case .multiple(var set):
            set.insert(new)
            return .multiple(set)
        }
    }
}

struct Elves: Parsable {
    var coordinates: Set<Coordinate2D>

    var groundCovered: Int {
        if coordinates.isEmpty {
            return 0
        }
        let (minX,maxX) = coordinates.map(by: \.x).minAndMax().unsafelyUnwrapped
        let (minY,maxY) = coordinates.map(by: \.y).minAndMax().unsafelyUnwrapped
        return abs(1 + maxX - minX) * abs(1 + maxY - minY) - coordinates.count
    }

    func afterRound(_ n: Int) -> Elves {
        var propositions: [Coordinate2D: ProposedElves] = [:]
        // Each elves makes propositions
        elvesLoop: for coordinate in coordinates {
            // Is there at least one elve?
            if adjacents(from: coordinate).intersection(coordinates).isEmpty {
                // Not moving
                assert(propositions[coordinate] == nil)
                propositions[coordinate] = .one(coordinate)
                continue elvesLoop
            }

            // Directions checking
            let directions: [Direction]
            switch n % 4 {
            case 0:
                directions = [.north, .south, .west, .east]
            case 1:
                directions = [.south, .west, .east, .north]
            case 2:
                directions = [.west, .east, .north, .south]
            case 3:
                directions = [.east, .north, .south, .west]
            default:
                fatalError("Impossible")
            }
            for direction in directions {
                if adjacents(from: coordinate, moving: direction).intersection(coordinates).isEmpty {
                    let to = coordinate.adjacent(moving: direction)
                    propositions[to] = propositions[to].compose(with: coordinate)
                    continue elvesLoop
                }
            }

            // Not moving
            assert(propositions[coordinate] == nil)
            propositions[coordinate] = .one(coordinate)
        }
        // Resolve propositions
        // Keep elves that do not move
        var coordinates: Set<Coordinate2D> = []
        for (to,elves) in propositions {
            switch elves {
            case .one:
                // Moves
                coordinates.insert(to)
            case .multiple(let set):
                // No one moves
                coordinates = coordinates.union(set)
            }
        }
        return .init(coordinates: coordinates)
    }

    func afterRounds(_ count: Int) -> Elves {
        var elves = self
        for round in 0..<count {
            elves = elves.afterRound(round)
        }
        return elves
    }

    func findFreezeTime() -> Int {
        var elves = self
        var rounds = 0
        repeat {
            let new = elves.afterRound(rounds)
            rounds += 1
            if new.coordinates == elves.coordinates {
                break
            }
            elves = new
        } while true
        return rounds
    }

    func adjacents(from coord: Coordinate2D) -> Set<Coordinate2D> {
        return [
            .init(x: coord.x - 1, y: coord.y - 1), .init(x: coord.x, y: coord.y - 1), .init(x: coord.x + 1, y: coord.y - 1),
            .init(x: coord.x - 1, y: coord.y), .init(x: coord.x + 1, y: coord.y),
            .init(x: coord.x - 1, y: coord.y + 1), .init(x: coord.x, y: coord.y + 1), .init(x: coord.x + 1, y: coord.y + 1),
        ]
    }

    func adjacents(from coord: Coordinate2D, moving direction: Direction) -> Set<Coordinate2D> {
        switch direction {
        case .north:
            return [.init(x: coord.x - 1, y: coord.y - 1), .init(x: coord.x, y: coord.y - 1), .init(x: coord.x + 1, y: coord.y - 1)]
        case .east:
            return [.init(x: coord.x + 1, y: coord.y - 1), .init(x: coord.x + 1, y: coord.y), .init(x: coord.x + 1, y: coord.y + 1)]
        case .south:
            return [.init(x: coord.x - 1, y: coord.y + 1), .init(x: coord.x, y: coord.y + 1), .init(x: coord.x + 1, y: coord.y + 1)]
        case .west:
            return [.init(x: coord.x - 1, y: coord.y - 1), .init(x: coord.x - 1, y: coord.y), .init(x: coord.x - 1, y: coord.y + 1)]
        }
    }

    static func parse(raw: String) throws -> Elves {
        var coordinates: Set<Coordinate2D> = []
        for (y,line) in raw.components(separatedBy: .newlines).enumerated() {
            for (x,char) in line.enumerated() {
                switch char {
                case ".":
                    break
                case "#":
                    coordinates.insert(.init(x: x, y: y))
                default:
                    throw InputError.unexpectedInput(unrecognized: String(char))
                }
            }
        }
        return .init(coordinates: coordinates)
    }
}

// MARK: - PART 1

extension Day23 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 25, fromRaw: "##\n#.\n..\n##"),
            assert(expectation: 110, fromRaw: exampleRawInput),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.afterRounds(10).groundCovered
    }
}

// MARK: - PART 2

extension Day23 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 4, fromRaw: "##\n#.\n..\n##"),
            assert(expectation: 20, fromRaw: exampleRawInput),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        input.findFreezeTime()
    }
}

// MARK: - Custom string convertible

extension Elves: CustomStringConvertible {
    var description: String {
        let (minX,maxX) = coordinates.map(by: \.x).minAndMax().unsafelyUnwrapped
        let (minY,maxY) = coordinates.map(by: \.y).minAndMax().unsafelyUnwrapped

        var output = ""
        for y in minY...maxY {
            for x in minX...maxX {
                if coordinates.contains(.init(x: x, y: y)) {
                    output += "#"
                } else {
                    output += "."
                }
            }
            output += "\n"
        }
        return output
    }
}
