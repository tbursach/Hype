//
//  HypeController.swift
//  Hype
//
//  Created by Trevor Bursach on 10/5/20.
//

import UIKit
import CloudKit

class HypeController {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - Singleton
    
    static let shared = HypeController()
    
    //MARK: - Source of Truth
    
    var hypes: [Hype] = []
    
    //MARK: - CRUD
    
    func saveHype(with text: String, hypePhoto: UIImage?, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        
        guard let currentUser = UserController.shared.currentUser else { return completion(.failure(.couldNotUnwrap)) }
        
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .none)
        
        let newHype = Hype(body: text, userReference: reference, hypePhoto: hypePhoto)
        let hypeRecord = CKRecord(hype: newHype)
        publicDB.save(hypeRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                  let savedHype = Hype(ckRecord: record) else { return completion(.failure(.couldNotUnwrap)) }

            print("Saved Hype successfully")
            completion(.success(savedHype))
        }
    }
    
    // Read Func
    func fetchAllHypes(completion: @escaping (Result<[Hype]?, HypeError>) -> Void) {
        
        let fetchAllPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: fetchAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
            
            print("Fetched Hypes successfully")
            let fetchedHypes = records.compactMap({Hype(ckRecord: $0) })
            completion(.success(fetchedHypes))
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (Result<Hype, HypeError>) -> Void) {
        
        // Step 2a - Create the record to save
        let recordToUpdate = CKRecord(hype: hype)
        // Step 2 - Create the operation to add
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate], recordIDsToDelete: nil)
        // Step 3 - Adjust the properties on our operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            // Handle the error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            // Unwrap the record that was updated and complete with a hype
            guard let record = records?.first,
                  let updatedHype = Hype(ckRecord: record) else { return completion(.failure(.couldNotUnwrap)) }
            print("Update \(record.recordID.recordName) successfully in Cloudkit")
            completion(.success(updatedHype))
        }
        
        // Step 1 - Add the operation to the database
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        
        // Step 2 - Create the operation to add
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        // Step 3 - Adjust the properties on our operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, recordIDs, error) in
            // Handle the error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            // Guarding against the returned recordIDs of the deleted records
            guard let recordIDs = recordIDs else { return completion(.failure(.couldNotUnwrap)) }
            print("\(recordIDs) were removed successfully")
            completion(.success(true))
        }
        // Step 1 - Add the operation to the database
        publicDB.add(operation)
    }
    
    //MARK: - Notifications
    func subscribeToRemoteNotifications(completion: @escaping (Error?) -> Void) {
        
        let allInstancesPredicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: allInstancesPredicate, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "CHOO CHOO"
        notificationInfo.alertBody = "Can't stop the Hype Train!!!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                completion(error)
            }
            completion(nil)
        }
    }
    
} // END OF CLASS
