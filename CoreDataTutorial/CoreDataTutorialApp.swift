//
//  CoreDataTutorialApp.swift
//  CoreDataTutorial
//
//  Created by Miroslav Perovic on 10.5.23..
//

import SwiftUI

@main
struct CoreDataTutorialApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
