//
//  Error.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 01/12/2023.
//

import Foundation

struct Error: LocalizedError {
    let errorDescription: String?

    init(_ errorDescription: String?) {
        self.errorDescription = errorDescription
    }
}
