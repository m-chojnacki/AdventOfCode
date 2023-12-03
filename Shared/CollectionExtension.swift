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
