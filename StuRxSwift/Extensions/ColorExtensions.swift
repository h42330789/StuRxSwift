//
//  ColorExtensions.swift
//  StuRxSwift
//
//  Created by aaa on 1/6/23.
//

import UIKit

public extension UIColor {
    
    static var random: UIColor {
        return random()
    }
    
    static func random(randomizeAlpha: Bool = false) -> UIColor {
        let r = CGFloat.random(in: 0...255) / 255.0
        let g = CGFloat.random(in: 0...255) / 255.0
        let b = CGFloat.random(in: 0...255) / 255.0
        let a = randomizeAlpha ? 1 : CGFloat.random(in: 0...1)
            
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    convenience init?(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            
        var hexValue = UInt64()
            
        guard Scanner(string: hexString).scanHexInt64(&hexValue) else {
            return nil
        }
            
        let a, r, g, b: UInt64
        switch hexString.count {
        case 3: // 0xRGB
            (a, r, g, b) = (255, (hexValue >> 8) * 17, (hexValue >> 4 & 0xF) * 17, (hexValue & 0xF) * 17)
        case 6: // 0xRRGGBB
            (a, r, g, b) = (255, hexValue >> 16, hexValue >> 8 & 0xFF, hexValue & 0xFF)
        case 8: // 0xRRGGBBAA
            (r, g, b, a) = (hexValue >> 24, hexValue >> 16 & 0xFF, hexValue >> 8 & 0xFF, hexValue & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
        
    // The hexadecimal value of the color.
//    var hex: String {
//        let rgb = Int(self.red * 255) << 16 | Int(self.green * 255) << 8 | Int(self.blue * 255) << 0
//        return String(format: "#%06x", rgb)
//    }
}
