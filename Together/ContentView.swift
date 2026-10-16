import SwiftUI
import PhotosUI

private let rose = Color(red: 0.57, green: 0.18, blue: 0.30)
private let blush = Color(red: 0.98, green: 0.87, blue: 0.87)
private let cream = Color(red: 1, green: 0.97, blue: 0.94)
private let ink = Color(red: 0.25, green: 0.13, blue: 0.17)

private struct LoveBackground: View {
    var body: some View {
        LinearGradient(colors: [cream, blush.opacity(0.65), cream], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

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
                        VStack(alignment: .leading, spacing: 14) {
                            Label("A LOVE STORY, STILL UNFOLDING", systemImage: "heart.fill")
                                .font(.caption2.weight(.semibold)).tracking(1.5).foregroundStyle(rose)
                            Text("Every little moment.\nAlways, us.")
                                .font(.system(.largeTitle, design: .serif).weight(.medium)).foregroundStyle(ink)
                            Text("A place for the days we never want to forget.")
                                .font(.subheadline).foregroundStyle(ink.opacity(0.75))
                            HStack(spacing: 8) {
                                Image(systemName: "heart")
                                Text("\(store.memories.count) memories tucked away")
                            }.font(.caption).foregroundStyle(rose)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(24)
                            .background(.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 28))
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "heart.fill").font(.system(size: 44))
                                    .foregroundStyle(rose.opacity(0.08)).rotationEffect(.degrees(18)).padding(18)
                                    .accessibilityHidden(true)
                            }
                        if store.memories.isEmpty {
                            emptyState("Your story starts here", subtitle: "The first adventure. A quiet Sunday. A thousand little reasons to love.", icon: "heart.text.clipboard")
                        }
                        ForEach(store.memories.sorted { $0.date > $1.date }) { memory in
                            Button { selectedMemory = memory } label: {
                                VStack(alignment: .leading, spacing: 14) {
                                    GeometryReader { geometry in
                                        memoryImage(memory).frame(width: geometry.size.width, height: 230).clipped()
                                    }.frame(height: 230).clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(alignment: .bottomTrailing) {
                                            if !memory.photos.isEmpty {
                                                Label("\(memory.photos.count)", systemImage: "photo.on.rectangle")
                                                    .font(.caption.weight(.semibold)).padding(8)
                                                    .background(.white, in: Capsule()).padding(12).foregroundStyle(rose)
                                            }
                                        }
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(memory.title).font(.system(.title2, design: .serif)).foregroundStyle(ink)
                                        Label(memory.date.formatted(date: .abbreviated, time: .omitted), systemImage: "heart")
                                            .font(.caption).foregroundStyle(rose)
                                        if !memory.note.isEmpty {
                                            Text(memory.note).font(.subheadline).foregroundStyle(ink.opacity(0.75)).lineLimit(2)
                                        }
                                    }.padding(.horizontal, 8).padding(.bottom, 10)
                                }.padding(12).background(.white, in: RoundedRectangle(cornerRadius: 22))
                                    .shadow(color: rose.opacity(0.08), radius: 12, y: 5)
                            }.buttonStyle(.plain)
                        }
                        Button { addingMemory = true } label: {
                            Label("Add a memory", systemImage: "heart.badge.plus").frame(maxWidth: .infinity).padding(10)
                        }.buttonStyle(.borderedProminent).clipShape(Capsule())
                        Text("Made of little moments. Kept with love.")
                            .font(.system(.footnote, design: .serif)).italic().foregroundStyle(rose)
                            .frame(maxWidth: .infinity).padding(.bottom)
                    }.padding(20)
                }.background(LoveBackground()).navigationTitle("Together")
                    .toolbar { Button("Add", systemImage: "plus") { addingMemory = true } }
            }.tabItem { Label("Memories", systemImage: "heart.fill") }

            NavigationStack {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Some days belong to us.")
                                .font(.system(.title2, design: .serif)).foregroundStyle(ink)
                            Text("Firsts, forever promises, and reasons to celebrate.")
                                .font(.subheadline).foregroundStyle(rose)
                        }.padding(.vertical, 12)
                    }.listRowBackground(Color.clear)
                    if store.occasions.isEmpty {
                        emptyState("Days close to your heart", subtitle: "Save your anniversary, first date, and every milestone in between.", icon: "calendar.badge.heart")
                            .listRowBackground(Color.clear)
                    }
                    ForEach(store.occasions.sorted { $0.nextDate < $1.nextDate }) { occasion in
                        HStack(spacing: 16) {
                            Image(systemName: "heart.fill").font(.title2).foregroundStyle(rose)
                                .frame(width: 48, height: 48).background(blush, in: RoundedRectangle(cornerRadius: 16))
                            VStack(alignment: .leading, spacing: 5) {
                                Text(occasion.title).font(.system(.headline, design: .serif)).foregroundStyle(ink)
                                Text(occasion.nextDate.formatted(date: .abbreviated, time: .omitted)).font(.subheadline).foregroundStyle(.secondary)
                                if occasion.repeatsYearly { Text("Every year").font(.caption).foregroundStyle(rose) }
                            }
                            Spacer()
                            Text(dayLabel(occasion.nextDate)).font(.caption.weight(.semibold)).foregroundStyle(rose).multilineTextAlignment(.trailing)
                        }.padding(.vertical, 10).listRowBackground(Color.white)
                            .swipeActions { Button("Delete", role: .destructive) { store.delete(occasion) } }
                    }
                }.scrollContentBackground(.hidden).background(LoveBackground()).navigationTitle("Special dates")
                    .toolbar { Button("Add", systemImage: "plus") { addingDate = true } }
            }.tabItem { Label("Dates", systemImage: "calendar") }
        }.tint(rose)
            .sheet(isPresented: $addingMemory) { MemoryEditor() }
            .sheet(isPresented: $addingDate) { OccasionEditor() }
            .sheet(item: $selectedMemory) { memory in MemoryDetail(original: memory) }
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
        Text(title).font(.system(.title3, design: .serif)).foregroundStyle(ink)
        Text(subtitle).foregroundStyle(ink.opacity(0.7)).multilineTextAlignment(.center)
    }.frame(maxWidth: .infinity).padding(.vertical, 32)
}

