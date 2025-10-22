//
//  OTPVerificationView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI
internal import Combine

struct OTPVerificationView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var timeRemaining = 60
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

                        Text(viewModel.email)
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
                                get: { viewModel.otpCode[index] },
                                set: { newValue in
                                    let oldValue = viewModel.otpCode[index]
                                    
                                    // Handle paste of full OTP code
                                    if newValue.count > 1 {
                                        let digits = newValue.filter { $0.isNumber }
                                        let digitsArray = Array(digits.prefix(6))
                                        for (i, digit) in digitsArray.enumerated() {
                                            if i < 6 {
                                                viewModel.otpCode[i] = String(digit)
                                            }
                                        }
                                        focusedField = min(digitsArray.count, 5)
                                        return
                                    }
                                    
                                    viewModel.otpCode[index] = newValue
                                    
                                    // Auto-advance to next field when digit is entered
                                    if !newValue.isEmpty && newValue != oldValue && index < 5 {
                                        focusedField = index + 1
                                    }
                                    // Auto-go back when deleted
                                    else if newValue.isEmpty && oldValue != newValue && index > 0 {
                                        focusedField = index - 1
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
                            Task {
                                await viewModel.resendOTP()
                                timeRemaining = 60
                                focusedField = 0
                            }
                        }
                        .font(.bodySmall)
                        .foregroundColor(.adaptiveWhite)
                    }
                }

                // Verify Button
                GlassButton(
                    title: "Verify Code",
                    action: {
                        Task {
                            await viewModel.verifyOTP { success in
                                if success {
                                    dismiss()
                                }
                            }
                        }
                    },
                    isLoading: viewModel.isLoading,
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
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
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
                .onChange(of: text) { oldValue, newValue in
                    // Only allow digits and limit to 1 character
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count > 1 {
                        text = String(filtered.prefix(1))
                    } else if filtered != newValue {
                        text = filtered
                    }
                }
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
    OTPVerificationView(viewModel: AuthViewModel())
}
