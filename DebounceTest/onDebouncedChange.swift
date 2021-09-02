//
//  onDebouncedChange.swift
//  DebounceTest
//
//  Created by Phil on 02.09.2021.
//

import Combine
import SwiftUI

extension View {
    func onDebouncedChange<V, S: Scheduler>(
        of binding: Binding<V>,
        debounceFor dueTime: S.SchedulerTimeType.Stride,
        scheduler: S,
        options: S.SchedulerOptions? = nil,
        perform action: @escaping (V) -> Void
    ) -> some View where V: Equatable {
        modifier(ListenDebounce(binding: binding,
            for: dueTime,
            scheduler: scheduler,
            options: options,
            perform: action))
    }
}

private struct ListenDebounce<Value: Equatable>: ViewModifier {
    let binding: Binding<Value>
    let relay = PassthroughSubject<Value, Never>()
    let debouncedPublisher: AnyPublisher<Value, Never>
    let action: (Value) -> Void

    init<S: Scheduler>(
        binding: Binding<Value>,
        for dueTime: S.SchedulerTimeType.Stride,
        scheduler: S,
        options: S.SchedulerOptions? = nil,
        perform action: @escaping (Value) -> Void
    ) {
        self.binding = binding
        self.action = action
        debouncedPublisher = relay
            .removeDuplicates()
            .debounce(for: dueTime, scheduler: scheduler, options: options)
            .eraseToAnyPublisher()
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: binding.wrappedValue) { value in
                relay.send(value)
            }
            .onReceive(debouncedPublisher, perform: { value in
                action(value)
            })
    }
}
