//
//  MockInputResult.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

public struct MockInputResult {
    public let defaultValue: String
    public var type: MockInputType

    public init(defaultValue: String = "", type: MockInputType = .ordered([])) {
        self.defaultValue = defaultValue
        self.type = type
    }
}


// MARK: - Dependencies
public enum MockInputType {
    case ordered([String])
    case dictionary([String: String])
}
