//
//  EnumEntityState.swift
//  Networking
//
//  Created by Nahuel Gladstein on 6/7/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Argo

internal enum EnumStringEntityState: String, Decodable {
    case aState = "a_state"
    case anotherState = "another_state"
    case aThirdState = "a_third_state"
}

internal enum EnumUIntEntityState: UInt, Decodable {
    case one = 1
    case three = 3
    case eleven = 11
}

internal enum EnumDoubleEntityState: Double, Decodable {
    case onePointFive = 1.5
    case threePointFive = 3.5
    case elevenPointFive = 11.5
}

internal enum EnumFloatEntityState: Float, Decodable {
    case oneAndAQuarter = 1.25
    case threeAndAQuarter = 3.25
    case elevenAndAQuarter = 11.25
}
