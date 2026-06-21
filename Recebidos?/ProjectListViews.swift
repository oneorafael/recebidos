//
//  ProjectListViews.swift
//  Recebidos?
//

import SwiftUI

struct SummaryHeader: View {
    let totalReceived: Decimal
    let totalPending: Decimal
    let pendingCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("A receber")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(pendingCount) em aberto")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(totalPending, format: .currency(code: "BRL"))
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .contentTransition(.numericText())

            Text("\(totalReceived.formatted(.currency(code: "BRL"))) já recebido")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct ProjectListSection: View {
    let projects: [ClientProject]
    let profile: UserProfile
    let onTogglePaid: (ClientProject) -> Void
    let onSetPaid: (ClientProject, Bool) -> Void
    let onUpdateValue: (ClientProject, Decimal) -> Void
    let onDelete: (ClientProject) -> Void

    var body: some View {
        Section {
            if projects.isEmpty {
                EmptyStateView(
                    title: "Nada cadastrado",
                    subtitle: "Adicione uma cobrança para acompanhar pagamentos."
                )
                .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 18, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(projects) { project in
                    NavigationLink {
                        ProjectDetailView(
                            project: project,
                            profile: profile,
                            onSetPaid: onSetPaid,
                            onUpdateValue: onUpdateValue
                        )
                    } label: {
                        ProjectRow(project: project, onTogglePaid: onTogglePaid)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDelete(project)
                        } label: {
                            Label("Apagar", systemImage: "trash")
                        }
                    }
                }
            }
        } header: {
            Text("Cobranças")
                .font(.title3.weight(.bold))
                .textCase(nil)
                .foregroundStyle(.primary)
        }
    }
}

struct ProjectRow: View {
    let project: ClientProject
    let onTogglePaid: (ClientProject) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                onTogglePaid(project)
            } label: {
                Image(systemName: project.isPaid ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(project.isPaid ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(project.isPaid ? "Marcar como pendente" : "Marcar como pago")

            VStack(alignment: .leading, spacing: 4) {
                Text(project.clientName)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(project.projectName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(project.isPaid ? "Recebido" : "Vence \(project.paymentDueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(project.isPaid ? .green : .secondary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text(project.projectValue, format: .currency(code: "BRL"))
                    .font(.callout.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(project.contactMethod.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
