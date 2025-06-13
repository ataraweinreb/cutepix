//
//  UIImage+DominantColor.swift
//  SwipePhoto
//
//  Created by Atara Weinreb on 6/13/25.
//

import UIKit

extension UIImage {
    func dominantColor() -> UIColor? {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: .zero, size: size))
        let context = UIGraphicsGetCurrentContext()
        let data = context?.data
        UIGraphicsEndImageContext()
        guard let pixelData = data else { return nil }
        let ptr = pixelData.bindMemory(to: UInt8.self, capacity: 4 * 100)
        var r = 0, g = 0, b = 0
        for i in stride(from: 0, to: 100 * 4, by: 4) {
            r += Int(ptr[i])
            g += Int(ptr[i+1])
            b += Int(ptr[i+2])
        }
        let count = 100
        return UIColor(red: CGFloat(r/count)/255, green: CGFloat(g/count)/255, blue: CGFloat(b/count)/255, alpha: 1)
    }
} 
