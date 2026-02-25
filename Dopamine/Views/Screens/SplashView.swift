//
//  SplashView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var showBackground = false
    @State private var showOuterRing = false
    @State private var showInnerCircle = false
    @State private var showLetter = false
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var pulseRing = false
    @State private var rotateOrbs = false
    @State private var shimmer = false
    @State private var dismissSplash = false
    @State private var moveToLogin = false

    var body: some View {
        ZStack {
            SplashBackgroundView(
                colorScheme: colorScheme,
                showBackground: showBackground
            )
            SplashFloatingOrbsView(
                rotateOrbs: rotateOrbs,
                showBackground: showBackground
            )
            VStack(spacing: 28) {
                Spacer()
                SplashLogoView(
                    showOuterRing: showOuterRing,
                    showInnerCircle: showInnerCircle,
                    showLetter: showLetter,
                    pulseRing: pulseRing,
                    rotateOrbs: rotateOrbs,
                    shimmer: shimmer
                )
                SplashTitleView(
                    colorScheme: colorScheme,
                    showTitle: showTitle,
                    showTagline: showTagline
                )
                Spacer()
                SplashLoadingDotsView(showTagline: showTagline)
                    .padding(.bottom, 60)
            }
        }
        .opacity(dismissSplash ? 0 : 1)
        .scaleEffect(dismissSplash ? 1.1 : 1.0)
        .onAppear(perform: startAnimationSequence)
        .fullScreenCover(isPresented: $moveToLogin) {
            LoginView()
        }
    }

    // MARK: - Animation Sequence

    private func startAnimationSequence() {
        withAnimation(.easeOut(duration: 0.8)) {
            showBackground = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            rotateOrbs = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                showOuterRing = true
            }
            pulseRing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                showInnerCircle = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                showLetter = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeInOut(duration: 1.0)) {
                shimmer = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                showTitle = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                showTagline = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeIn(duration: 0.4)) {
                dismissSplash = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
            moveToLogin = true
        }
    }
}

// MARK: - Background

private struct SplashBackgroundView: View {
    let colorScheme: ColorScheme
    let showBackground: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark
                    ? [Color(red: 0.06, green: 0.02, blue: 0.12),
                       Color(red: 0.12, green: 0.06, blue: 0.20),
                       Color(red: 0.05, green: 0.02, blue: 0.10)]
                    : [Color(red: 0.93, green: 0.90, blue: 0.98),
                       Color(red: 0.96, green: 0.94, blue: 1.0),
                       Color(red: 0.90, green: 0.92, blue: 0.98)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.purple.opacity(showBackground ? 0.25 : 0))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(x: -80, y: -200)

            Circle()
                .fill(Color.blue.opacity(showBackground ? 0.20 : 0))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: 100, y: 250)
        }
    }
}

// MARK: - Floating Orbs

private struct SplashFloatingOrbsView: View {
    let rotateOrbs: Bool
    let showBackground: Bool

    private let sizes: [CGFloat] = [18, 12, 22, 10, 16, 14]
    private let durations: [Double] = [20, 25, 18, 22, 28, 24]
    private let offsets: [CGSize] = [
        CGSize(width: -120, height: -180),
        CGSize(width: 140, height: -120),
        CGSize(width: -100, height: 200),
        CGSize(width: 130, height: 160),
        CGSize(width: -50, height: -280),
        CGSize(width: 80, height: 300)
    ]

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: index.isMultiple(of: 2)
                                ? [Color.purple.opacity(0.4), Color.blue.opacity(0.2)]
                                : [Color.blue.opacity(0.35), Color.purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: sizes[index], height: sizes[index])
                    .blur(radius: 8)
                    .offset(offsets[index])
                    .rotationEffect(.degrees(rotateOrbs ? 360 : 0))
                    .opacity(showBackground ? 0.6 : 0)
                    .animation(
                        .linear(duration: durations[index])
                        .repeatForever(autoreverses: false),
                        value: rotateOrbs
                    )
            }
        }
    }
}

// MARK: - Logo

private struct SplashLogoView: View {
    let showOuterRing: Bool
    let showInnerCircle: Bool
    let showLetter: Bool
    let pulseRing: Bool
    let rotateOrbs: Bool
    let shimmer: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 40,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(pulseRing ? 1.15 : 0.95)
                .opacity(showOuterRing ? 1 : 0)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: pulseRing
                )

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.purple.opacity(0.8),
                            Color.blue.opacity(0.6),
                            Color.purple.opacity(0.4),
                            Color.blue.opacity(0.8),
                            Color.purple.opacity(0.8)
                        ],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(rotateOrbs ? 360 : 0))
                .scaleEffect(showOuterRing ? 1 : 0.3)
                .opacity(showOuterRing ? 1 : 0)
                .animation(
                    .linear(duration: 8).repeatForever(autoreverses: false),
                    value: rotateOrbs
                )

            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.purple.opacity(0.4), radius: 20, x: 0, y: 10)
                .scaleEffect(showInnerCircle ? 1 : 0)
                .opacity(showInnerCircle ? 1 : 0)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0)
                        ],
                        startPoint: shimmer ? .topLeading : .bottomTrailing,
                        endPoint: shimmer ? .bottomTrailing : .topLeading
                    )
                )
                .frame(width: 120, height: 120)
                .opacity(showInnerCircle ? 1 : 0)

            Text("D")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.purple.opacity(0.5), radius: 8, x: 0, y: 4)
                .scaleEffect(showLetter ? 1 : 0.2)
                .opacity(showLetter ? 1 : 0)
        }
    }
}

// MARK: - Title & Tagline

private struct SplashTitleView: View {
    let colorScheme: ColorScheme
    let showTitle: Bool
    let showTagline: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Dopamine")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: colorScheme == .dark
                            ? [Color.white, Color.white.opacity(0.8)]
                            : [Color(red: 0.1, green: 0.05, blue: 0.15),
                               Color(red: 0.3, green: 0.15, blue: 0.45)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(y: showTitle ? 0 : 20)
                .opacity(showTitle ? 1 : 0)

            Text("Break free from doomscrolling")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark
                    ? Color.white.opacity(0.6)
                    : Color(red: 0.35, green: 0.30, blue: 0.45))
                .offset(y: showTagline ? 0 : 15)
                .opacity(showTagline ? 1 : 0)
        }
    }
}

// MARK: - Loading Dots

private struct SplashLoadingDotsView: View {
    let showTagline: Bool

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .scaleEffect(showTagline ? 1 : 0)
                    .opacity(showTagline ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: showTagline
                    )
            }
        }
    }
}

#Preview {
    SplashView()
}
