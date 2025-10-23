//
//  MenuView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.menuConfiguration == nil {
                // Loading State
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .adaptiveWhite))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let menuConfig = viewModel.menuConfiguration {
                // Menu Categories List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(menuConfig.getAllCategories(), id: \.category) { item in
                            MenuCategoryCard(
                                categoryInfo: item.info,
                                category: item.category,
                                onAdd: {
                                    handleAddCategory(item.category, item.info)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            } else {
                // Error State
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Menu Not Available",
                    message: "Unable to load menu. Please try again later.",
                    actionTitle: "Retry",
                    action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                )
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .overlay(
            ToastView(message: toastMessage, isShowing: $showToast)
                .animation(.spring(), value: showToast)
        )
    }

    private func handleAddCategory(_ category: ActivityCategory, _ info: MenuCategoryInfo) {
        toastMessage = "Added \(info.title) to your selections!"
        showToast = true
        HapticManager.notification(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

// MARK: - Menu Category Card
struct MenuCategoryCard: View {
    let categoryInfo: MenuCategoryInfo
    let category: ActivityCategory
    let onAdd: () -> Void
    @State private var isAdded = false
    @State private var showBottomSheet = false

    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                // Top: Icon, Title, and Plus Button in same line
                HStack(alignment: .center, spacing: 10) {
                    // Category Icon (smaller)
                    Text(categoryInfo.icon)
                        .font(.system(size: 16))
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                    
                    // Category Name (smaller)
                    Text(categoryInfo.title)
                        .font(.headline)
                        .foregroundColor(.adaptiveWhite)
                    
                    Spacer()
                    
                    // Plus Button (smaller)
                    Button(action: {
                        HapticManager.impact(.light)
                        showBottomSheet = true
                    }) {
                        Image(systemName: isAdded ? "checkmark" : "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isAdded ? .green : .adaptiveWhite)
                            .frame(width: 40, height: 40)
                            .background {
                                if isAdded {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                } else {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                }
                            }
                            .overlay(
                                Circle()
                                    .stroke(isAdded ? Color.green : Color.clear, lineWidth: 2)
                            )
                    }
                    .disabled(isAdded)
                    .scaleEffect(isAdded ? 1.1 : 1.0)
                }
                
                // Category Description (smaller text)
                Text(categoryInfo.description)
                    .font(.caption2)
                    .foregroundColor(.adaptiveSecondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
        }
        .sheet(isPresented: $showBottomSheet) {
            CategoryBottomSheet(
                categoryInfo: categoryInfo,
                category: category,
                onAdd: {
                    onAdd()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAdded = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isAdded = false
                        }
                    }
                }
            )
        }
    }
}

// MARK: - Category Bottom Sheet
struct CategoryBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    let categoryInfo: MenuCategoryInfo
    let category: ActivityCategory
    let onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Category Icon and Title
                VStack(spacing: 12) {
                    Text(categoryInfo.icon)
                        .font(.system(size: 64))
                        .frame(width: 80, height: 80)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                    
                    Text(categoryInfo.title)
                        .font(.h1)
                        .foregroundColor(.adaptiveWhite)
                }
                .padding(.top, 20)
                
                // Description
                Text(categoryInfo.description)
                    .font(.bodyRegular)
                    .foregroundColor(.adaptiveSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        onAdd()
                        HapticManager.notification(.success)
                        dismiss()
                    }) {
                        Text("Add to Selection")
                            .font(.h3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.accentColor)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        HapticManager.impact(.light)
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.h3)
                            .foregroundColor(.adaptiveSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.secondaryBackground)
            .navigationTitle(category.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