private func memoryImage(_ memory: Memory) -> some View {
    Group {
        if let data = memory.photos.first, let image = UIImage(data: data) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            ZStack {
                LinearGradient(colors: [blush, cream], startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "heart.fill").font(.system(size: 52)).foregroundStyle(rose.opacity(0.5))
            }
        }
    }
}

private struct MemoryDetail: View {
    @EnvironmentObject private var store: MemoryStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingDelete = false
    @State private var editing = false
    @State private var photoIndex = 0
    let original: Memory
    private var memory: Memory { store.memories.first { $0.id == original.id } ?? original }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !memory.photos.isEmpty {
                        TabView(selection: $photoIndex) {
                            ForEach(memory.photos.indices, id: \.self) { index in
                                if let image = UIImage(data: memory.photos[index]) {
                                    Image(uiImage: image).resizable().scaledToFit().tag(index)
                                        .accessibilityLabel("Photo \(index + 1) of \(memory.photos.count)")
                                }
                            }
                        }.tabViewStyle(.page(indexDisplayMode: .never)).frame(height: 340)
                            .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
                        HStack {
                            Button { photoIndex = max(0, photoIndex - 1) } label: { Image(systemName: "chevron.left") }
                                .disabled(photoIndex == 0).accessibilityLabel("Previous photo")
                            Spacer()
                            Text("\(min(photoIndex + 1, memory.photos.count)) of \(memory.photos.count) photos")
                                .font(.caption).foregroundStyle(rose).accessibilityIdentifier("photoCount")
                            Spacer()
                            Button { photoIndex = min(memory.photos.count - 1, photoIndex + 1) } label: { Image(systemName: "chevron.right") }
                                .disabled(photoIndex >= memory.photos.count - 1).accessibilityLabel("Next photo")
                        }
                    }
                    Label("A LITTLE PIECE OF US", systemImage: "heart.fill").font(.caption2).tracking(2).foregroundStyle(rose)
                    Text(memory.title).font(.system(.largeTitle, design: .serif)).foregroundStyle(ink)
                    Text(memory.date.formatted(date: .long, time: .omitted)).foregroundStyle(rose)
                    Text(memory.note).foregroundStyle(ink).lineSpacing(6)
                }.padding(24)
            }.background(LoveBackground()).toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Edit") { editing = true }
                    Button("Delete", systemImage: "trash", role: .destructive) { confirmingDelete = true }
                }
            }.confirmationDialog("Delete this memory?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("Delete memory", role: .destructive) { if store.delete(memory) { dismiss() } }
            }.sheet(isPresented: $editing, onDismiss: { photoIndex = 0 }) { MemoryEditor(memory: memory) }
        }
    }
}

private struct DraftPhoto: Identifiable {
    var id = UUID()
    var data: Data
}

