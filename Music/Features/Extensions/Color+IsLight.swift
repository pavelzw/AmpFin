//
//  Color+IsLight.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI

#if canImport(UIKit)
extension UIColor {
    func isLight(threshold: Float = 0.5) -> Bool {
        let originalCGColor = self.cgColor
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components, components.count >= 3 else {
            return false
        }
        
        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}
#endif
