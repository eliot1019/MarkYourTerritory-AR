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
        let attributes = [NSFontAttributeName: font]
        let rect = NSString(string: text).boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: attributes, context: nil)
        print("Height needed for \(text) is \(rect.height)")
        return rect.height
        
    }
}
