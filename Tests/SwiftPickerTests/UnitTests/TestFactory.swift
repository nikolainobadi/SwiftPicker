//
//  TestFactory.swift
//
//
//  Created by Nikolai Nobadi on 8/10/25.
//

@testable import SwiftPicker

func makePickerInfo(title: String = "Title", items: [String]? = nil) -> PickerInfo<String> {
    return .init(title: title, items: items ?? makeItems())
}

func makeItems(itemCount: Int = 25) -> [String] {
    return (1...itemCount).map({ "Item \($0)" })
}
