//
//  SprintDataController.swift
//  Sprint
//
//  Created by Mohammed Ibrahim on 2020-03-07.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import Foundation
import Firebase

class SprintDataController {
    static let shared = SprintDataController()
    
    // Database Reference
    private let db = Firestore.firestore()
    
    // MARK: - Fetch Single Workspace by ID
    // Used when a user is trying to join a pre-existing workspace
    func isWorkspaceOpen(withID id: String, completion: @escaping (_ doesExist: Bool) -> ()) {
        db.collection("workspaces").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(false)
            } else {
                if let workspaces = querySnapshot?.documents {
                    var isOpen = false
                    
                    for workspace in workspaces {
                        isOpen = (workspace.documentID == id && workspace.data()["isActive"] as! Bool == true)
                    }
                    
                    completion(isOpen)
                    
                } else {
                    completion(false)
                }
            }
        }
    }
}
