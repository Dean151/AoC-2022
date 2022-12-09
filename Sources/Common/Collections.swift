//
// Collections.swift
//

extension Collection {
    public func extremum(by keyPath: KeyPath<Element, some Comparable>) -> (min: Element, max: Element)? {
        guard let min = min(by: keyPath), let max = max(by: keyPath) else {
            return nil
        }
        return (min, max)
    }
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

extension Collection where Element: Comparable {
    public func extremum() -> (min: Element, max: Element)? {
        guard let min = self.min(), let max = self.max() else {
            return nil
        }
        return (min, max)
    }
}
