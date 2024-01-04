//
//  WorkoutEditorApp.swift
//  WorkoutEditor
//
//  Created by Vladyslav on 22.12.2023.
//

import SwiftUI

@main
struct WorkoutEditorApp: App {
    var body: some Scene {
        WindowGroup {
            WorkoutListView()
                .onAppear() {
                    HealthKitManager.shared.requestAuthorization { success, error in
                        if success {
                            // Proceed with HealthKit-related functionality
                            print("Authorization requested successfully")
                            HealthKitManager.shared.loadWorkouts()
                        } else {
                            // Handle authorization error
                            print("Error requesting HealthKit authorization: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
        }
    }
}
