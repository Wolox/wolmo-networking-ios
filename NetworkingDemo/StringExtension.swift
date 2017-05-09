//
//  StringExtension.swift
//  Networking
//
//  Created by Pablo Giorgi on 5/10/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation

internal extension String {
    
    static func / (url: String, path: String) -> String {
        return (url as NSString).appendingPathComponent(path)
    }
    
}
