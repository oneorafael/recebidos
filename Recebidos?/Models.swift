//
//  Models.swift
//  Recebidos?
//

import Foundation

enum ContactMethod: String, CaseIterable, Identifiable, Codable {
    case whatsapp = "WhatsApp"
    case email = "E-mail"
    case other = "Outro"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .whatsapp: "message.fill"
        case .email: "envelope.fill"
        case .other: "ellipsis.message.fill"
        }
    }
}

enum MessageTone: String, CaseIterable, Identifiable, Codable {
    case friendly = "Amigável"
    case professional = "Profissional"
    case firm = "Firme"

    var id: String { rawValue }

    var instruction: String {
        switch self {
        case .friendly:
            "tom cordial, leve e próximo, sem parecer cobrança dura"
        case .professional:
            "tom claro, educado e profissional"
        case .firm:
            "tom objetivo e firme, mantendo respeito e evitando ameaças"
        }
    }
}

struct UserProfile: Codable, Equatable {
    var ownerName: String
    var companyName: String

    var signature: String {
        let trimmedOwner = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCompany = companyName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedOwner.isEmpty {
            return trimmedCompany
        }

        if trimmedCompany.isEmpty {
            return trimmedOwner
        }

        return "\(trimmedOwner)\n\(trimmedCompany)"
    }

    static let sample = UserProfile(ownerName: "Rafael Oliveira", companyName: "Recebidos Filmes")
}

struct ClientProject: Identifiable, Codable, Equatable {
    var id: UUID
    var clientName: String
    var projectName: String
    var projectDate: Date
    var paymentDueDate: Date
    var projectValue: Decimal
    var isPaid: Bool
    var contactMethod: ContactMethod
    var contactInfo: String
    var notes: String

    init(
        id: UUID = UUID(),
        clientName: String,
        projectName: String,
        projectDate: Date,
        paymentDueDate: Date,
        projectValue: Decimal,
        isPaid: Bool,
        contactMethod: ContactMethod,
        contactInfo: String = "",
        notes: String = ""
    ) {
        self.id = id
        self.clientName = clientName
        self.projectName = projectName
        self.projectDate = projectDate
        self.paymentDueDate = paymentDueDate
        self.projectValue = projectValue
        self.isPaid = isPaid
        self.contactMethod = contactMethod
        self.contactInfo = contactInfo
        self.notes = notes
    }
}

extension ClientProject {
    static let samples: [ClientProject] = [
        ClientProject(
            clientName: "Studio Luz",
            projectName: "Vídeo institucional",
            projectDate: .now.addingTimeInterval(60 * 60 * 24 * 2),
            paymentDueDate: .now.addingTimeInterval(60 * 60 * 24),
            projectValue: 4200,
            isPaid: false,
            contactMethod: .email,
            contactInfo: "financeiro@studioluz.com"
        ),
        ClientProject(
            clientName: "Mariana e João",
            projectName: "Casamento no Solar",
            projectDate: .now.addingTimeInterval(60 * 60 * 24 * 5),
            paymentDueDate: .now.addingTimeInterval(60 * 60 * 24 * 3),
            projectValue: 2800,
            isPaid: false,
            contactMethod: .whatsapp,
            contactInfo: "+55 11 99999-9999"
        ),
        ClientProject(
            clientName: "Café Aurora",
            projectName: "Reels de lançamento",
            projectDate: .now.addingTimeInterval(60 * 60 * 24 * 10),
            paymentDueDate: .now.addingTimeInterval(60 * 60 * 24 * 8),
            projectValue: 1500,
            isPaid: true,
            contactMethod: .whatsapp
        )
    ]
}
