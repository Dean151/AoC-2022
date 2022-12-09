//
//  CartesianGeometry.swift
//

import Foundation

public struct Coordinate2D: Hashable, Equatable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
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
