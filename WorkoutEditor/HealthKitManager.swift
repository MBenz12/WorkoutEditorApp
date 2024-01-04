//
//  HealthKitManager.swift
//  WorkoutEditor
//
//  Created by Vladyslav on 23.12.2023.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    @Published var loadedWorkouts: [HKWorkout]?
    private let healthStore = HKHealthStore()
    
    // Request authorization for specific health data types
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]

        let typesToWrite: Set<HKSampleType> = [HKObjectType.workoutType()]

        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            completion(success, error)
        }
    }

    func save(_ workout: HKWorkout, completion: @escaping (Bool, Error?) -> Void) {
        self.healthStore.save(workout) { success, error in
            completion(success, error)
        }
    }
    
    func loadWorkouts() {
        let workoutType = HKObjectType.workoutType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: 100, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let workouts = samples as? [HKWorkout] else {
                return
            }
            
            // Store the loaded workouts and trigger an update
            DispatchQueue.main.async {
                self.loadedWorkouts = workouts
            }
        }

        self.healthStore.execute(query)
    }
    
    func fetchWorkout(withUUID uuid: UUID, completion: @escaping (HKWorkout?, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil, HealthKitError.healthDataNotAvailable)
            return
        }

        let workoutType = HKObjectType.workoutType()
        let predicate = HKQuery.predicateForObject(with: uuid)

        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { (query, samples, error) in
            guard let workouts = samples as? [HKWorkout], let workout = workouts.first else {
                completion(nil, error)
                return
            }
            completion(workout, nil)
        }

        healthStore.execute(query)
    }
    
    func deleteWorkout(_ workout: HKWorkout, completion: @escaping (Bool, Error?) -> Void) {
        healthStore.delete(workout) { success, error in
            completion(success, error)
        }
    }
}

enum HealthKitError: Error {
    case healthDataNotAvailable
    // Add more error cases as needed
}
