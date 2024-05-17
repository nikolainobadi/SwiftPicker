//
//  main.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import SwiftPicker

let title = "Select the item that you would like to use."
let sampleList = (1...25).map { "Item \($0)" }
let picker = SwiftPicker()
//let _ = picker.singleSelection(title: title, items: sampleList)
let _ = picker.multiSelection(title: title, items: sampleList)
