//
//  NewProjectView.swift
//  Recebidos?
//

import SwiftUI

struct NewProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isValueFieldFocused: Bool

    @State private var clientName = ""
    @State private var projectName = ""
    @State private var projectDate = Date()
    @State private var paymentDueDate = Date()
    @State private var projectValue: Decimal = 0
    @State private var isPaid = false
    @State private var contactMethod: ContactMethod = .whatsapp

    let onSave: (ClientProject) -> Void

    var canSave: Bool {
        !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        projectValue > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Cliente", text: $clientName)
                    TextField("Projeto ou evento", text: $projectName)
                    TextField(
                        "Valor",
                        value: $projectValue,
                        format: .currency(code: "BRL").locale(Locale(identifier: "pt_BR"))
                    )
                        .keyboardType(.decimalPad)
                        .focused($isValueFieldFocused)
                }

                Section {
                    DatePicker("Evento", selection: $projectDate, displayedComponents: .date)
                    DatePicker("Pagamento até", selection: $paymentDueDate, displayedComponents: .date)

                    Picker("Contato", selection: $contactMethod) {
                        ForEach(ContactMethod.allCases) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(6)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Toggle("Já recebi", isOn: $isPaid)
                }
            }
            .navigationTitle("Novo recebido")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        let project = ClientProject(
                            clientName: clientName,
                            projectName: projectName,
                            projectDate: projectDate,
                            paymentDueDate: paymentDueDate,
                            projectValue: projectValue,
                            isPaid: isPaid,
                            contactMethod: contactMethod,
                            contactInfo: "",
                            notes: ""
                        )

                        onSave(project)
                        dismiss()
                    }
                    .disabled(!canSave)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Concluir") {
                        isValueFieldFocused = false
                    }
                }
            }
        }
    }
}
