//
//  Day16.swift
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
struct Day16: Puzzle {
    typealias Input = [String: Valve]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Never

    static func transform(raw: String) async throws -> Input {
        let lines = raw.components(separatedBy: .newlines)
        return try lines.reduce(into: Input(minimumCapacity: lines.count), {
            let valve = try Valve.parse(raw: $1)
            $0[valve.identifier] = valve
        })
    }
}

struct Valve: Parsable, Hashable {
    let identifier: String
    let flowRate: Int
    let leadsTo: Set<String>

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func parse(raw: String) throws -> Valve {
        let regex = #/^Valve ([A-Z]{2}) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)$/#
        guard let match = raw.firstMatch(of: regex) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        let identifier = String(match.1)
        guard let flowRate = Int(String(match.2)) else {
            throw InputError.unexpectedInput(unrecognized: match.2)
        }
        let leadsTo = Set(match.3.components(separatedBy: ", "))
        return .init(identifier: identifier, flowRate: flowRate, leadsTo: leadsTo)
    }
}

}

// MARK: - PART 1

extension Day16 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 1651, fromRaw: "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB\nValve BB has flow rate=13; tunnels lead to valves CC, AA\nValve CC has flow rate=2; tunnels lead to valves DD, BB\nValve DD has flow rate=20; tunnels lead to valves CC, AA, EE\nValve EE has flow rate=3; tunnels lead to valves FF, DD\nValve FF has flow rate=0; tunnels lead to valves EE, GG\nValve GG has flow rate=0; tunnels lead to valves FF, HH\nValve HH has flow rate=22; tunnel leads to valve GG\nValve II has flow rate=0; tunnels lead to valves AA, JJ\nValve JJ has flow rate=21; tunnel leads to valve II")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        // TODO: Solve part 1 :)
        throw ExecutionError.notSolved
    }
}

// MARK: - PART 2

extension Day16 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            // TODO: add expectations for part 2
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
