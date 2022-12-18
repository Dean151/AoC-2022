//
//  Day18.swift
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
struct Day18: Puzzle {
    typealias Input = Set<Coordinate3D>
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int

    static func transform(raw: String) async throws -> Input {
        return Set(try raw.components(separatedBy: .newlines).map({ try .parse(raw: $0) }))
    }
}

extension Coordinate3D: Parsable {
    public static func parse(raw: String) throws -> Coordinate3D {
        let components = raw.components(separatedBy: ",").compactMap({ Int($0) })
        guard components.count == 3 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(x: components[0], y: components[1], z: components[2])
    }
}

// MARK: - PART 1

extension Day18 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 6, fromRaw: "1,1,1"),
            assert(expectation: 10, fromRaw: "1,1,1\n2,1,1"),
            assert(expectation: 64, fromRaw: "2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n1,2,5\n3,2,5\n2,1,5\n2,3,5"),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.map({ $0.adjacents.filter({ !input.contains($0) }).count }).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day18 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 58, fromRaw: "2,2,2\n1,2,2\n3,2,2\n2,1,2\n2,3,2\n2,2,1\n2,2,3\n2,2,4\n2,2,6\n1,2,5\n3,2,5\n2,1,5\n2,3,5"),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let (minX,maxX) = input.map(by: \.x).minAndMax().unsafelyUnwrapped
        let (minY,maxY) = input.map(by: \.y).minAndMax().unsafelyUnwrapped
        let (minZ,maxZ) = input.map(by: \.z).minAndMax().unsafelyUnwrapped

        var exterior: Set<Coordinate3D> = []
        let first = Coordinate3D(x: minX, y: minY, z: minZ)
        guard !input.contains(first) else {
            throw ExecutionError.unsolvable
        }

        var toGo: [Coordinate3D] = [first]
        while let coordinate = toGo.popLast() {
            let adjacents = coordinate.adjacents.filter {
                $0.isWithin(x: minX-1...maxX+1, y: minY-1...maxY+1, z: minZ-1...maxZ+1) && !exterior.contains($0) && !input.contains($0)
            }
            adjacents.forEach {
                exterior.insert($0)
            }
            toGo.append(contentsOf: adjacents)
        }

        return input.map({ $0.adjacents.filter({ exterior.contains($0) }).count }).reduce(0, +)
    }
}
