//
//  main.swift
//
//
//  Created by Nikolai Nobadi on 5/16/24.
//

import SwiftPicker

let picker = SwiftPicker()

if picker.getPermission(prompt: "Wanna pick a favorite programming language?") {
    let title = "Choose Your Favorite Programming Language"
    let sampleList = ["Swift", "Python", "JavaScript", "C#", "Java", "Go", "Ruby", "Kotlin"]
    
    let _ = picker.singleSelection(title: title, items: sampleList)
}

if picker.getPermission(prompt: "Wanna pick your favorite marvel movies?") {
    let multiTitle = "Select Your Favorite Marvel Movies"
    let multiList = [
        "Iron Man", "The Incredible Hulk", "Iron Man 2", "Thor",
        "Captain America: The First Avenger", "The Avengers", "Iron Man 3", "Thor: The Dark World",
        "Captain America: The Winter Soldier", "Guardians of the Galaxy", "Avengers: Age of Ultron", "Ant-Man",
        "Captain America: Civil War", "Doctor Strange", "Guardians of the Galaxy Vol. 2", "Spider-Man: Homecoming",
        "Thor: Ragnarok", "Black Panther", "Avengers: Infinity War", "Ant-Man and The Wasp"
    ]
    
    let _ = picker.multiSelection(title: multiTitle, items: multiList)
}
