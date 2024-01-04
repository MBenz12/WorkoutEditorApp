//
//  WorkoutListView.swift
//  WorkoutEditor
//
//  Created by Vladyslav on 23.12.2023.
//

import SwiftUI
import HealthKit

struct WorkoutListView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared
    var body: some View {
        NavigationView {
            List(healthKitManager.loadedWorkouts ?? [], id: \.uuid) { workout in
                NavigationLink(destination: WorkoutEditView(workout: workout)) {
                    // Display date in "DD-MM-YYYY" format along with activity type
                    Text("\(formattedDate(workout.startDate)) - \(workout.workoutActivityType.activityTypeDescription)")
                }
            }
            .onAppear() {
                healthKitManager.loadWorkouts()
            }
            .navigationTitle("Workouts")
            .navigationBarItems(trailing: NavigationLink(destination: WorkoutAddView()) {
                Image(systemName: "plus")
            })
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
    }
}
