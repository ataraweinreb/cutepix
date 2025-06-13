//
//  ColorSortView.swift
//  SwipePhoto
//
//  Created by Atara Weinreb on 6/13/25.
//


import SwiftUI
import Photos

struct PhotoThumbnail: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Color.gray.frame(width: 60, height: 60).cornerRadius(10)
            }
        }
        .onAppear {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.isSynchronous = false
            options.resizeMode = .fast
            manager.requestImage(for: asset, targetSize: CGSize(width: 60, height: 60), contentMode: .aspectFill, options: options) { img, _ in
                self.image = img
            }
        }
    }
}
