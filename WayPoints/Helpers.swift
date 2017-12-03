//
//  Helpers.swift
//  WayPoints
//
//  Created by apple on 11/12/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import Foundation
import MapKit
import Firebase

let imageCache = NSCache<NSString, UIImage>()

func getBackgroundColorForSeverity(severity: Severity? ) -> UIColor {
    guard severity != nil else {
        print("severity is null")
        return UIColor.white
    }
    switch severity! {
        case .none, .unknown:
            return UIColor.white
        case .severe:
            return UIColor.red
        case .moderate:
            return UIColor.yellow
        default:
            return UIColor.white
    }
}

func getTextForSeverity(severity: Severity?) -> String {
    guard severity != nil else {
        print("severity is null")
        return ""
    }
    switch severity! {
    case .none, .unknown:
        return "🚫"
    default:
        return ""
    }
}

func getImageName(precip: Precip? ) -> String? {
    guard precip != nil else {
        print("precip is null")
        return nil
    }
    if precip! != .none && precip! != .unknown {
        let fileName = "\(precip!)"
        return fileName
    }
    else {
        return nil
    }
    
}

extension String {
    
    func getAltitudeAsInteger() -> Int {
        var retVal = 0
        if let range = self.range(of: ".") {
            let firstPart = self[(self.startIndex)..<range.lowerBound]
            if let altitude = Int(firstPart) {
                retVal = altitude
            }
        }
        return retVal
    }
    
}

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    static let preciseGMTDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "MM/dd/YYYY HH:mm"
        return formatter
    }()
    static let USDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        return formatter
    }()
}
extension Date {
    
    func toFirebaseTimestamp() -> Int {
        return Int(self.timeIntervalSince1970) * 1000
    }
    
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var nanosecond: Int { return Calendar.current.component(.nanosecond,  from: self)   }
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
    var preciseGMTDateTime: String {
        return Formatter.preciseGMTDateTime.string(for: self) ?? ""
    }
    var currentDate: String {
        return Formatter.USDate.string(for: self) ?? ""
    }
}

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    

    func normalizedImage() -> UIImage {
        
        if (self.imageOrientation == UIImageOrientation.up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }

}

extension String {
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}








