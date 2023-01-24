//
//  JournalManagerNSError.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 1/23/23.
//

import Foundation

extension JournalManagerNSError: CustomNSError {
    
    static var errorDomain: String { "JournalManagerError" }
    
    var errorCode: Int {
        switch self {
        case .noResultsRetrived:
            return 1
        case .multipleResultsRetrived:
            return 2
        case .asyncFetchFailed:
            return 3
        }
    }
    
    var userInfo: [String : Any] {
        switch self {
        case .noResultsRetrived:
            return ["Problem" : "No results were retrived"]
        case .multipleResultsRetrived:
            return ["Problem" : "Multiple results were retrived where single result was expected"]
        case .asyncFetchFailed:
            return ["Problem" : "Asynchronous fetch request failed"]
        }
    }
}
