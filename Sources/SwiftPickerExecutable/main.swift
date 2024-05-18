//
//  main.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import SwiftPicker

let title = "Select the items that you would like to use."
let sampleList = (1...2).map { "Item \($0)" }
let picker = SwiftPicker()

if picker.getPermission(prompt: "Wanna single select?") {
    let _ = picker.singleSelection(title: title, items: sampleList)
}

if picker.getPermission(prompt: "Wanna multi select?") {
    let _ = picker.multiSelection(title: title, items: sampleList)
}
