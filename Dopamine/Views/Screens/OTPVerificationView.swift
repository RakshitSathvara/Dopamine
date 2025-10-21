//
//  OTPVerificationView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI
internal import Combine

struct OTPVerificationView: View {
    let email: String

    @State private var otpCode: [String] = Array(repeating: "", count: 6)
    @State private var timeRemaining = 60
    @State private var isLoading = false
    @State private var moveToHome = false
    @FocusState private var focusedField: Int?
    @Environment(\.dismiss) private var dismiss

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 40) {
                HStack {
                    Button(action: {
                        HapticManager.impact(.light)
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.adaptiveWhite)
                            .padding()
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)

                Spacer()

                // Header
                VStack(spacing: 16) {
                    Text("Enter verification code")
                        .font(.h1)
                        .foregroundColor(.adaptiveWhite)

                    VStack(spacing: 4) {
                        Text("Code sent to")
                            .font(.bodyRegular)
                            .foregroundColor(.adaptiveSecondary)

                        Text(email)
                            .font(.bodySmall)
                            .foregroundColor(.adaptiveWhite)
                            .fontWeight(.semibold)
                    }
                }

                // OTP Fields
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        OTPDigitField(
                            text: Binding(
                                get: { otpCode[index] },
                                set: { newValue in
                                    if newValue.count <= 1 {
                                        otpCode[index] = newValue
                                        handleOTPInput(at: index, value: newValue)
                                    }
                                }
                            ),
                            isFocused: focusedField == index
                        )
                        .focused($focusedField, equals: index)
                    }
                }
                .padding(.horizontal, 20)

                // Resend Timer
                HStack(spacing: 8) {
                    Text("Didn't receive code?")
                        .font(.bodySmall)
                        .foregroundColor(.adaptiveSecondary)

                    if timeRemaining > 0 {
                        Text("Resend in \(formatTime(timeRemaining))")
                            .font(.bodySmall)
                            .foregroundColor(.adaptiveTertiary)
                    } else {
                        Button("Resend") {
                            HapticManager.impact(.light)
                            resendOTP()
                        }
                        .font(.bodySmall)
                        .foregroundColor(.adaptiveWhite)
                    }
                }

                // Verify Button
                GlassButton(
                    title: "Verify Code",
                    action: verifyOTP,
                    isLoading: isLoading,
                    isDisabled: false
                )
                .padding(.horizontal, 30)

                Spacer()
        }
        .onAppear {
            focusedField = 0
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .fullScreenCover(isPresented: $moveToHome) {
            MainTabView()
        }
    }

    private func handleOTPInput(at index: Int, value: String) {
        if value.count == 1 && index < 5 {
            focusedField = index + 1
        } else if value.isEmpty && index > 0 {
            focusedField = index - 1
        }
    }

    private func verifyOTP() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            HapticManager.notification(.success)
            moveToHome = true
        }
    }

    private func resendOTP() {
        timeRemaining = 60
        otpCode = Array(repeating: "", count: 6)
        focusedField = 0
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct OTPDigitField: View {
    @Binding var text: String
    let isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 56)

            TextField("", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.h2)
                .foregroundColor(.adaptiveWhite)
                .frame(height: 56)
                .background(Color.clear)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    isFocused ? Color.adaptiveWhite.opacity(0.6) : Color.borderLight,
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .shadow(color: isFocused ? Color.purple.opacity(0.3) : Color.clear, radius: 10)
    }
}

#Preview {
    OTPVerificationView(email: "sarah@example.com")
}
