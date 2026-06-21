//
//  MessageBuilder.swift
//  Recebidos?
//

import Foundation

enum MessageBuilder {
    static func message(for project: ClientProject, profile: UserProfile, tone: MessageTone = .professional) -> String {
        let signature = profile.signature.isEmpty ? "" : "\n\n\(profile.signature)"

        return switch project.contactMethod {
        case .email:
            """
            Bom dia, \(project.clientName).

            Gostaria de lembrar que o projeto "\(project.projectName)", previsto para \(project.projectDate.formatted(date: .long, time: .omitted)), está se aproximando.

            Para seguirmos com a organização do serviço, solicito a realização do pagamento no valor de \(project.projectValue.formatted(.currency(code: "BRL"))) até \(project.paymentDueDate.formatted(date: .long, time: .omitted)).

            Fico à disposição para qualquer dúvida.\(signature)
            """
        case .whatsapp:
            """
            Olá, \(project.clientName)! Tudo bem?

            Passando para lembrar que o pagamento referente ao projeto "\(project.projectName)", marcado para \(project.projectDate.formatted(date: .abbreviated, time: .omitted)), ainda está pendente.

            O valor combinado é de \(project.projectValue.formatted(.currency(code: "BRL"))) e o prazo para pagamento é até \(project.paymentDueDate.formatted(date: .abbreviated, time: .omitted)).

            Qualquer dúvida, fico à disposição.\(signature)
            """
        case .other:
            """
            Olá, \(project.clientName). O pagamento referente ao projeto "\(project.projectName)" ainda está pendente.

            Valor: \(project.projectValue.formatted(.currency(code: "BRL")))
            Prazo combinado: \(project.paymentDueDate.formatted(date: .abbreviated, time: .omitted))\(signature)
            """
        }
    }
}
