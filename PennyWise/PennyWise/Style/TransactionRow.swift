//
//  TransactionRow.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//
import SwiftUI

struct TransactionRow: View {
    let tx: Transaction
    
    var body: some View {
        HStack(spacing: PWSpacing.element + 6) {
            icon
            info
            Spacer()
            amount
        }
        .padding(.vertical, PWSpacing.element)
    }
}
