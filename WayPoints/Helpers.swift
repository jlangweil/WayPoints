//
//  Helpers.swift
//  WayPoints
//
//  Created by apple on 11/12/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import Foundation

func getImageName(weather:String, severity: Severity? ) -> String? {
    guard severity != nil else {
        print("severity is null")
        return nil
    }
    if severity! != .none && severity! != .unknown {
        let fileName = "\(weather)-\(severity!)"
        return fileName
    }
    else {
        return nil
    }
  
}

func getImageName(weather:String, precip: Precip? ) -> String? {
    guard precip != nil else {
        print("precip is null")
        return nil
    }
    if precip! != .none && precip! != .unknown {
        let fileName = "\(weather)-\(precip!)"
        return fileName
    }
    else {
        return nil
    }
    
}
