//
//  PickerPrompt.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

public protocol PickerPrompt {
    var title: String { get }
}

extension String: PickerPrompt {
    public var title: String {
        return self
    }
}
