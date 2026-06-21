//
//  ProjectDetailView.swift
//  Recebidos?
//

import SwiftUI

struct ProjectDetailView: View {
    let project: ClientProject
    let profile: UserProfile
    let onSetPaid: (ClientProject, Bool) -> Void

    @State private var selectedTone: MessageTone = .professional
    @State private var generatedMessage: String?
    @State private var isGeneratingMessage = false
    @State private var generationError: String?

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
                    onSetPaid(project, isPaid)
                }

                VStack(alignment: .leading, spacing: 12) {
                    DetailLine(title: "Data do projeto", value: project.projectDate.formatted(date: .long, time: .omitted), icon: "calendar")
                    DetailLine(title: "Prazo do pagamento", value: project.paymentDueDate.formatted(date: .long, time: .omitted), icon: "calendar.badge.clock")
                    DetailLine(title: "Valor", value: project.projectValue.formatted(.currency(code: "BRL")), icon: "banknote.fill")
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
