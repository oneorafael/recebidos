//
//  PaymentNotificationManager.swift
//  Recebidos?
//

import Foundation
import UserNotifications

enum PaymentNotificationManager {
    private static let notificationPrefix = "payment-due-"

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func schedulePaymentReminder(for project: ClientProject) {
        guard !project.isPaid else {
            cancelPaymentReminder(for: project)
            return
        }

        guard let reminderDate = Calendar.current.date(
            bySettingHour: 9,
            minute: 0,
            second: 0,
            of: project.paymentDueDate
        ), reminderDate > .now else {
            cancelPaymentReminder(for: project)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Cobrança vence hoje"
        content.body = "\(project.clientName) - \(project.projectValue.formatted(.currency(code: "BRL"))) de \(project.projectName)."
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: project),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier(for: project)]
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelPaymentReminder(for project: ClientProject) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier(for: project)]
        )
    }

    private static func notificationIdentifier(for project: ClientProject) -> String {
        "\(notificationPrefix)\(project.id.uuidString)"
    }
}
