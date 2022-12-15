//
//  Day15.swift
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
struct Day15: Puzzle {
    typealias Input = MapAndRow
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

extension Coordinate2D: Parsable {
    public static func parse(raw: String) throws -> Coordinate2D {
        let components = raw.components(separatedBy: ", ")
        guard components.count == 2, components[0].hasPrefix("x="), components[1].hasPrefix("y=") else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let rawX = components[0].components(separatedBy: "=").last.unsafelyUnwrapped
        let rawY = components[1].components(separatedBy: "=").last.unsafelyUnwrapped
        guard let x = Int(rawX), let y = Int(rawY) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(x: x, y: y)
    }

    var tuningFrequency: Int {
        (x * 4_000_000) + y
    }
}

struct Sensor: Parsable {
    let coordinate: Coordinate2D
    let beacon: Coordinate2D

    static func parse(raw: String) throws -> Self {
        guard raw.hasPrefix("Sensor at ") else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let components = raw.suffix(from: raw.index(raw.startIndex, offsetBy: 10)).components(separatedBy: ": closest beacon is at ")
        guard components.count == 2 else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(coordinate: try .parse(raw: components[0]), beacon: try .parse(raw: components[1]))
    }
}

struct MapAndRow: Parsable {
    let rowOfInterest: Int
    let searchArea: Int
    let sensors: [Sensor]

    func impossiblePositions(at row: Int, inArea: Bool = false) throws -> Set<ClosedRange<Int>> {
        var positions: Set<ClosedRange<Int>> = []
        for sensor in sensors {
            let distance = sensor.coordinate.manhattanDistance(to: sensor.beacon)
            let distanceFromRow = sensor.coordinate.manhattanDistance(to: .init(x: sensor.coordinate.x, y: row))
            // If the distance does not cover the row of interest, we dismiss
            if distanceFromRow > distance {
                continue
            }
            let diff = distance - distanceFromRow
            let minX = inArea ? max(0, sensor.coordinate.x - diff) : sensor.coordinate.x - diff
            let maxX = inArea ? min(searchArea, sensor.coordinate.x + diff) : sensor.coordinate.x + diff
            positions.insert(minX...maxX)
        }
        return positions
    }

    func distressPosition() throws -> Coordinate2D {
        let center = searchArea / 2
        loop: for index in 0...searchArea {
            let y: Int
            if index % 2 == 0 {
                y = center + (index / 2)
            } else {
                y = center - ((index / 2) + 1)
            }
            let positions = try impossiblePositions(at: y, inArea: true).consolidate()
            switch positions.count {
            case 1:
                let stride = positions[0]
                if stride.lowerBound != 0 {
                    return .init(x: 0, y: y)
                }
                if stride.upperBound != searchArea {
                    return .init(x: searchArea, y: y)
                }
                continue loop
            case 2:
                return .init(x: positions[0].upperBound + 1, y: y)
            default:
                break loop
            }
        }
        throw ExecutionError.unsolvable
    }

    static func parse(raw: String) throws -> Self {
        return .init(rowOfInterest: 2_000_000, searchArea: 4_000_000, sensors: try raw.components(separatedBy: .newlines).map({ try .parse(raw: $0) }))
    }

    static var testInput: Self {
        let raw = "Sensor at x=2, y=18: closest beacon is at x=-2, y=15\nSensor at x=9, y=16: closest beacon is at x=10, y=16\nSensor at x=13, y=2: closest beacon is at x=15, y=3\nSensor at x=12, y=14: closest beacon is at x=10, y=16\nSensor at x=10, y=20: closest beacon is at x=10, y=16\nSensor at x=14, y=17: closest beacon is at x=10, y=16\nSensor at x=8, y=7: closest beacon is at x=2, y=10\nSensor at x=2, y=0: closest beacon is at x=2, y=10\nSensor at x=0, y=11: closest beacon is at x=2, y=10\nSensor at x=20, y=14: closest beacon is at x=25, y=17\nSensor at x=17, y=20: closest beacon is at x=21, y=22\nSensor at x=16, y=7: closest beacon is at x=15, y=3\nSensor at x=14, y=3: closest beacon is at x=15, y=3\nSensor at x=20, y=1: closest beacon is at x=15, y=3"
        return .init(rowOfInterest: 10, searchArea: 20, sensors: raw.components(separatedBy: .newlines).map({ try! .parse(raw: $0) }))
    }
}

// MARK: - PART 1

extension Day15 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {

        return [
            assert(expectation: 26, from: .testInput)
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let ranges = try input.impossiblePositions(at: input.rowOfInterest)
        let positions = ranges.reduce(into: Set<Coordinate2D>()) { partialResult, range in
            range.forEach { y in
                partialResult.insert(.init(x: input.rowOfInterest, y: y))
            }
        }
        return positions.subtracting(input.sensors.map(by: \.beacon)).count
    }
}

// MARK: - PART 2

extension Day15 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 56_000_011, from: .testInput)
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.distressPosition().tuningFrequency
    }
}
