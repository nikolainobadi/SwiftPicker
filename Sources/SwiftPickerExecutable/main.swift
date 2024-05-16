//
//  main.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import SwiftPicker

let title = "My Title"
let sampleList = (1...25).map { "Item \($0)" }
let picker = SwiftPicker(padding: .init(top: 2, bottom: 4))
//let _ = picker.singleSelection(title: title, items: sampleList)
let _ = picker.multiSelection(title: title, items: sampleList)
