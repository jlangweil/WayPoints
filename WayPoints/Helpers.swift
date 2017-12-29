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
import FirebaseAuthUI

//let imageCache = NSCache<NSString, UIImage>()
let defaults = UserDefaults.standard
let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
var signedInUser : String {
    get {
        if let user = Auth.auth().currentUser {
            return user.uid
        }
        else {
            return ""
        }
    }
}



// Utils

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
        return severity?.rawValue ?? ""
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

func getWaypointPinName(conditions: [String?], urgent: Bool) -> String {
    if (urgent) {
        return "planered"
    }
    else {
        let severeConditions = conditions.filter{ ($0?.contains(find: Severity.severe.rawValue) ?? false) || ($0?.contains(find: Precip.mixed.rawValue) ?? false) || $0?.contains(find: Precip.snow.rawValue) ?? false}
        let moderateConditions = conditions.filter{ ($0?.contains(find: Severity.light.rawValue) ?? false) || ($0?.contains(find: Severity.moderate.rawValue) ?? false) || $0?.contains(find: Precip.rain.rawValue) ?? false}
        if severeConditions.count > 0 {
            return "planered"
        }
        else if moderateConditions.count > 0 {
            return "planeyellow"
        }
        else {
            return "wayPointPinDefaultSmall"
        }
        
    }
}

// Extension methods

extension String {
    
    func getAltitudeAsInteger() -> Int {
        if let intValue = Int(self) {
            return intValue
        }
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
    
    func getThumbnailSize() -> CGSize {
        let originalWidth = Int(self.size.width)
        let originalHeight = Int(self.size.height)
        var newWidth: Int
        var newHeight: Int
        let maxResolution = 960
        if originalWidth > originalHeight {
            newWidth = maxResolution
            newHeight = Int((maxResolution * originalHeight) / originalWidth)
        }
        else {
            newHeight = maxResolution
            newWidth = Int ((maxResolution * originalWidth) / originalHeight)
        }
        return CGSize(width: newWidth, height: newHeight)
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

func reUploadImageToDatabase(data:Data, fileName: String) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imagesRef = storageRef.child("images/\(fileName)")
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    let uploadTask = imagesRef.putData(data, metadata: metadata)
    uploadTask.observe(.success) { snapshot in
        print ("SUCESSS UPLOAD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        // delete from disk
        deleteImage(imageName: fileName)
    }
    
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func saveImageToDisc(data: Data, imageName: String) {
    let filename = getDocumentsDirectory().appendingPathComponent(imageName)
    do {
        var imageFolderExists = false
        imageFolderExists = directoryExistsAtPath("images")
        if imageFolderExists == false {
            let imagesPath = getDocumentsDirectory().appendingPathComponent("images")
            try FileManager.default.createDirectory(atPath: imagesPath.path, withIntermediateDirectories: true, attributes: nil)
            imageFolderExists = directoryExistsAtPath("images")
        }
        try data.write(to: filename)
    }
    catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
}

func directoryExistsAtPath(_ path: String) -> Bool {
    var isDirectory = ObjCBool(true)
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
}

func deleteImage(imageName: String) {
    do {
        let imagesPath = getDocumentsDirectory().appendingPathComponent("images")
        let url = imagesPath.appendingPathComponent(imageName)
        try FileManager.default.removeItem(at: url)
    } catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
}

func retryImageUploads() {
    do {
        let filemanager = FileManager()
        let imagesPath = getDocumentsDirectory().appendingPathComponent("images")
        let files = filemanager.enumerator(atPath: imagesPath.path)
        while let file = files?.nextObject() {
            print(file)
            let fileNamePath = imagesPath.appendingPathComponent("\(file)")
            let data = try Data.init(contentsOf: fileNamePath)
            reUploadImageToDatabase(data: data, fileName: "\(file)")
        }
    }
    catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
}








