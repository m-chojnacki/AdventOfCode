//
//  InputHelper.swift
//  AdventOfCode
//
//  Created by Marcin Chojnacki on 01/12/2023.
//

import Foundation

enum InputHelper {
    static func readInput(_ filePath: String = "input.txt") -> String {
        let url = URL(filePath: filePath)

        do {
            return try String(contentsOf: url)
        } catch {
            fatalError("File \(filePath) does not exist")
        }
    }
}
