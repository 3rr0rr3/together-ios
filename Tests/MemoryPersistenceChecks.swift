import Foundation

@main
struct MemoryPersistenceChecks {
    @MainActor
    static func main() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("test.json")
        let id = UUID()
        let first = Data([1, 2, 3, 4])
        let second = Data([5, 6, 7, 8])
        let legacy: [String: Any] = [
            "memories": [["id": id.uuidString, "title": "Our first day", "note": "Keep this",
                           "date": 1000, "photo": first.base64EncodedString()]],
            "occasions": []
        ]
        try JSONSerialization.data(withJSONObject: legacy).write(to: file)
        let store = MemoryStore(file: file)
        precondition(store.errorMessage == nil)
        precondition(store.memories.count == 1)
        precondition(store.memories[0].photos == [first], "Legacy photo must survive migration")
        var updated = store.memories[0]
        updated.photos.append(second)
        precondition(store.save(updated))
        let reloaded = MemoryStore(file: file)
        precondition(reloaded.memories.count == 1, "Editing must not duplicate a memory")
        precondition(reloaded.memories[0].id == id)
        precondition(reloaded.memories[0].photos == [first, second], "Photo order and bytes must persist")
        precondition(reloaded.memories[0].note == "Keep this")
        updated.photos.removeFirst()
        precondition(reloaded.save(updated))
        precondition(MemoryStore(file: file).memories[0].photos == [second], "Photo removal must persist")
        updated.photos = []
        precondition(reloaded.save(updated))
        precondition(MemoryStore(file: file).memories[0].photos.isEmpty)
        precondition(reloaded.delete(updated))
        precondition(MemoryStore(file: file).memories.isEmpty)
        let corrupt = Data("broken archive".utf8)
        try corrupt.write(to: file)
        let protected = MemoryStore(file: file)
        precondition(protected.errorMessage != nil)
        precondition(!protected.save(updated))
        let remaining = try Data(contentsOf: file)
        precondition(remaining == corrupt, "Do not overwrite an unreadable archive")
        print("PASS: legacy migration, multi-photo persistence, order, edit, remove, delete, corrupt-file protection")
    }
}
