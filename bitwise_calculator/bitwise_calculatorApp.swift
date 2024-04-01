//
//  bitwise_calculatorApp.swift
//  bitwise_calculator
//
//  Created by Sudharsan on 26/08/24.
//

import SwiftUI

@main
struct bitwise_calculatorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
