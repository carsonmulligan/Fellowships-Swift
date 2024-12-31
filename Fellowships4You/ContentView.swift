//
//  ContentView.swift
//  Fellowships4You
//
//  Created by Carson Mulligan on 12/31/24.
//

import SwiftUI

struct Scholarship: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let url: String
    let dueDate: String
    let value: Int
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, description, url, dueDate, value, tags
    }
}

struct ScholarshipData: Codable {
    let scholarships: [Scholarship]
}

class ScholarshipStore: ObservableObject {
    @Published var scholarships: [Scholarship] = []
    @Published private(set) var bookmarkedIds: Set<UUID> = []
    
    init() {
        loadScholarships()
        loadBookmarks()
    }
    
    private func loadBookmarks() {
        if let savedBookmarks = UserDefaults.standard.array(forKey: "BookmarkedScholarships") as? [String] {
            bookmarkedIds = Set(savedBookmarks.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func toggleBookmark(for scholarship: Scholarship) {
        var newBookmarks = bookmarkedIds
        if bookmarkedIds.contains(scholarship.id) {
            newBookmarks.remove(scholarship.id)
        } else {
            newBookmarks.insert(scholarship.id)
        }
        bookmarkedIds = newBookmarks
        // Save to UserDefaults
        UserDefaults.standard.set(Array(bookmarkedIds).map { $0.uuidString }, forKey: "BookmarkedScholarships")
    }
    
    func isBookmarked(_ scholarship: Scholarship) -> Bool {
        bookmarkedIds.contains(scholarship.id)
    }
    
    private func loadScholarships() {
        guard let url = Bundle.main.url(forResource: "scholarships", withExtension: "json") else {
            print("Error: Could not find scholarships.json in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let scholarshipData = try decoder.decode(ScholarshipData.self, from: data)
            self.scholarships = scholarshipData.scholarships
        } catch {
            print("Error loading scholarships: \(error)")
            // Load fallback data
            loadFallbackData()
        }
    }
    
    private func loadFallbackData() {
        scholarships = [
            Scholarship(
                name: "🇬🇧 Rhodes Scholarship",
                description: "The Rhodes Scholarships are the oldest and most celebrated international fellowship awards in the world.",
                url: "http://www.rhodesscholar.org/",
                dueDate: "10/01/2025",
                value: 1,
                tags: ["united_kingdom"]
            )
        ]
    }
}

struct ScholarshipDetailView: View {
    let scholarship: Scholarship
    @ObservedObject var store: ScholarshipStore
    @Environment(\.openURL) private var openURL
    
    private var formattedTags: [String] {
        scholarship.tags.compactMap { tag in
            ContentView.availableTags[tag]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(scholarship.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            store.toggleBookmark(for: scholarship)
                        }) {
                            Image(systemName: store.isBookmarked(scholarship) ? "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("Due: \(formatDate(scholarship.dueDate))")
                            .foregroundColor(.blue)
                    }
                }
                
                // Description
                Text(scholarship.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                // Tags
                VStack(alignment: .leading, spacing: 8) {
                    Text("Categories")
                        .font(.headline)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(formattedTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color(.systemGray6))
                                )
                        }
                    }
                }
                
                // Stats
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Facts")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("🌟")
                                .font(.title)
                            Text("Featured")
                                .font(.caption)
                        }
                        
                        VStack {
                            Text("📚")
                                .font(.title)
                            Text("Academic")
                                .font(.caption)
                        }
                        
                        VStack {
                            Text("🎓")
                                .font(.title)
                            Text("Graduate")
                                .font(.caption)
                        }
                    }
                }
                
