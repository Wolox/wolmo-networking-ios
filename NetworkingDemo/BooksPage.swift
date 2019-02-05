//
//  BooksPage.swift
//  NetworkingDemo
//
//  Created by Nahuel Gladstein on 04/02/2019.
//  Copyright © 2019 Wolox. All rights reserved.
//

import Argo
import Curry
import Runes

public struct BooksPage {
    let data: [Book]
    let currentPage: Int
}

extension BooksPage: Argo.Decodable {
    
    public static func decode(_ json: JSON) -> Decoded<BooksPage> {
        return curry(BooksPage.init)
            <^> json <|| "data"
            <*> json <| ["page", "position", "current"]
    }
    
}
