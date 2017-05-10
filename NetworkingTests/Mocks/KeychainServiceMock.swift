//
//  KeychainServiceMock.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/8/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import ReactiveSwift
import Result
import Networking
@testable import Networking

internal class KeychainServiceMock: KeychainServiceType {
    
    private var _dictionary: [String: String] = [:]
    
    func get(key: String) -> String? {
        return _dictionary[key]
    }
    
    func set(value: String, forKey key: String) {
        _dictionary[key] = value
    }
    
    func delete(key: String) {
        _dictionary.removeValue(forKey: key)
    }
    
}
