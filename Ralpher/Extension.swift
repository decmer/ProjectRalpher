//
//  Extension.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 17/12/24.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    func toHex() -> String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let r = Int(red * 255)
            let g = Int(green * 255)
            let b = Int(blue * 255)
            return String(format: "#%02X%02X%02X", r, g, b)
        }
        return nil
    }
}

extension Color {
    /// Calcula un color que contraste con el actual (claro si el color es oscuro y viceversa).
    func contrastingColor() -> Color {
        // Convertir el color actual a valores de RGB
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else { return .black }

        // Obtener los valores de los canales RGB (normalizados a [0, 1])
        let red = components[0]
        let green = components[1]
        let blue = components[2]

        // Calcular la luminancia relativa
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue

        // Si la luminancia es baja, devolver un color claro; de lo contrario, uno oscuro
        return luminance < 0.5 ? .white : .black
    }
}

extension Color {
    func complementaryColor() -> Color {
        let uiColor = UIColor(self)
        let components = uiColor.cgColor.components ?? [0, 0, 0, 1]

        let red = 1 - components[0]
        let green = 1 - components[1]
        let blue = 1 - components[2]
        
        return Color(red: red, green: green, blue: blue)
    }
}
extension LinearGradient {
    static func harmoniousGradient(baseColor: Color) -> LinearGradient {
        let complementary = baseColor.complementaryColor()

        return LinearGradient(gradient: Gradient(colors: [baseColor, complementary]),
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
    }
    
}


extension CGColor {
    /// Convierte el color actual al espacio sRGB si no lo está
    func copyConvertedToSRGB() -> CGColor? {
        guard let sRGBSpace = CGColorSpace(name: CGColorSpace.sRGB),
              colorSpace?.name != sRGBSpace.name else {
            return self // Ya es sRGB
        }
        return converted(to: sRGBSpace, intent: .defaultIntent, options: nil)
    }
}

extension Bool {
    @State static var trueState: Bool = true
    @State static var falseState: Bool = false
}
