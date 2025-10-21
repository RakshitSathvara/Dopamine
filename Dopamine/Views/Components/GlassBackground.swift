//
//  GlassBackground.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct GlassBackground: View {
    let gradient: LinearGradient

    init(topColor: Color, bottomColor: Color) {
        self.gradient = LinearGradient(
            colors: [topColor, bottomColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    init(gradient: LinearGradient) {
        self.gradient = gradient
    }

    var body: some View {
        gradient
            .ignoresSafeArea()
    }
}
