//
//  CollectionExtension.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 03/12/2023.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Collection where Iterator.Element: RandomAccessCollection {
    func transposed() -> [[Iterator.Element.Iterator.Element]] {
        guard let first else { return [] }

        return first.indices.map { index in
            map { $0[index] }
        }
    }
}

extension MutableCollection {
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
