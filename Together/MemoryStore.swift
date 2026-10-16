import Foundation
import Combine

struct Memory: Identifiable, Codable {
    var id = UUID()
    var title: String
    var note: String
    var date: Date
    var photo: Data?
}

struct Occasion: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var repeatsYearly: Bool

    var nextDate: Date {
        guard repeatsYearly else { return date }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let parts = calendar.dateComponents([.month, .day], from: date)
        return calendar.nextDate(after: today.addingTimeInterval(-1), matching: parts,
                                 matchingPolicy: .nextTime) ?? date
    }
}

@MainActor
final class MemoryStore: ObservableObject {
    @Published private(set) var memories: [Memory] = []
    @Published private(set) var occasions: [Occasion] = []
    @Published var errorMessage: String?

    private struct Archive: Codable {
        var memories: [Memory]
        var occasions: [Occasion]
    }

    private let file = URL.documentsDirectory.appending(path: "together.json")
    private var loadFailed = false

    init() {
        guard FileManager.default.fileExists(atPath: file.path) else { return }
        do {
            let archive = try JSONDecoder().decode(Archive.self, from: Data(contentsOf: file))
            memories = archive.memories
            occasions = archive.occasions
        } catch {
            loadFailed = true
            errorMessage = "Your saved memories couldn’t be opened. Please restart the app before adding anything."
        }
    }

    @discardableResult
    private func commit(memories: [Memory], occasions: [Occasion]) -> Bool {
        guard !loadFailed else {
            errorMessage = "Your saved file couldn’t be read. Changes are disabled to protect your existing memories."
            return false
        }
        do {
            let data = try JSONEncoder().encode(Archive(memories: memories, occasions: occasions))
            try data.write(to: file, options: [.atomic, .completeFileProtection])
            self.memories = memories
            self.occasions = occasions
            return true
        } catch {
            errorMessage = "We couldn’t save your changes. Please check your device storage and try again."
            return false
        }
    }

    func add(_ memory: Memory) -> Bool { commit(memories: memories + [memory], occasions: occasions) }
    func add(_ occasion: Occasion) -> Bool { commit(memories: memories, occasions: occasions + [occasion]) }
    func delete(_ memory: Memory) { commit(memories: memories.filter { $0.id != memory.id }, occasions: occasions) }
    func delete(_ occasion: Occasion) { commit(memories: memories, occasions: occasions.filter { $0.id != occasion.id }) }
}
