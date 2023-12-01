//
//  StringExtension.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 01/12/2023.
//

extension String {
    func lines() -> [String] {
        trimmingCharacters(in: .newlines).components(separatedBy: .newlines)
    }
}
