//
//  CollectionExtension.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 03/12/2023.
//

public extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    func unzip<T, U>() -> ([T], [U]) where Element == (T, U) {
        reduce(into: ([T](), [U]())) { result, pair in
            result.0.append(pair.0)
            result.1.append(pair.1)
        }
    }
}

public extension Collection where Iterator.Element: RandomAccessCollection {
    func transposed() -> [[Iterator.Element.Iterator.Element]] {
        guard let first else { return [] }

        return first.indices.map { index in
            map { $0[index] }
        }
    }
}

public extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }

        set {
            if let newValue, indices.contains(index) {
                self[index] = newValue
            }
        }
    }
}
