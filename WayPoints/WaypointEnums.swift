//
//  WaypointEnums.swift
//  WayPoints
//
//  Created by apple on 11/11/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import Foundation

enum Precip:String{
    case none = "NONE"
    case rain = "RAIN"
    case snow = "SNOW"
    case mixed = "MIX"
    case unknown = ""
}

enum Severity:String {
    case none = "NONE"
    case light = "LGT"
    case moderate = "MOD"
    case severe = "SEV"
    case unknown = ""
}
