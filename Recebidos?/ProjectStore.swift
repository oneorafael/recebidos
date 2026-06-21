//
//  ProjectStore.swift
//  Recebidos?
//

import Foundation
import Observation

@Observable
final class ProjectStore {
    private let projectsKey = "recebidos.projects"
    private let profileKey = "recebidos.profile"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var projects: [ClientProject]
    var profile: UserProfile

    init() {
        projects = Self.load(ClientProject.self, arrayForKey: projectsKey) ?? ClientProject.samples
        profile = Self.load(UserProfile.self, forKey: profileKey) ?? .sample
    }

    var totalReceived: Decimal {
        projects.filter(\.isPaid).reduce(0) { $0 + $1.projectValue }
    }

    var totalPending: Decimal {
        projects.filter { !$0.isPaid }.reduce(0) { $0 + $1.projectValue }
    }

    var nextSevenDays: [ClientProject] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let limit = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return projects
            .filter { project in
                let projectDay = calendar.startOfDay(for: project.projectDate)
                return projectDay >= today && projectDay <= limit
            }
            .sorted { $0.projectDate < $1.projectDate }
    }

    func add(_ project: ClientProject) {
        projects.append(project)
        projects.sort { $0.projectDate < $1.projectDate }
        saveProjects()
        PaymentNotificationManager.schedulePaymentReminder(for: project)
    }

    func togglePaid(for project: ClientProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index].isPaid.toggle()
        saveProjects()
        updatePaymentReminder(for: projects[index])
    }

    func setPaid(_ isPaid: Bool, for project: ClientProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index].isPaid = isPaid
        saveProjects()
        updatePaymentReminder(for: projects[index])
    }

    func updateValue(_ value: Decimal, for project: ClientProject) {
        guard value > 0,
              let index = projects.firstIndex(where: { $0.id == project.id }) else { return }

        projects[index].projectValue = value
        saveProjects()
        updatePaymentReminder(for: projects[index])
    }

    func delete(_ project: ClientProject) {
        PaymentNotificationManager.cancelPaymentReminder(for: project)
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }

    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        saveProfile()
    }

    func preparePaymentNotifications() async {
        guard await PaymentNotificationManager.requestAuthorization() else { return }
        projects.forEach(updatePaymentReminder)
    }

    func syncPaymentNotifications() {
        projects.forEach(updatePaymentReminder)
    }

    private func saveProjects() {
        save(projects, forKey: projectsKey)
    }

    private func saveProfile() {
        save(profile, forKey: profileKey)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func load<T: Decodable>(_ type: T.Type, arrayForKey key: String) -> [T]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([T].self, from: data)
    }

    private func updatePaymentReminder(for project: ClientProject) {
        if project.isPaid {
            PaymentNotificationManager.cancelPaymentReminder(for: project)
        } else {
            PaymentNotificationManager.schedulePaymentReminder(for: project)
        }
    }
}
