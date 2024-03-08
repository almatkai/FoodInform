//
//  ImageUrlView.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 02.03.2024.
//

import SwiftUI

struct ImageFromUrlView: View {
    var imageURL: String

    var body: some View {
        VStack {
            if let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Show a loading indicator
                    case .success(let image):
                        image.resizable().scaledToFit()
                    case .failure:
                        Image(systemName: "photo.fill") // Placeholder on error
                    @unknown default:
                        EmptyView()
                    }
                }
                .scaledToFill()
                .frame(width: 100)
            }
        }
    }
}
