//
//  Day07.swift
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
struct Day07: Puzzle {
    typealias Input = Hierarchy
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

struct Hierarchy: Parsable {
    final class Folder {
        let name: String
        weak var parent: Folder?
        var subfolders: [String: Folder]
        var files: [String: Int]

        var level: Int {
            guard let parent else {
                return 0
            }
            return parent.level + 1
        }

        var absoluteName: String {
            guard let parent else {
                return ""
            }
            return parent.absoluteName + "/" + name
        }

        var size: Int {
            subfolders.values.map(by: \.size).reduce(0, +) + files.values.reduce(0, +)
        }

        var foldersRecursive: [Folder] {
            var folder = [self]
            for subfolder in subfolders.values {
                folder.append(contentsOf: subfolder.foldersRecursive)
            }
            return folder
        }

        init(name: String, parent: Folder? = nil) {
            self.name = name
            self.parent = parent
            self.subfolders = [:]
            self.files = [:]

            if let parent {
                parent.subfolders[name] = self
            }
        }
    }

    let root: Folder

    var folders: [Folder] {
        root.foldersRecursive
    }

    static func parse(raw: String) throws -> Hierarchy {
        let lines = raw.components(separatedBy: .newlines)
        let root = Folder(name: "/")
        var folders: [String: Folder] = ["/": root]
        var current = root
        for line in lines[1...] {
            if line.hasPrefix("$ cd") {
                guard let folderName = line.components(separatedBy: .whitespaces).last else {
                    throw InputError.unexpectedInput(unrecognized: line)
                }
                if folderName == ".." {
                    guard let folder = current.parent else {
                        throw InputError.unexpectedInput(unrecognized: line)
                    }
                    current = folder
                } else {
                    guard let folder = folders[current.absoluteName + "/" + folderName] else {
                        throw InputError.unexpectedInput(unrecognized: line)
                    }
                    current = folder
                }
            } else if line == "$ ls" {
                continue
            } else {
                if line.hasPrefix("dir") {
                    guard let folderName = line.components(separatedBy: .whitespaces).last else {
                        throw InputError.unexpectedInput(unrecognized: line)
                    }
                    folders[current.absoluteName + "/" + folderName] = .init(name: folderName, parent: current)
                } else {
                    let components = line.components(separatedBy: .whitespaces)
                    guard components.count == 2, let size = Int(components[0]) else {
                        throw InputError.unexpectedInput(unrecognized: line)
                    }
                    current.files[components[1]] = size
                }
            }
        }
        return .init(root: root)
    }
}

// MARK: - PART 1

extension Day07 {
    static var partOneExpectations: [any Expectation<Input, OutputPartOne>] {
        [
            assert(expectation: 95437, fromRaw: "$ cd /\n$ ls\ndir a\n14848514 b.txt\n8504156 c.dat\ndir d\n$ cd a\n$ ls\ndir e\n29116 f\n2557 g\n62596 h.lst\n$ cd e\n$ ls\n584 i\n$ cd ..\n$ cd ..\n$ cd d\n$ ls\n4060174 j\n8033020 d.log\n5626152 d.ext\n7214296 k")
        ]
    }

    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        input.folders.filter({ $0.size <= 100_000 }).reduce(0, { $0 + $1.size })
    }
}

// MARK: - PART 2

extension Day07 {
    static var partTwoExpectations: [any Expectation<Input, OutputPartTwo>] {
        [
            assert(expectation: 24_933_642, fromRaw: "$ cd /\n$ ls\ndir a\n14848514 b.txt\n8504156 c.dat\ndir d\n$ cd a\n$ ls\ndir e\n29116 f\n2557 g\n62596 h.lst\n$ cd e\n$ ls\n584 i\n$ cd ..\n$ cd ..\n$ cd d\n$ ls\n4060174 j\n8033020 d.log\n5626152 d.ext\n7214296 k")
        ]
    }

    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let diskSize = 70_000_000
        let required = 30_000_000
        let used = input.root.size
        let unused = diskSize - used
        let toFree = required - unused
        guard let folder = input.folders.filter({ $0.size >= toFree }).min(by: \.size) else {
            throw ExecutionError.unsolvable
        }
        return folder.size
    }
}

// MARK: - Custom String convertible

extension Hierarchy: CustomStringConvertible {
    var description: String {
        root.description
    }
}

extension Hierarchy.Folder: CustomStringConvertible {
    var description: String {
        var description = String(repeating: " ", count: level) + "- \(name) (dir)" + "\n"
        for folder in subfolders.values.sorted(by: \.name) {
            description += folder.description
        }
        for file in files.sorted(by: \.0) {
            description += String(repeating: " ", count: level + 1) + "- \(file.key) (file, size=\(file.value))" + "\n"
        }
        return description
    }
}
