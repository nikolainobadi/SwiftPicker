//
//  MockSwiftPicker.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 2025-10-24.
//

import SwiftPicker

public class MockSwiftPicker {
    private let grantPermissionByDefault: Bool
    private var mockPermissionType: MockPermissionType
    
    init(grantPermissionByDefault: Bool = true, mockPermissionType: MockPermissionType = .ordered([])) {
        self.grantPermissionByDefault = grantPermissionByDefault
        self.mockPermissionType = mockPermissionType
    }
}

extension MockSwiftPicker: CommandLinePermission {
    public func getPermission(prompt: PickerPrompt) -> Bool {
        switch mockPermissionType {
        case .ordered(var responses):
            if responses.isEmpty {
                return grantPermissionByDefault
            }
            
            let response = responses.removeFirst()
            
            mockPermissionType = .ordered(responses)
            
            return response
        case .dictionary(let dict):
            return dict[prompt.title] ?? grantPermissionByDefault
        }
    }

    public func requiredPermission(prompt: PickerPrompt) throws {
        guard getPermission(prompt: prompt) else {
            throw SwiftPickerError.selectionCancelled
        }
    }
}

public enum MockPermissionType {
    case ordered([Bool])
    case dictionary([String: Bool])
}
