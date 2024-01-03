//
//  ContentView.swift
//  WorkoutEditor
//
//  Created by Vladyslav on 22.12.2023.
//

import SwiftUI
import HealthKit

struct WorkoutAddView: View {
    @State private var selectedActivityType: HKWorkoutActivityType = .running
    @State private var startTime = Date()
    @State private var endTime = Date()

    var activityTypes: [HKWorkoutActivityType] = [
        .running,
        .cycling,
        .swimming,
        // Add more activity types as needed
    ]
    @State private var isSaveSuccessful: Bool = false
    var body: some View {
        NavigationView {
            Form() {
                Section(header: Text("New Workout Details")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
                    Picker("Activity Type", selection: $selectedActivityType) {
                        ForEach(activityTypes, id: \.self) { activityType in
                            Text(activityType.activityTypeDescription).tag(activityType)
                        }
                    }
                }
                
                Section {
                    Button(action: saveWorkout) {
                        Text("Save Workout")
                    }
                    .background(
                        EmptyView()
                            .fullScreenCover(isPresented: $isSaveSuccessful, content: {
                                WorkoutListView()
                            })
                    )
                }
            }
            .navigationTitle("Add New Workout")
        }
    }

    private func saveWorkout() {
        let timezoneIdentifier = TimeZone.current.identifier
        let metadata = [HKMetadataKeyTimeZone: timezoneIdentifier]
        let workout = HKWorkout(activityType: selectedActivityType, start: startTime, end: endTime, workoutEvents: nil, totalEnergyBurned: nil, totalDistance: nil, metadata: metadata)

        HealthKitManager.shared.save(workout) { success, error in
            if success {
                // Workout saved successfully
                print("Workout saved successfully")
                isSaveSuccessful = true
            } else {
                // Handle error
                print("Error saving workout: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

struct WorkoutAddView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutAddView()
    }
}

// Define an extension to get the name of the activity type
extension HKWorkoutActivityType {
    var activityTypeDescription: String {
        switch self {
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .swimming:
            return "Swimming"
        // Add more cases as needed
        default:
            return "Other"
        }
    }
}
