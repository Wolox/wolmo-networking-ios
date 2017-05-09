//
//  KeychainService.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/5/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import KeychainSwift

/**
    Protocol for keychain service.
    Provides a way to save, delete and query a String.
 */
internal protocol KeychainServiceType {
    
    /**
        Returns the associated value given a key
     
        - Parameters:
            - key: key to get the associate value in case there is any
        - Returns:
            A String with the associated value
     */
    func get(key: String) -> String?
    
    /**
        Stores the value in under the given key
     
        - Parameters:
            - value: value associated to key
            - key: key to associate the value
     */
    func set(value: String, forKey key: String)
    
    /**
        Deletes the entry for the key
     
        - Parameters:
            - key: key to delete
     */
    func delete(key: String)
    
}

/**
    Default KeychainService responsible for handling the keychain in the SessionManager.
 */
final internal class KeychainService {
    
    fileprivate let _keychain: KeychainSwift
    
    init(keychain: KeychainSwift = KeychainSwift()) {
        _keychain = keychain
    }
    
}

extension KeychainService: KeychainServiceType {

    func get(key: String) -> String? {
        return _keychain.get(key)
    }
    
    func set(value: String, forKey key: String) {
        _keychain.set(value, forKey: key)
    }
    
    func delete(key: String) {
        _keychain.delete(key)
    }
    
}
