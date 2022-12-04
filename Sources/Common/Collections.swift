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
    public func sorted(by keyPath: KeyPath<Element, some Comparable>) -> [Element] {
        self.sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}
