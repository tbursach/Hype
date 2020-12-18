//
//  User.swift
//  Hype
//
//  Created by Trevor Bursach on 10/7/20.
//

import UIKit
import CloudKit

struct UserStrings {
     static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
     static let appleUserReferenceKey = "appleUserReference"
    fileprivate static let photoAssetKey = "photoAsset"
}

class User {
    
    var username: String
    var bio: String
    var recordID: CKRecord.ID
    var appleUserReference: CKRecord.Reference
    var photoData: Data?
    
    var profilePhoto: UIImage? {
        get {
            guard let data = photoData else { return nil }
            return UIImage(data: data)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("==========Error==========")
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                print("==========Error==========")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(username: String, bio: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference, profilePhoto: UIImage? = nil) {
        
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserReference = appleUserReference
        self.profilePhoto = profilePhoto
    }
}

extension User {
    convenience init?(ckRecord: CKRecord) {
        
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
              let bio = ckRecord[UserStrings.bioKey] as? String,
              let appleUserReference = ckRecord[UserStrings.appleUserReferenceKey] as? CKRecord.Reference else { return nil }
        
        var foundPhoto: UIImage?
        
        if let photoAsset = ckRecord[UserStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("==========Error==========")
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                print("==========Error==========")
            }
        }
        
        self.init(username: username, bio: bio, recordID: ckRecord.recordID, appleUserReference: appleUserReference, profilePhoto: foundPhoto)
    }
}

extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordTypeKey, recordID: user.recordID)
        setValuesForKeys([
            UserStrings.usernameKey : user.username,
            UserStrings.bioKey : user.bio,
            UserStrings.appleUserReferenceKey : user.appleUserReference
        ])
        if let asset = user.photoAsset {
            setValue(asset, forKey: UserStrings.photoAssetKey)
        }
    }
}
