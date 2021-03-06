//
//  ValidationState.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/1/22.
//

import Foundation
import SwiftUI

class ValidationState: ObservableObject {
    public enum ValidationError: Error {
        case clashingCondition(message: String)
        
        func message() -> String {
            switch self {
            case .clashingCondition(message: let message):
                return message
            }
        }
    }
    
    private(set) var validationState: Bool = true {
        didSet {
            print("validation state changed to \(validationState)")
        }
    }
    
    private(set)var validationMessage: String = ""
    
    func set(validationState: Bool? = nil, validationMessage: String? = nil) {
        if let validationState = validationState {
            self.validationState = validationState
        }
        
        if let validationMessage = validationMessage {
            self.validationMessage = validationMessage
        }
    }
}
