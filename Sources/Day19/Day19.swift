//
//  Day19.swift
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
struct Day19: Puzzle {
    typealias Input = [Blueprint]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

enum Robot: CaseIterable {
    case ore
    case clay
    case obsidian
    case geode

    var keyPath: KeyPath<Resources, Int> {
        switch self {
        case .ore:
            return \.ore
        case .clay:
            return \.clay
        case .obsidian:
            return \.obsidian
        case .geode:
            fatalError("Impossible!")
        }
    }
}

struct Resources: Hashable {
    var ore: Int
    var clay: Int
    var obsidian: Int

    init(ore: Int = 0, clay: Int = 0, obsidian: Int = 0) {
        self.ore = ore
        self.clay = clay
        self.obsidian = obsidian
    }

    func canAfford(cost: Resources) -> Bool {
        cost.ore <= ore && cost.clay <= clay && cost.obsidian <= obsidian
    }

    static func +=(lhs: inout Resources, rhs: Resources) {
        lhs.ore += rhs.ore
        lhs.clay += rhs.clay
        lhs.obsidian += rhs.obsidian
    }

    static func -=(lhs: inout Resources, rhs: Resources) {
        lhs.ore -= rhs.ore
        lhs.clay -= rhs.clay
        lhs.obsidian -= rhs.obsidian
    }
}

struct State: Hashable {
    var resources: Resources
    var robots: [Robot: Int]
    var geodesOpened: Int

    static let initial = State(resources: .init(), robots: [.ore: 1, .clay: 0, .obsidian: 0, .geode: 0], geodesOpened: 0)

    func next(making robot: (type: Robot, cost: Resources)? = nil) throws -> State {
        var new = self
        new.resources += Resources(ore: robots[.ore] ?? 0, clay: robots[.clay] ?? 0, obsidian: robots[.obsidian] ?? 0)
        new.geodesOpened += robots[.geode] ?? 0
        if let robot {
            guard resources.canAfford(cost: robot.cost) else {
                throw ExecutionError.unsolvable
            }
            new.resources -= robot.cost
            new.robots[robot.type] = (new.robots[robot.type] ?? 0) + 1
        }
        return new
    }
}

struct Blueprint: Parsable {
    let identifier: Int
    let costs: [Robot: Resources]

    func maxCost(of resource: KeyPath<Resources, Int>) -> Int {
        costs.values.map(by: resource).max().unsafelyUnwrapped
    }

    func qualityLevel(in minutes: Int) throws -> Int {
        try identifier * maxNumberOfGeodesOpened(in: minutes)
    }

    func maxNumberOfGeodesOpened(in minutes: Int) throws -> Int {
        var states: Set<State> = [.initial]
        for minute in 1...minutes-1 {
            var new: Set<State> = []
            for state in states {
                let affordable = affordableRobots(using: state.resources)
                if affordable.contains(.geode) {
                    new.insert(try state.next(making: (type: .geode, cost: costs[.geode]!)))
                    continue
                }
                new.insert(try state.next())
                for robot in affordable.filter({ state.robots[$0].unsafelyUnwrapped < maxCost(of: $0.keyPath) }) {
                    new.insert(try state.next(making: (type: robot, cost: costs[robot]!)))
                }
            }
            let max = new.map({ $0.geodesOpened + $0.robots[.geode].unsafelyUnwrapped }).max().unsafelyUnwrapped
            if minute == minutes - 1 {
                return max
            }
            states = new.filter({ $0.geodesOpened + $0.robots[.geode].unsafelyUnwrapped == max })
        }
        throw ExecutionError.unsolvable
    }

    func affordableRobots(using resources: Resources) -> Set<Robot> {
        Set(Robot.allCases.filter({ resources.canAfford(cost: costs[$0]!) }))
    }

    static func parse(raw: String) throws -> Blueprint {
        let regex = #/^Blueprint (?<id>\d+): Each ore robot costs (?<orecost>\d+) ore\. Each clay robot costs (?<claycost>\d+) ore\. Each obsidian robot costs (?<obsidiancost1>\d+) ore and (?<obsidiancost2>\d+) clay. Each geode robot costs (?<geodecost1>\d+) ore and (?<geodecost2>\d+) obsidian\.$/#
        guard let match = raw.firstMatch(of: regex) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        guard let id = Int(match.id), let oreCost = Int(match.orecost), let clayCost = Int(match.claycost),
                let obsidianCost1 = Int(match.obsidiancost1), let obsidianCost2 = Int(match.obsidiancost2),
                let geodeCost1 = Int(match.geodecost1), let geodeCost2 = Int(match.geodecost2) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .init(
            identifier: id,
            costs: [
                .ore: .init(ore: oreCost),
                .clay: .init(ore: clayCost),
                .obsidian: .init(ore: obsidianCost1, clay: obsidianCost2),
                .geode: .init(ore: geodeCost1, obsidian: geodeCost2)
            ]
        )
    }
}

// MARK: - PART 1

extension Day19 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 33, fromRaw: "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.\nBlueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."),
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        try input.map({ try $0.qualityLevel(in: 24) }).reduce(0, +)
    }
}

// MARK: - PART 2

extension Day19 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 56, fromRaw: "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian."),
            assert(expectation: 62, fromRaw: "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian."),
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        try input.prefix(3).map({ try $0.maxNumberOfGeodesOpened(in: 32) }).reduce(1, *)
    }
}
