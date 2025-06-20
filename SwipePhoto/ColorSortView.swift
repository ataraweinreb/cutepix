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
    @State private var isLoading = true
    @State private var loadError = false

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(10)
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(0.8)
                    .frame(width: 60, height: 60)
            } else if loadError {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            } else {
                Color.gray.frame(width: 60, height: 60).cornerRadius(10)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        isLoading = true
        loadError = false
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = false
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: options) { img, info in
            DispatchQueue.main.async {
                self.isLoading = false
                if let img = img {
                    self.image = img
                } else {
                    self.loadError = true
                    print("Failed to load thumbnail for asset: \(asset.localIdentifier)")
                    if let error = info?[PHImageErrorKey] as? Error {
                        print("Thumbnail loading error: \(error)")
                    }
                }
            }
        }
    }
}
