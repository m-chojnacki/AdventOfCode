// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AdventOfCode",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0")
    ],
    targets: [
        .target(name: "Shared"),
        /*
         * Year 2023
         */
        .day(1, year: 2023),
        .day(2, year: 2023),
        .day(3, year: 2023),
        .day(4, year: 2023),
        .day(5, year: 2023),
        .day(6, year: 2023),
        .day(7, year: 2023),
        .day(8, year: 2023),
        .day(9, year: 2023),
        .day(10, year: 2023),
        .day(11, year: 2023, dependencies: [.algorithms]),
        .day(12, year: 2023, dependencies: [.algorithms]),
        .day(13, year: 2023),
        .day(14, year: 2023),
        .day(15, year: 2023),
        .day(16, year: 2023),
        .day(17, year: 2023),
        .day(18, year: 2023),
        .day(19, year: 2023),
        .day(20, year: 2023),
        .day(21, year: 2023),
        .day(22, year: 2023),
        .day(23, year: 2023),
        /*
         * Year 2024
         */
        .day(1, year: 2024),
        .day(2, year: 2024),
        .day(3, year: 2024),
        .day(4, year: 2024),
        .day(5, year: 2024),
        .day(6, year: 2024),
        .day(7, year: 2024),
        .day(8, year: 2024),
        .day(9, year: 2024),
        .day(10, year: 2024),
        .day(11, year: 2024),
        .day(12, year: 2024)
    ]
)

extension Target {
    static func day(_ day: Int, year: Int, dependencies: [Dependency] = []) -> Target {
        .executableTarget(
            name: "Year\(year)Day\(day)",
            dependencies: ["Shared"] + dependencies,
            path: "Sources/Year\(year)/Day\(day)",
            resources: [.embedInCode("Resources")]
        )
    }
}

extension Target.Dependency {
    static var algorithms: Target.Dependency {
        .product(name: "Algorithms", package: "swift-algorithms")
    }
}
