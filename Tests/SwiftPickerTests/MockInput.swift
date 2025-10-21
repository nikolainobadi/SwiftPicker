//
//  MockInput.swift
//  
//
//  Created by Nikolai Nobadi on 5/17/24.
//

@testable import SwiftPicker

final class MockInput: PickerInput {
    var pressKey = false
    var screenSize: (Int, Int)
    var directionKey: Direction?
    
    private(set) var writtenText: [String] = []
    private(set) var didEnableNormalInput = false
    private(set) var didExitAlternateScreen = false
    private(set) var specialKeyQueue: [SpecialChar?] = []
    
    init(screenSize: (Int, Int), directionKey: Direction?) {
        self.screenSize = screenSize
        self.directionKey = directionKey
    }
    
    func enqueueSpecialChar(specialChar: SpecialChar?) {
        specialKeyQueue.append(specialChar)
    }
}

extension MockInput {
    func cursorOff() { }
    func moveRight() { }
    func moveToHome() { }
    func clearBuffer() { }
    func clearScreen() { }
    
    func enableNormalInput() {
        didEnableNormalInput = true
    }
    
    func keyPressed() -> Bool {
        return pressKey
    }
    
    func write(_ text: String) {
        writtenText.append(text)
    }
    
    func exitAlternativeScreen() {
        didExitAlternateScreen = true
    }
    
    func enterAlternativeScreen() { }
    func moveTo(_ row: Int, _ col: Int) { }
    
    func readDirectionKey() -> Direction? {
        return directionKey
    }
    
    func readSpecialChar() -> SpecialChar? {
        guard !specialKeyQueue.isEmpty else { return nil }
        let specialChar = specialKeyQueue.removeFirst()
        
        return specialChar
    }
    
    func readCursorPos() -> (row: Int, col: Int) {
        return (0, 0)
    }
    
    func readScreenSize() -> (rows: Int, cols: Int) {
        return screenSize
    }
}
