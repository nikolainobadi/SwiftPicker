//
//  MockPermissionResult.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

public struct MockPermissionResult {
    public let grantByDefault: Bool
    public var type: MockPermissionType

    public init(grantByDefault: Bool = true, type: MockPermissionType = .ordered([])) {
        self.grantByDefault = grantByDefault
        self.type = type
    }
}


// MARK: - Dependencies
public enum MockPermissionType {
    case ordered([Bool])
    case dictionary([String: Bool])
}
