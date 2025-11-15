//
//  MockColumnSelectionResult.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

public struct MockColumnSelectionResult {
    public let defaultIndex: Int?
    public var singleColumnSelectionType: MockColumnSelectionType
    public var multiColumnSelectionType: MockMultiColumnSelectionType

    public init(
        defaultIndex: Int? = 0,
        singleColumnSelectionType: MockColumnSelectionType = .ordered([]),
        multiColumnSelectionType: MockMultiColumnSelectionType = .ordered([])
    ) {
        self.defaultIndex = defaultIndex
        self.singleColumnSelectionType = singleColumnSelectionType
        self.multiColumnSelectionType = multiColumnSelectionType
    }
}


// MARK: - Dependencies
public enum MockColumnSelectionType {
    case ordered([Int?])
    case dictionary([String: Int?])
}

public enum MockMultiColumnSelectionType {
    case ordered([[Int]])
    case dictionary([String: [Int]])
}
