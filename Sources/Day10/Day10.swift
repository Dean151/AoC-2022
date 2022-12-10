//
//  Day10.swift
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
struct Day10: Puzzle {
    typealias Input = [Command]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Void
}

enum Command: Parsable {
    case noop
    case addx(value: Int)

    static func parse(raw: String) throws -> Command {
        let components = raw.components(separatedBy: .whitespaces)
        if components[0] == "noop", components.count == 1 {
            return .noop
        }
        guard components.count == 2, components[0] == "addx", let value = Int(components[1]) else {
            throw InputError.unexpectedInput(unrecognized: raw)
        }
        return .addx(value: value)
    }
}

enum CPU {
     static func execute(program commands: [Command], duringCycle: (Int, Int) -> Void) {
         var register = 1
         var cycle = 0

         func performCycle() {
             // Starting a cycle
             cycle += 1
             // During the cycle
             duringCycle(cycle, register)
             // Ending the cycle
         }

         for command in commands {
             switch command {
             case .noop:
                 performCycle()
             case .addx(value: let value):
                 performCycle()
                 performCycle()
                 register += value
             }
         }
    }
}

// MARK: - PART 1

extension Day10 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 13140, fromRaw: "addx 15\naddx -11\naddx 6\naddx -3\naddx 5\naddx -1\naddx -8\naddx 13\naddx 4\nnoop\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx -35\naddx 1\naddx 24\naddx -19\naddx 1\naddx 16\naddx -11\nnoop\nnoop\naddx 21\naddx -15\nnoop\nnoop\naddx -3\naddx 9\naddx 1\naddx -3\naddx 8\naddx 1\naddx 5\nnoop\nnoop\nnoop\nnoop\nnoop\naddx -36\nnoop\naddx 1\naddx 7\nnoop\nnoop\nnoop\naddx 2\naddx 6\nnoop\nnoop\nnoop\nnoop\nnoop\naddx 1\nnoop\nnoop\naddx 7\naddx 1\nnoop\naddx -13\naddx 13\naddx 7\nnoop\naddx 1\naddx -33\nnoop\nnoop\nnoop\naddx 2\nnoop\nnoop\nnoop\naddx 8\nnoop\naddx -1\naddx 2\naddx 1\nnoop\naddx 17\naddx -9\naddx 1\naddx 1\naddx -3\naddx 11\nnoop\nnoop\naddx 1\nnoop\naddx 1\nnoop\nnoop\naddx -13\naddx -19\naddx 1\naddx 3\naddx 26\naddx -30\naddx 12\naddx -1\naddx 3\naddx 1\nnoop\nnoop\nnoop\naddx -9\naddx 18\naddx 1\naddx 2\nnoop\nnoop\naddx 9\nnoop\nnoop\nnoop\naddx -1\naddx 2\naddx -37\naddx 1\naddx 3\nnoop\naddx 15\naddx -21\naddx 22\naddx -6\naddx 1\nnoop\naddx 2\naddx 1\nnoop\naddx -10\nnoop\nnoop\naddx 20\naddx 1\naddx 2\naddx 2\naddx -6\naddx -11\nnoop\nnoop\nnoop")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var signalStrengthSum = 0
        let cyclesOfInterest: Set<Int> = [20, 60, 100, 140, 180, 220]
        CPU.execute(program: input) { cycle, register in
            guard cyclesOfInterest.contains(cycle) else {
                return
            }
            signalStrengthSum += cycle * register
        }
        return signalStrengthSum
    }
}

// MARK: - PART 2

extension Day10 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: (), fromRaw: "addx 15\naddx -11\naddx 6\naddx -3\naddx 5\naddx -1\naddx -8\naddx 13\naddx 4\nnoop\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx 5\naddx -1\naddx -35\naddx 1\naddx 24\naddx -19\naddx 1\naddx 16\naddx -11\nnoop\nnoop\naddx 21\naddx -15\nnoop\nnoop\naddx -3\naddx 9\naddx 1\naddx -3\naddx 8\naddx 1\naddx 5\nnoop\nnoop\nnoop\nnoop\nnoop\naddx -36\nnoop\naddx 1\naddx 7\nnoop\nnoop\nnoop\naddx 2\naddx 6\nnoop\nnoop\nnoop\nnoop\nnoop\naddx 1\nnoop\nnoop\naddx 7\naddx 1\nnoop\naddx -13\naddx 13\naddx 7\nnoop\naddx 1\naddx -33\nnoop\nnoop\nnoop\naddx 2\nnoop\nnoop\nnoop\naddx 8\nnoop\naddx -1\naddx 2\naddx 1\nnoop\naddx 17\naddx -9\naddx 1\naddx 1\naddx -3\naddx 11\nnoop\nnoop\naddx 1\nnoop\naddx 1\nnoop\nnoop\naddx -13\naddx -19\naddx 1\naddx 3\naddx 26\naddx -30\naddx 12\naddx -1\naddx 3\naddx 1\nnoop\nnoop\nnoop\naddx -9\naddx 18\naddx 1\naddx 2\nnoop\nnoop\naddx 9\nnoop\nnoop\nnoop\naddx -1\naddx 2\naddx -37\naddx 1\naddx 3\nnoop\naddx 15\naddx -21\naddx 22\naddx -6\naddx 1\nnoop\naddx 2\naddx 1\nnoop\naddx -10\nnoop\nnoop\naddx 20\naddx 1\naddx 2\naddx 2\naddx -6\naddx -11\nnoop\nnoop\nnoop")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        CPU.execute(program: input) { cycle, register in
            if abs(((cycle-1) % 40) - register) <= 1 {
                print("#", terminator: "")
            } else {
                print(" ", terminator: "")
            }
            if cycle % 40 == 0 {
                print("", terminator: "\n")
            }
        }
    }
}
