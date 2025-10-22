//
//  ActivityTypeChip.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct ActivityTypeChip: View {
    let type: ActivityType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            onTap()
        }) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.caption)

                Text(type.displayName)
                    .font(.bodySmall)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .adaptiveWhite : .adaptiveSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(1) : Color.clear)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(isSelected ? 0 : 1)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isSelected ? Color.accentColor : Color.borderLight,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityTypeChipSelector: View {
    @Binding var selectedType: ActivityType?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Type")
                .font(.bodySmall)
                .foregroundColor(.adaptiveSecondary)

            FlowLayout(spacing: 8) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    ActivityTypeChip(
                        type: type,
                        isSelected: selectedType == type,
                        onTap: {
                            if selectedType == type {
                                selectedType = nil
                            } else {
                                selectedType = type
                            }
                        }
                    )
                }
            }
        }
    }
}

// Flow Layout for wrapping chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)

                if x + subviewSize.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, subviewSize.height)
                x += subviewSize.width + spacing
            }

            size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    VStack {
        ActivityTypeChipSelector(selectedType: .constant(.focus))
            .padding()
    }
    .background(Color.secondaryBackground)
}
