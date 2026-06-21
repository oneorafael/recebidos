//
//  ProjectDetailView.swift
//  Recebidos?
//

import SwiftUI

struct ProjectDetailView: View {
    @State private var project: ClientProject
    let profile: UserProfile
    let onSetPaid: (ClientProject, Bool) -> Void
    let onUpdateValue: (ClientProject, Decimal) -> Void

    @State private var selectedTone: MessageTone = .professional
    @State private var generatedMessage: String?
    @State private var isGeneratingMessage = false
    @State private var generationError: String?
    @State private var isEditingValue = false

    init(
        project: ClientProject,
        profile: UserProfile,
        onSetPaid: @escaping (ClientProject, Bool) -> Void,
        onUpdateValue: @escaping (ClientProject, Decimal) -> Void
    ) {
        _project = State(initialValue: project)
        self.profile = profile
        self.onSetPaid = onSetPaid
        self.onUpdateValue = onUpdateValue
    }

    var message: String {
        generatedMessage ?? MessageBuilder.message(for: project, profile: profile, tone: selectedTone)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    PaymentStatusBadge(isPaid: project.isPaid)

                    Text(project.projectName)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))

                    Text(project.clientName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .glassCard()

                PaymentStateControl(isPaid: project.isPaid) { isPaid in
                    project.isPaid = isPaid
                    onSetPaid(project, isPaid)
                }

                VStack(alignment: .leading, spacing: 12) {
                    DetailLine(title: "Data do projeto", value: project.projectDate.formatted(date: .long, time: .omitted), icon: "calendar")
                    DetailLine(title: "Prazo do pagamento", value: project.paymentDueDate.formatted(date: .long, time: .omitted), icon: "calendar.badge.clock")
                    Button {
                        isEditingValue = true
                    } label: {
                        HStack(spacing: 12) {
                            DetailLine(
                                title: "Valor",
                                value: project.projectValue.formatted(.currency(code: "BRL")),
                                icon: "banknote.fill"
                            )

                            Image(systemName: "pencil")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Editar valor do projeto")
                    DetailLine(title: "Contato", value: project.contactMethod.rawValue, icon: project.contactMethod.icon)
                }
                .padding(16)
                .glassCard()

                if !project.isPaid {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: "Mensagem sugerida", icon: "sparkles")

                        Picker("Tom", selection: $selectedTone) {
                            ForEach(MessageTone.allCases) { tone in
                                Text(tone.rawValue).tag(tone)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedTone) {
                            generatedMessage = nil
                            generationError = nil
                        }

                        Text(message)
                            .font(.body)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        if let generationError {
                            Label(generationError, systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                        }

                        Button {
                            Task {
                                await generateMessageWithAI()
                            }
                        } label: {
                            Label(
                                isGeneratingMessage ? "Gerando..." : "Gerar com IA local",
                                systemImage: isGeneratingMessage ? "hourglass" : "sparkles"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isGeneratingMessage)

                        ShareLink(item: message) {
                            Label("Compartilhar cobrança", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(16)
                    .glassCard()
                }
            }
            .padding(20)
        }
        .background(AppBackground())
        .navigationTitle("Projeto")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditingValue) {
            EditProjectValueView(value: project.projectValue) { value in
                project.projectValue = value
                generatedMessage = nil
                generationError = nil
                onUpdateValue(project, value)
            }
            .presentationDetents([.medium])
        }
    }

    private func generateMessageWithAI() async {
        isGeneratingMessage = true
        generationError = nil

        do {
            generatedMessage = try await AIMessageGenerator.message(for: project, profile: profile, tone: selectedTone)
        } catch {
            generatedMessage = nil
            generationError = error.localizedDescription
        }

        isGeneratingMessage = false
    }
}

private struct EditProjectValueView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isValueFieldFocused: Bool

    @State private var value: Decimal
    let onSave: (Decimal) -> Void

    init(value: Decimal, onSave: @escaping (Decimal) -> Void) {
        _value = State(initialValue: value)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        "Valor",
                        value: $value,
                        format: .currency(code: "BRL").locale(Locale(identifier: "pt_BR"))
                    )
                    .keyboardType(.decimalPad)
                    .focused($isValueFieldFocused)
                } footer: {
                    Text("O novo valor será atualizado também no resumo e no lembrete de pagamento.")
                }
            }
            .navigationTitle("Editar valor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        onSave(value)
                        dismiss()
                    }
                    .disabled(value <= 0)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Concluir") {
                        isValueFieldFocused = false
                    }
                }
            }
            .task {
                isValueFieldFocused = true
            }
        }
    }
}
