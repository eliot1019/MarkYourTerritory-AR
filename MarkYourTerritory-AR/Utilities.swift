//
//  Utilities.swift
//  MarkYourTerritory-AR
//
//  Created by Eliot Han on 10/7/17.
//  Copyright © 2017 Eliot Han. All rights reserved.
//


import Foundation

struct Utilities {
    
    /// Returns the height needed to display x text for a width and a font
    static func getHeight(toDisplay text: String, width: CGFloat, font: UIFont) -> CGFloat{
        let attributes = [NSAttributedStringKey.font: font]
        let rect = NSString(string: text).boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: attributes, context: nil)
        print("Height needed for \(text) is \(rect.height)")
        return rect.height
        
    }
    
    //Returns an ISO date string of today's date
    static func getDateString(isoFormat:Bool?=nil) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        if let isIso = isoFormat {
            if isIso {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            }
        }
        let dateString = dateFormatter.string(from: date as Date)
        return dateString
    }
    
}


protocol Serializable {
    var properties:Array<String> { get }
    func valueForKey(key: String) -> Any?
    func toDictionary() -> [String:Any]
}

extension Serializable {
    func toDictionary() -> [String:Any] {
        var dict:[String:Any] = [:]
        
        for prop in self.properties {
            if let val = self.valueForKey(key: prop) as? String {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Int {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Double {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Array<String> {
                dict[prop] = val
            } else if let val = self.valueForKey(key: prop) as? Serializable {
                dict[prop] = val.toDictionary()
            } else if let val = self.valueForKey(key: prop) as? Array<Serializable> {
                var arr = Array<[String:Any]>()
                
                for item in (val as Array<Serializable>) {
                    arr.append(item.toDictionary())
                }
                
                dict[prop] = arr
            }
        }
        
        return dict
    }
}
