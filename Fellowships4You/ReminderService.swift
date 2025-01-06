import EventKit
import SwiftUI

class ReminderService: ObservableObject {
    private let store = EKEventStore()
    @Published var hasPermission = false
    
    init() {
        Task {
            await requestAccess()
        }
    }
    
    func requestAccess() async {
        do {
            hasPermission = try await store.requestAccess(to: .reminder)
        } catch {
            print("Failed to request reminders access: \(error)")
            hasPermission = false
        }
    }
    
    func createReminder(for scholarship: Scholarship, daysBeforeDeadline: Int?) async throws {
        guard let dueDate = dateFromString(scholarship.dueDate) else { return }
        
        let reminder = EKReminder(eventStore: store)
        reminder.title = "Deadline approaching: \(scholarship.name)"
        reminder.notes = "Application deadline for \(scholarship.name)\n\n\(scholarship.description)"
        
        // Set calendar
        guard let calendar = store.defaultCalendarForNewReminders() else {
            throw NSError(domain: "ReminderService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No default calendar found"])
        }
        reminder.calendar = calendar
        
        // Set due date
        let reminderDate: Date
        if let daysBeforeDeadline = daysBeforeDeadline {
            reminderDate = dueDate.addingTimeInterval(-TimeInterval(daysBeforeDeadline * 24 * 60 * 60))
        } else {
            reminderDate = Date().addingTimeInterval(24 * 60 * 60) // tomorrow
        }
        
        // Set alarm for 9 AM on the reminder date
        let calendar2 = Calendar.current
        var components = calendar2.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = 9
        components.minute = 0
        
        if let alarmDate = calendar2.date(from: components) {
            let alarm = EKAlarm(absoluteDate: alarmDate)
            reminder.addAlarm(alarm)
        }
        
        try store.save(reminder, commit: true)
    }
    
    private func dateFromString(_ dateString: String) -> Date? {
        let components = dateString.split(separator: "/")
        guard components.count >= 3,
              let month = Int(components[0]),
              let day = Int(components[1]),
              let year = Int(components[2]) else {
            return nil
        }
        
        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.year = year
        
        return Calendar.current.date(from: dateComponents)
    }
} 