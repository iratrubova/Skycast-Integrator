//
//  CoreDataStack.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//
import CoreData
import Foundation
import Combine

@available(macOS 10.15, *)
@available(macOS 10.15, *)
final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    let container: NSPersistentContainer
    
    @Published var saveError: Error?
    
    private init() {
        container = NSPersistentContainer(name: "FlightEnrichment")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            if #available(macOS 10.15, *) {
                saveError = error
            } else {
                // Fallback on earlier versions
            }
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            block(context)
        }
    }
}
