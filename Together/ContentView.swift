import SwiftUI
import PhotosUI

private let rose = Color(red: 0.67, green: 0.27, blue: 0.36)
private let cream = Color(red: 0.99, green: 0.96, blue: 0.93)

struct ContentView: View {
    @EnvironmentObject private var store: MemoryStore
    @State private var addingMemory = false
    @State private var addingDate = false
    @State private var selectedMemory: Memory?

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("OUR LITTLE TIME CAPSULE").font(.caption.weight(.semibold)).tracking(2).foregroundStyle(rose)
                            Text("The moments that\nmake us, us.").font(.system(.largeTitle, design: .serif).weight(.medium))
                            Text("Keep your favorite pieces of life together.").foregroundStyle(.secondary)
                        }.padding(.top)
                        if store.memories.isEmpty {
                            emptyState("Your story starts here", subtitle: "Add a photo, a few words, and a day worth remembering.", icon: "heart.text.clipboard")
                        }
                        ForEach(store.memories.sorted { $0.date > $1.date }) { memory in
                            Button { selectedMemory = memory } label: {
                                VStack(alignment: .leading, spacing: 12) {
                                    memoryImage(memory).frame(height: 230).clipped()
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(memory.title).font(.title3.weight(.semibold))
                                        Text(memory.date.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundStyle(.secondary)
                                        if !memory.note.isEmpty { Text(memory.note).font(.subheadline).lineLimit(2) }
                                    }.padding([.horizontal, .bottom])
                                }.background(.white).clipShape(RoundedRectangle(cornerRadius: 22))
                            }.buttonStyle(.plain)
                        }
                        Button { addingMemory = true } label: {
                            Label("Add a memory", systemImage: "plus").frame(maxWidth: .infinity).padding(8)
                        }.buttonStyle(.borderedProminent)
                    }.padding(20)
                }.background(cream).navigationTitle("Together")
                    .toolbar { Button("Add", systemImage: "plus") { addingMemory = true } }
            }.tabItem { Label("Memories", systemImage: "heart.fill") }

            NavigationStack {
                List {
                    if store.occasions.isEmpty {
                        emptyState("Days close to your heart", subtitle: "Save your anniversary, first date, and every milestone in between.", icon: "calendar.badge.heart").listRowBackground(Color.clear)
                    }
                    ForEach(store.occasions.sorted { $0.nextDate < $1.nextDate }) { occasion in
                        HStack(spacing: 16) {
                            Image(systemName: "heart.circle.fill").font(.largeTitle).foregroundStyle(rose)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(occasion.title).font(.headline)
                                Text(occasion.nextDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                                if occasion.repeatsYearly { Text("Every year").font(.caption).foregroundStyle(rose) }
                            }
                            Spacer()
                            Text(dayLabel(occasion.nextDate)).font(.caption.weight(.semibold)).foregroundStyle(rose).multilineTextAlignment(.trailing)
                        }.padding(.vertical, 8)
                            .swipeActions { Button("Delete", role: .destructive) { store.delete(occasion) } }
                    }
                }.scrollContentBackground(.hidden).background(cream).navigationTitle("Special dates")
                    .toolbar { Button("Add", systemImage: "plus") { addingDate = true } }
            }.tabItem { Label("Dates", systemImage: "calendar") }
        }.tint(rose)
            .sheet(isPresented: $addingMemory) { MemoryEditor() }
            .sheet(isPresented: $addingDate) { OccasionEditor() }
            .sheet(item: $selectedMemory) { memory in MemoryDetail(memory: memory) }
            .alert("Something went wrong", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
                Button("OK") { store.errorMessage = nil }
            } message: { Text(store.errorMessage ?? "") }
    }

    private func dayLabel(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: date)).day ?? 0
        if days == 0 { return "Today ♥" }
        return days > 0 ? "In \(days) days" : "\(-days) days ago"
    }
}

private func emptyState(_ title: String, subtitle: String, icon: String) -> some View {
    VStack(spacing: 14) {
        Image(systemName: icon).font(.system(size: 40)).foregroundStyle(rose)
        Text(title).font(.title3.weight(.semibold))
        Text(subtitle).foregroundStyle(.secondary).multilineTextAlignment(.center)
    }.frame(maxWidth: .infinity).padding(.vertical, 40)
}

private func memoryImage(_ memory: Memory) -> some View {
    Group {
        if let data = memory.photo, let image = UIImage(data: data) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            ZStack { rose.opacity(0.10); Image(systemName: "heart").font(.system(size: 48)).foregroundStyle(rose) }
        }
    }
}

private struct MemoryDetail: View {
    @EnvironmentObject private var store: MemoryStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingDelete = false
    let memory: Memory

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let data = memory.photo, let image = UIImage(data: data) {
                        Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    Text(memory.title).font(.system(.largeTitle, design: .serif))
                    Text(memory.date.formatted(date: .long, time: .omitted)).foregroundStyle(.secondary)
                    Text(memory.note)
                }.padding()
            }.background(cream).toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .primaryAction) { Button("Delete", systemImage: "trash", role: .destructive) { confirmingDelete = true } }
            }.confirmationDialog("Delete this memory?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Delete memory", role: .destructive) { store.delete(memory); dismiss() }
            }
        }
    }
}

private struct MemoryEditor: View {
    @EnvironmentObject private var store: MemoryStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var selection: PhotosPickerItem?
    @State private var photo: Data?
    @State private var loading = false
    @State private var photoError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selection, matching: .images) {
                        Label(photo == nil ? "Choose a photo" : "Change photo", systemImage: "photo.badge.plus")
                    }
                    if loading { ProgressView("Loading photo…") }
                    if let photo, let image = UIImage(data: photo) {
                        Image(uiImage: image).resizable().scaledToFit().frame(maxHeight: 240)
                    }
                    if let photoError { Text(photoError).foregroundStyle(.red) }
                }
                Section("The moment") {
                    TextField("A name for this memory", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("What made it special?", text: $note, axis: .vertical).lineLimit(4...8)
                }
            }.navigationTitle("New memory").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if store.add(Memory(title: title.trimmingCharacters(in: .whitespacesAndNewlines), note: note, date: date, photo: photo)) { dismiss() }
                        }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || loading)
                    }
                }
                .task(id: selection) {
                    guard let selection else { return }
                    loading = true
                    photoError = nil
                    do {
                        guard let data = try await selection.loadTransferable(type: Data.self), let image = UIImage(data: data) else {
                            throw CocoaError(.fileReadCorruptFile)
                        }
                        try Task.checkCancellation()
                        let scale = min(1, 1600 / max(image.size.width, image.size.height))
                        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                        let format = UIGraphicsImageRendererFormat()
                        format.scale = 1
                        photo = UIGraphicsImageRenderer(size: size, format: format).image { _ in image.draw(in: CGRect(origin: .zero, size: size)) }.jpegData(compressionQuality: 0.85)
                    } catch is CancellationError { return }
                    catch { photoError = "This photo couldn’t be loaded. Please choose another." }
                    loading = false
                }
        }
    }
}

private struct OccasionEditor: View {
    @EnvironmentObject private var store: MemoryStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date = Date()
    @State private var repeats = true

    var body: some View {
        NavigationStack {
            Form {
                TextField("Anniversary, first date…", text: $title)
                DatePicker("Special day", selection: $date, displayedComponents: .date)
                Toggle("Celebrate every year", isOn: $repeats)
            }.navigationTitle("New special date").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if store.add(Occasion(title: title.trimmingCharacters(in: .whitespacesAndNewlines), date: date, repeatsYearly: repeats)) { dismiss() }
                        }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
        }
    }
}
