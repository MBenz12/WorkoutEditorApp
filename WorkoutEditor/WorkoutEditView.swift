//
//  WorkoutEditView.swift
//  WorkoutEditor
//
//  Created by Vladyslav on 23.12.2023.
//

import SwiftUI
import HealthKit

struct WorkoutEditView: View {
    var workout: HKWorkout
    
    @State private var editedStartTime: Date
    @State private var editedEndTime: Date
    @State private var editedActivityType: HKWorkoutActivityType
    
    init(workout: HKWorkout) {
        self.workout = workout
        _editedStartTime = State(initialValue: workout.startDate)
        _editedEndTime = State(initialValue: workout.endDate)
        _editedActivityType = State(initialValue: workout.workoutActivityType)
    }
    
    var activityTypes: [HKWorkoutActivityType] = [
        .running,
        .cycling,
        .swimming,
        // Add more activity types as needed
    ]
    
    @State private var isSaveSuccessful: Bool = false
    @State private var presentingRemoveAlert = false
    @State private var presentingUpdateAlert = false
    
    var body: some View {
        NavigationView {
            Form() {
                Section(header: Text("Workout Details")) {
                    DatePicker("Start Time", selection: $editedStartTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
                    DatePicker("End Time", selection: $editedEndTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    
                    Picker("Activity Type", selection: $editedActivityType) {
                        ForEach(activityTypes, id: \.self) { activityType in
                            Text(activityType.activityTypeDescription).tag(activityType)
                        }
                    }
                }
                
                Section {
                    Button(action: saveChanges) {
                        Text("Save Workout")
                    }
                    .alert(isPresented: $presentingUpdateAlert) {
                        Alert(
                            title: Text("Save Changes"),
                            message: Text("Are you sure you want to save these changes to the workout?"),
                            primaryButton: .default(
                                Text("Save"),
                                action: {
                                    // Perform the update here
                                    confirmSaveChanges()
                                }
                            ),
                            secondaryButton: .cancel()
                        )
                    }
                    .background(
                        EmptyView()
                            .fullScreenCover(isPresented: $isSaveSuccessful, content: {
                                WorkoutListView()
                            })
                    )
                    Button(action: removeWorkout) {
                        Text("Remove Workout")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented:
                            $presentingRemoveAlert) {
                        Alert(
                            title: Text("Remove Workout"),
                            message: Text("Are you sure you want to remove this workout? This action cannot be undone."),
                            primaryButton: .destructive(
                                Text("Remove"),
                                action: {
                                    // Perform the deletion here
                                    confirmRemoveWorkout()
                                }
                            ),
                            secondaryButton: .cancel()
                        )
                    }
                            .background(
                                EmptyView()
                                    .fullScreenCover(isPresented: $isSaveSuccessful, content: {
                                        WorkoutListView()
                                    })
                            )
                }
            }
            .navigationTitle("Workout \(formattedDate(workout.startDate))")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    private func removeWorkout() {
        presentingRemoveAlert.toggle()
    }
    
    private func confirmRemoveWorkout() {
        HealthKitManager.shared.fetchWorkout(withUUID: workout.uuid) { originalWorkout, error in
            guard let originalWorkout = originalWorkout else {
                return
            }
            
            // Now, delete the original workout
            HealthKitManager.shared.deleteWorkout(originalWorkout) { deleteSuccess, deleteError in
                if deleteSuccess {
                    // Original workout deleted successfully
                    print("Original workout deleted successfully")
                    isSaveSuccessful = true
                } else {
                    // Handle deletion error
                    print("Error deleting original workout: \(deleteError?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func saveChanges() {
        presentingUpdateAlert.toggle()
    }
    
    private func confirmSaveChanges() {
        guard editedEndTime > editedStartTime else {
            // Show an alert or some feedback to the user that the end time must be after the start time.
            return
        }

        // Fetch the original workout to update
        HealthKitManager.shared.fetchWorkout(withUUID: workout.uuid) { originalWorkout, error in
            guard let originalWorkout = originalWorkout else {
                // Handle error or show an alert that the original workout couldn't be fetched
     	               return
            }

            // Update the original workout with the edited values
            let updatedWorkout = HKWorkout(
                activityType: editedActivityType,
                start: editedStartTime,
                end: editedEndTime,
                workoutEvents: originalWorkout.workoutEvents,
                totalEnergyBurned: originalWorkout.totalEnergyBurned,
                totalDistance: originalWorkout.totalDistance,
                metadata: originalWorkout.metadata
            )

            // Save the updated workout
            HealthKitManager.shared.save(updatedWorkout) { success, error in
                if success {
                    // Changes saved successfully
                    print("Changes saved successfully")
                    // Now, delete the original workout
                    HealthKitManager.shared.deleteWorkout(originalWorkout) { deleteSuccess, deleteError in
                       if deleteSuccess {
                           // Original workout deleted successfully
                           print("Original workout deleted successfully")
                       } else {
                           // Handle deletion error
                           print("Error deleting original workout: \(deleteError?.localizedDescription ?? "Unknown error")")
                       }
                    }
                    isSaveSuccessful = true
                } else {
                    // Handle error
                    print("Error saving changes: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

struct WorkoutEditView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutEditView(workout: HKWorkout(activityType: .running, start: Date(), end: Date()))
    }
}
