//
//  CommandLinePicker.swift
//  SwiftPicker
//
//  Created by Nikolai Nobadi on 3/26/25.
//

/// A unified protocol combining all command line interaction capabilities.
public typealias CommandLinePicker = CommandLineInput & CommandLinePermission & CommandLineSelection

/// Legacy protocol name for backward compatibility. Use `CommandLinePicker` instead.
@available(*, deprecated, renamed: "CommandLinePicker", message: "Use CommandLinePicker to avoid conflicts with SwiftUI.Picker")
public typealias Picker = CommandLinePicker
