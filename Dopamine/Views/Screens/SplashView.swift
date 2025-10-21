//
//  SplashView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var moveToLogin = false

    var body: some View {
        VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.borderAccent, lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)

                    Text("D")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.adaptiveWhite)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))

                Text("Dopamine")
                    .font(.displayMedium)
                    .foregroundColor(.adaptiveWhite)
                    .fontWeight(.bold)

                Text("Break free from doomscrolling")
                    .font(.bodyRegular)
                    .foregroundColor(.adaptiveSecondary)
        }
        .opacity(isAnimating ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                isAnimating = true
            }

            // Navigate to login after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                moveToLogin = true
            }
        }
        .fullScreenCover(isPresented: $moveToLogin) {
            LoginView()
        }
    }
}

#Preview {
    SplashView()
}
