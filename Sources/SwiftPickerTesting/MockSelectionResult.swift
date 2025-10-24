//
//  MockSelectionResult.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

public struct MockSelectionResult {
    public let defaultIndex: Int?
    public var singleSelectionType: MockSelectionType
    public var multiSelectionType: MockMultiSelectionType

    public init(
        defaultIndex: Int? = 0,
        singleSelectionType: MockSelectionType = .ordered([]),
        multiSelectionType: MockMultiSelectionType = .ordered([])
    ) {
        self.defaultIndex = defaultIndex
        self.singleSelectionType = singleSelectionType
        self.multiSelectionType = multiSelectionType
    }
}


// MARK: - Dependencies
public enum MockSelectionType {
    case ordered([Int?])
    case dictionary([String: Int?])
}

public enum MockMultiSelectionType {
    case ordered([[Int]])
    case dictionary([String: [Int]])
}