private struct MemoryEditor: View {
    @EnvironmentObject private var store: MemoryStore
    @Environment(\.dismiss) private var dismiss
    private let memoryID: UUID
    private let isEditing: Bool
    @State private var title: String
    @State private var note: String
    @State private var date: Date
    @State private var selection: [PhotosPickerItem] = []
    @State private var photos: [DraftPhoto]
    @State private var loading = false
    @State private var photoError: String?
    @State private var saveError: String?

    init(memory: Memory? = nil) {
        memoryID = memory?.id ?? UUID()
        isEditing = memory != nil
        _title = State(initialValue: memory?.title ?? "")
        _note = State(initialValue: memory?.note ?? "")
        _date = State(initialValue: memory?.date ?? Date())
        _photos = State(initialValue: (memory?.photos ?? []).map { DraftPhoto(data: $0) })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if photos.count < 20 {
                        PhotosPicker(selection: $selection, maxSelectionCount: 20 - photos.count, selectionBehavior: .ordered, matching: .images) {
                            Label(photos.isEmpty ? "Choose photos" : "Add more photos", systemImage: "photo.badge.plus")
                        }.disabled(loading).accessibilityIdentifier("choosePhotos")
                    }
                    Text("\(photos.count) of 20 photos • The first photo is your cover.")
                        .font(.caption).foregroundStyle(rose)
                    if loading { ProgressView("Gathering your moments…") }
                    if !photos.isEmpty {
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(photos) { photo in
                                    VStack(spacing: 8) {
                                        if let image = UIImage(data: photo.data) {
                                            Image(uiImage: image).resizable().scaledToFill()
                                                .frame(width: 104, height: 104).clipped().clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        Button(role: .destructive) { photos.removeAll { $0.id == photo.id } } label: {
                                            Label("Remove", systemImage: "xmark.circle.fill").font(.caption)
                                        }.buttonStyle(.borderless).disabled(loading)
                                    }
                                }
                            }.padding(.vertical, 6)
                        }
                    }
                    if let photoError { Text(photoError).foregroundStyle(.red).font(.caption) }
                } header: { Text("Our little collection") }
                Section("The moment") {
                    TextField("A name for this memory", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("What made it special?", text: $note, axis: .vertical).lineLimit(4...8)
                }
                if let saveError { Section { Text(saveError).foregroundStyle(.red) } }
            }.scrollContentBackground(.hidden).background(LoveBackground())
                .navigationTitle(isEditing ? "Edit memory" : "New memory").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let memory = Memory(id: memoryID, title: title.trimmingCharacters(in: .whitespacesAndNewlines), note: note, date: date, photos: photos.map(\.data))
                            if store.save(memory) { dismiss() }
                            else { saveError = store.errorMessage }
                        }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || loading || !selection.isEmpty)
                    }
                }
                .task(id: selection) {
                    guard !selection.isEmpty else { return }
                    let batch = selection
                    loading = true
                    photoError = nil
                    var imported: [DraftPhoto] = []
                    var failures = 0
                    for item in batch {
                        do {
                            guard let data = try await item.loadTransferable(type: Data.self),
                                  let image = UIImage(data: data) else { throw CocoaError(.fileReadCorruptFile) }
                            try Task.checkCancellation()
                            let scale = min(1, 1600 / max(image.size.width, image.size.height))
                            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                            let format = UIGraphicsImageRendererFormat()
                            format.scale = 1
                            guard let compressed = UIGraphicsImageRenderer(size: size, format: format)
                                .image(actions: { _ in image.draw(in: CGRect(origin: .zero, size: size)) })
                                .jpegData(compressionQuality: 0.85) else { throw CocoaError(.fileReadCorruptFile) }
                            imported.append(DraftPhoto(data: compressed))
                        } catch is CancellationError { return }
                        catch { failures += 1 }
                    }
                    guard !Task.isCancelled else { return }
                    photos.append(contentsOf: imported.prefix(max(0, 20 - photos.count)))
                    if failures > 0 { photoError = "\(failures) photos could not be loaded. You can select them again to retry." }
                    loading = false
                    selection = []
                }
        }.tint(rose)
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
                Section {
                    TextField("Anniversary, first date…", text: $title)
                    DatePicker("Special day", selection: $date, displayedComponents: .date)
                    Toggle("Celebrate every year", isOn: $repeats)
                } header: { Text("A date written in our hearts") }
            }.scrollContentBackground(.hidden).background(LoveBackground())
                .navigationTitle("New special date").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if store.add(Occasion(title: title.trimmingCharacters(in: .whitespacesAndNewlines), date: date, repeatsYearly: repeats)) { dismiss() }
                        }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
        }.tint(rose)
    }
}
