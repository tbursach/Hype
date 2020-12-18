//
//  HypeError.swift
//  Hype
//
//  Created by Trevor Bursach on 10/5/20.
//

import Foundation

enum HypeError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
    
    var errorDescription: String {
        switch self {
        
        case .ckError(let error):
            return "There was an error: \(error.localizedDescription)"
        case .couldNotUnwrap:
            return "Unable to unwrap this Hype, that's not very Hype..."
        }
    }
}
