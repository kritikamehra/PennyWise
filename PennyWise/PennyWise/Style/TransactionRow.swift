//
//  TransactionRow.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//
import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: Spacing.medium) {

            // MARK: - Icon
            ZStack {
                Circle()
                    .fill(transaction.type == "Income" ?
                          ColorPalette.income.opacity(0.15) :
                          ColorPalette.expense.opacity(0.15))
                    .frame(width: 46, height: 46)

                Image(systemName: transaction.type == "Income" ?
                      "arrow.up.circle.fill" :
                      "arrow.down.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(transaction.type == "Income" ?
                                     ColorPalette.income :
                                     ColorPalette.expense)
            }

            // MARK: - Text
            VStack(alignment: .leading, spacing: Spacing.small) {

                Text(transaction.category.name)
                    .font(FontStyle.heading)
                    .foregroundColor(ColorPalette.textPrimary)

                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(FontStyle.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Text(transaction.date, style: .date)
                    .font(FontStyle.caption)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            Spacer()

            // MARK: - Amount
            Text("₹\(transaction.amount, specifier: "%.2f")")
                .font(FontStyle.heading)
                .foregroundColor(transaction.type == "Income" ?
                                 ColorPalette.income :
                                 ColorPalette.expense)
        }
        .background(ColorPalette.surface)
    }
}