                // Apply Button
                Button(action: {
                    if let url = URL(string: scholarship.url) {
                        openURL(url)
                    }
                }) {
                    HStack {
                        Text("Apply Now")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let components = dateString.split(separator: "/")
        guard components.count >= 2,
              let month = Int(components[0]),
              let day = Int(components[1]) else {
            return dateString
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(month: month))!
        let monthStr = dateFormatter.string(from: date)
        
        return "\(monthStr). \(day)"
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return rows.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows.rows {
            var x = bounds.minX
            for view in row {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.first?.sizeThatFits(.unspecified).height ?? 0 + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> (rows: [[LayoutSubviews.Element]], size: CGSize) {
        var rows: [[LayoutSubviews.Element]] = [[]]
        var currentRow = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > (proposal.width ?? .infinity) && !rows[currentRow].isEmpty {
                rows.append([])
                currentRow += 1
                x = size.width + spacing
                y += size.height + spacing
            } else {
                x += size.width + spacing
            }
            
            maxWidth = max(maxWidth, x)
            rows[currentRow].append(view)
        }
        
        let height = y + (rows.last?.first?.sizeThatFits(.unspecified).height ?? 0)
        return (rows, CGSize(width: maxWidth - spacing, height: height))
    }
}

struct ScholarshipRow: View {
    let scholarship: Scholarship
    @ObservedObject var store: ScholarshipStore
    
    private func formatDate(_ dateString: String) -> String {
        let components = dateString.split(separator: "/")
        guard components.count >= 2,
              let month = Int(components[0]),
              let day = Int(components[1]) else {
            return dateString
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(month: month))!
        let monthStr = dateFormatter.string(from: date)
        
        return "\(monthStr). \(day)"
    }
    
    var body: some View {
        NavigationLink(destination: ScholarshipDetailView(scholarship: scholarship, store: store)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(scholarship.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("Due: \(formatDate(scholarship.dueDate))")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text(scholarship.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("FEATURED")
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if store.isBookmarked(scholarship) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
}

struct ContentView: View {
    @StateObject private var store = ScholarshipStore()
    @State private var selectedTags: Set<String> = []
    @State private var showFilters = false
    @State private var showBookmarksOnly = false
    
    static let availableTags = [
        "united_kingdom": "🇬🇧 Europe",
        "united_states": "🇺🇸 United States",
        "china": "🇨🇳 China",
        "japan": "🇯🇵 Japan",
        "ireland": "🇮🇪 Ireland",
        "germany": "🇩🇪 Germany",
        "india": "🇮🇳 India",
        "africa": "🌍 Africa",
        "asia": "🌏 Asia",
        "latin_america": "🌎 Latin America",
        "global": "🌐 Global",
        "stem": "🧑‍🔬 STEM",
        "medical": "⚕️ Medical",
        "law": "⚖️ Law",
        "social_justice": "🗽 Social Justice",
        "peace_studies": "✌️ Peace Studies",
        "security_studies": "🛡 Security Studies",
        "financial": "💰 Financial",
        "food_security": "🥖 Food Security",
        "music": "🎵 Music",
        "language": "🗣 Language"
    ]
    
    var filteredScholarships: [Scholarship] {
        var scholarships = store.scholarships
        
        if showBookmarksOnly {
            scholarships = scholarships.filter { store.isBookmarked($0) }
        }
        
        if selectedTags.isEmpty {
            return scholarships
        }
        
        return scholarships.filter { scholarship in
            !Set(scholarship.tags).isDisjoint(with: selectedTags)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        // Filter Button
                        Button(action: { showFilters.toggle() }) {
                            HStack {
                                Text("Filters")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                        }
                        
                        // Bookmarks Toggle
                        Button(action: { showBookmarksOnly.toggle() }) {
                            Image(systemName: showBookmarksOnly ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    // Selected Filters
                    if !selectedTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedTags), id: \.self) { tag in
                                    HStack {
                                        Text(Self.availableTags[tag] ?? tag)
                                            .font(.caption)
                                        Button(action: {
                                            selectedTags.remove(tag)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray6))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                    
                    // Scholarships List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredScholarships) { scholarship in
                                ScholarshipRow(scholarship: scholarship, store: store)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Scholarships")
            .sheet(isPresented: $showFilters) {
                FilterView(selectedTags: $selectedTags, availableTags: Self.availableTags)
            }
        }
    }
}

struct FilterView: View {
    @Binding var selectedTags: Set<String>
    let availableTags: [String: String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(availableTags.keys.sorted()), id: \.self) { tag in
                    Button(action: {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }) {
                        HStack {
                            Text(availableTags[tag] ?? tag)
                            Spacer()
                            if selectedTags.contains(tag) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Filters")
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
