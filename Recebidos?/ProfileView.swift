//
//  ProfileView.swift
//  Recebidos?
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var ownerName: String
    @State private var companyName: String

    let onSave: (UserProfile) -> Void

    init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        _ownerName = State(initialValue: profile.ownerName)
        _companyName = State(initialValue: profile.companyName)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Seu nome", text: $ownerName)
                        .textContentType(.name)

                    TextField("Empresa ou marca", text: $companyName)
                        .textContentType(.organizationName)
                } footer: {
                    Text("Esses dados entram na assinatura e no contexto usado pela IA ao gerar cobranças.")
                }
            }
            .navigationTitle("Perfil")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        onSave(UserProfile(ownerName: ownerName, companyName: companyName))
                        dismiss()
                    }
                }
            }
        }
    }
}
