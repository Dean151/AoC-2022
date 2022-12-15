//
// Collections.swift
//

extension Collection {
    public func filter(by keyPath: KeyPath<Element, Bool>) -> [Element] {
        self.filter { $0[keyPath: keyPath] }
    }
    public func map<T>(by keyPath: KeyPath<Element, T>) -> [T] {
        self.map { $0[keyPath: keyPath] }
    }
    public func max(by keyPath: KeyPath<Element, some Comparable>) -> Element? {
        self.max { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
    public func min(by keyPath: KeyPath<Element, some Comparable>) -> Element? {
        self.min { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
    public func sorted(by keyPath: KeyPath<Element, some Comparable>) -> [Element] {
        self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}

extension Collection where Element == ClosedRange<Int> {
    public func consolidate() -> [Element] {
        let sorted = sorted(by: \.lowerBound)
        guard let first = sorted.first else {
            return []
        }
        if count == 1 {
            return [first]
        }
        var new: [ClosedRange<Int>] = []
        var current = first
        for range in sorted[1...] {
            if current.clamped(to: range) == range {
                continue
            }
            if current.overlaps(range) {
                current = current.lowerBound...range.upperBound
            } else {
                new.append(current)
                current = range
            }
        }
        new.append(current)
        return new
    }
}
