//
//  ContentView.swift
//  Recebidos?
//
//  Created by Rafael Oliveira on 15/06/26.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var store = ProjectStore()
    @State private var isPresentingNewProject = false
    @State private var isPresentingProfile = false

    private var orderedProjects: [ClientProject] {
        store.projects.sorted {
            if $0.isPaid != $1.isPaid {
                return !$0.isPaid
            }

            return $0.paymentDueDate < $1.paymentDueDate
        }
    }

    var body: some View {
        NavigationStack {
            List {
                SummaryHeader(
                    totalReceived: store.totalReceived,
                    totalPending: store.totalPending,
                    pendingCount: store.projects.filter { !$0.isPaid }.count
                )
                .listRowInsets(EdgeInsets(top: 18, leading: 20, bottom: 12, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

                ProjectListSection(
                    projects: orderedProjects,
                    profile: store.profile,
                    onTogglePaid: { project in
                        store.togglePaid(for: project)
                    },
                    onSetPaid: { project, isPaid in
                        store.setPaid(isPaid, for: project)
                    },
                    onUpdateValue: { project, value in
                        store.updateValue(value, for: project)
                    },
                    onDelete: { project in
                        store.delete(project)
                    }
                )
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppBackground())
            .navigationTitle("Recebidos?")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresentingProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    .accessibilityLabel("Editar perfil")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewProject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                }
            }
            .sheet(isPresented: $isPresentingNewProject) {
                NewProjectView { project in
                    store.add(project)
                }
            }
            .sheet(isPresented: $isPresentingProfile) {
                ProfileView(profile: store.profile) { profile in
                    store.updateProfile(profile)
                }
            }
            .task {
                await prepareNotificationPrompt()
            }
        }
    }

    private func prepareNotificationPrompt() async {
        switch await PaymentNotificationManager.authorizationStatus() {
        case .notDetermined:
            await store.preparePaymentNotifications()
        case .authorized, .provisional, .ephemeral:
            store.syncPaymentNotifications()
        case .denied:
            break
        @unknown default:
            break
        }
    }
}

#Preview {
    ContentView()
}
