//
//  Error.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 01/12/2023.
//

import Foundation

public struct Error: LocalizedError {
    public let errorDescription: String?

    public init(_ errorDescription: String?) {
        self.errorDescription = errorDescription
    }
}
