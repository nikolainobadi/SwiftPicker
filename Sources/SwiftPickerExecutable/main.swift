//
//  main.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import SwiftPicker

let sampleList = (1...25).map { "Item \($0)" }
let picker = SwiftPicker(padding: .init(top: 1, bottom: 3))
let _ = picker.singleSelection(title: "My Title", items: sampleList)
