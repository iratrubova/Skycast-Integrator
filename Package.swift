// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "schoolLF8",
    platforms: [
        .macOS(.v12), 
        .iOS(.v15)
    ],

    products: [
      
        .library(
            name: "schoolLF8",
            targets: ["FlightEnrichment"]
        ),
    ],
    targets: [
    
        .target(
            name: "schoolLF8"
        ),
        .testTarget(
            name: "schoolLF8Tests",
            dependencies: ["schoolLF8"]
        )
    ]
)
