//
//  AIMessageGenerator.swift
//  Recebidos?
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

enum AIMessageError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        "IA local indisponível neste dispositivo. Mantive a sugestão padrão."
    }
}

enum AIMessageGenerator {
    static func message(for project: ClientProject, profile: UserProfile, tone: MessageTone) async throws -> String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            let model = SystemLanguageModel.default

            guard case .available = model.availability else {
                throw AIMessageError.unavailable
            }

            let session = LanguageModelSession(model: model)
            let response = try await session.respond(to: prompt(for: project, profile: profile, tone: tone))
            return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        #endif

        throw AIMessageError.unavailable
    }

    private static func prompt(for project: ClientProject, profile: UserProfile, tone: MessageTone) -> String {
        let sender = profile.signature.isEmpty ? "não informado" : profile.signature.replacingOccurrences(of: "\n", with: " / ")

        return """
        Você é um assistente de comunicação para profissionais audiovisuais autônomos.
        Gere apenas uma mensagem de cobrança pronta para envio, em português do Brasil.
        Não inclua explicações, título, assinatura genérica nem opções alternativas.
        Não use placeholders como [seu nome], [seu cargo], [sua empresa] ou campos entre colchetes.
        Use \(tone.instruction).
        Evite linguagem jurídica, ameaças ou constrangimento.
        Se houver remetente informado, assine a mensagem com esses dados.

        Dados:
        - Remetente: \(sender)
        - Cliente: \(project.clientName)
        - Projeto: \(project.projectName)
        - Data do projeto: \(project.projectDate.formatted(date: .long, time: .omitted))
        - Prazo de pagamento: \(project.paymentDueDate.formatted(date: .long, time: .omitted))
        - Valor pendente: \(project.projectValue.formatted(.currency(code: "BRL")))
        - Canal preferido: \(project.contactMethod.rawValue)
        - Observações: \(project.notes.isEmpty ? "nenhuma" : project.notes)
        """
    }
}
