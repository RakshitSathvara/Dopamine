//
//  CustomCheckbox.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct CustomCheckbox: View {
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isChecked ? Color.purple : Color.clear)
                    .frame(width: 24, height: 24)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isChecked ? Color.purple : Color.gray.opacity(0.5), lineWidth: 2)
                    .frame(width: 24, height: 24)

                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
