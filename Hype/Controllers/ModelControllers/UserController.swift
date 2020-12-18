//
//  UserController.swift
//  Hype
//
//  Created by Trevor Bursach on 10/7/20.
//

import UIKit
import CloudKit

class UserController {
    
    // Shared Instance
    static let shared = UserController()
    
    // Source of Truth
    var currentUser: User?
    
    // Public Cloud Database
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // Create a User
    func createUser(username: String, bio: String, profilePhoto: UIImage?, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        
        fetchAppleUserReference { (result) in
            switch result {
            
            case .success(let reference):
                let user = User(username: username, bio: bio, appleUserReference: reference, profilePhoto: profilePhoto)
                let userRecord = CKRecord(user: user)
                
                self.publicDB.save(userRecord) { (record, error) in
                    if let error = error {
                        print("==========Error==========")
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        print("==========Error==========")
                        return completion(.failure(.ckError(error)))
                    }
                    
                    guard let record = record,
                          let savedUser = User(ckRecord: record) else {
                        completion(.failure(.couldNotUnwrap))
                        return
                    }
                    
                    self.currentUser = savedUser
                    completion(.success(true))
                }
            case .failure(let error):
                print("==========Error==========")
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                print("==========Error==========")
            }
        }
        
    }
    
    // Fetch a user
    func fetchUser(completion: @escaping (Result<Bool, HypeError>)-> Void) {
        
        // Step 4 - Fetch our Apple User Reference for our Predicate
        fetchAppleUserReference { (result) in
            switch result {
            
            case .success(let reference):
                // Step 3 - Create a Predicate for our Query
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserReferenceKey, reference])
                
                // Step 2 - Create a Query Item
                let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
                
                // Step 1 - Perform Query
                self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                    // Step 5 - Handle any possible errors
                    if let error = error {
                        print("==========Error==========")
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        print("==========Error==========")
                    }
                    
                    // Step 6 - Guard to make sure we have a record and that record can be turned into a User object
                    guard let record = records?.first,
                          let fetchedUser = User(ckRecord: record) else { completion(.failure(.couldNotUnwrap))
                        return
                    }
                    
                    // Step 7 - Set our source of truth with the fetched User and complete
                    self.currentUser = fetchedUser
                    print("Successfully fetched user with id: \(fetchedUser.recordID)")
                    completion(.success(true))
                    
                }
                // Unordered Step - Handle possible error fetching Apple User Reference (Step 4)
            case .failure(let error):
                print("==========Error==========")
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                print("==========Error==========")
                completion(.failure(.ckError(error)))
            }
        }
    }
    
    // Fetch Apple User Reference
    func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference, HypeError>) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("==========Error==========")
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                print("==========Error==========")
                completion(.failure(.ckError(error)))
            }
            
            guard let recordID = recordID else { return completion(.failure(.couldNotUnwrap)) }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(.success(reference))
        }
    }
    
} // END OF CLASS
