//
//  ContentView.swift
//  DebounceTest
//
//  Created by Phil on 02.09.2021.
//

import SwiftUI

struct ContentView: View {
    @State
    private var text: String = "hello"

    var body: some View {
        TextEditor(text: $text)
            .padding(100)
            .onDebouncedChange(
                of: $text,
                debounceFor: 1,
                scheduler: RunLoop.main
            ) { value in
                print(value)
            }
    }
} 
