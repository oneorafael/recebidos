//
//  Components.swift
//  Recebidos?
//

import SwiftUI

struct PaymentStatusBadge: View {
    let isPaid: Bool

    var body: some View {
        Label(isPaid ? "Recebido" : "Pendente", systemImage: isPaid ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(isPaid ? .green : .red)
            .background((isPaid ? Color.green : Color.red).opacity(0.12), in: Capsule())
    }
}

struct CompactPaymentStatus: View {
    let isPaid: Bool

    var body: some View {
        Circle()
            .fill(isPaid ? Color.green : Color.red)
            .frame(width: 10, height: 10)
            .accessibilityLabel(isPaid ? "Recebido" : "Pendente")
    }
}

struct PaymentStateControl: View {
    let isPaid: Bool
    let onChange: (Bool) -> Void
    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 8) {
            PaymentStateButton(
                title: "Não recebi",
                icon: "clock",
                isSelected: !isPaid,
                tint: .orange,
                namespace: selectionNamespace
            ) {
                withAnimation(.smooth(duration: 0.28)) {
                    onChange(false)
                }
            }

            PaymentStateButton(
                title: "Recebi",
                icon: "checkmark",
                isSelected: isPaid,
                tint: .green,
                namespace: selectionNamespace
            ) {
                withAnimation(.smooth(duration: 0.28)) {
                    onChange(true)
                }
            }
        }
        .padding(6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .animation(.smooth(duration: 0.28), value: isPaid)
    }
}

struct PaymentStateButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let tint: Color
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .foregroundStyle(isSelected ? .white : .primary)
                .contentTransition(.symbolEffect(.replace))
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(tint)
                            .matchedGeometryEffect(id: "paymentSelection", in: namespace)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct DateBadge: View {
    let date: Date

    var body: some View {
        VStack(spacing: 2) {
            Text(date.formatted(.dateTime.month(.abbreviated)).uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            Text(date.formatted(.dateTime.day()))
                .font(.title2.weight(.bold))
        }
        .frame(width: 54, height: 58)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct DetailLine: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)
                .background(.blue.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body.weight(.medium))
            }

            Spacer(minLength: 0)
        }
    }
}

struct SectionTitle: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.title3.weight(.bold))
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard()
    }
}

struct AppBackground: View {
    var body: some View {
        Color(.secondarySystemBackground)
            .ignoresSafeArea()
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        } else {
            content
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.28), lineWidth: 1)
                }
        }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}
