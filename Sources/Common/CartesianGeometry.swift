//
//  CartesianGeometry.swift
//

import Foundation

import AoC

// MARK: - 2D

public struct Coordinate2D: Hashable, Equatable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

extension Coordinate2D {
    public func translated(by other: Coordinate2D) -> Coordinate2D {
        .init(x: x + other.x, y: y + other.y)
    }

    public var adjacents: [Coordinate2D] {
        [
            .init(x: x - 1, y: y),
            .init(x: x + 1, y: y),
            .init(x: x, y: y - 1),
            .init(x: x, y: y + 1),
        ]
    }

    public func adjacent(moving direction: Direction) -> Coordinate2D {
        switch direction {
        case .north:
            return .init(x: x, y: y - 1)
        case .east:
            return .init(x: x + 1, y: y)
        case .south:
            return .init(x: x, y: y + 1)
        case .west:
            return .init(x: x - 1, y: y)
        }
    }

    public func stride(to other: Coordinate2D, forEach: (Coordinate2D) throws -> Void) throws {
        if self == other {
            try forEach(self)
            return
        }
        if x == other.x {
            let min = min(y, other.y)
            let max = max(y, other.y)
            for y in min...max {
                try forEach(.init(x: x, y: y))
            }
        } else if y == other.y {
            let min = min(x, other.x)
            let max = max(x, other.x)
            for x in min...max {
                try forEach(.init(x: x, y: y))
            }
        } else {
            throw ExecutionError.unsolvable
        }
    }
}

extension Coordinate2D {
    public static let zero = Coordinate2D(x: 0, y: 0)
}

public enum Direction: CaseIterable {
    case north, east, south, west
}

extension Coordinate2D {
    public func manhattanDistance(to other: Coordinate2D) -> Int {
        abs(other.x - x) + abs(other.y - y)
    }
}

// MARK: - 3D

public struct Coordinate3D: Hashable, Equatable {
    public var x: Int
    public var y: Int
    public var z: Int

    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
}

extension Coordinate3D {
    public var adjacents: [Coordinate3D] {
        [
            .init(x: x - 1, y: y, z: z),
            .init(x: x + 1, y: y, z: z),
            .init(x: x, y: y - 1, z: z),
            .init(x: x, y: y + 1, z: z),
            .init(x: x, y: y, z: z - 1),
            .init(x: x, y: y, z: z + 1),
        ]
    }

    public func isWithin(x xRange: ClosedRange<Int>, y yRange: ClosedRange<Int>, z zRange: ClosedRange<Int>) -> Bool {
        xRange.contains(x) && yRange.contains(y) && zRange.contains(z)
    }
}
