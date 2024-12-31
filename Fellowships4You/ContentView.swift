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
    
    init() {
        loadScholarships()
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

struct ContentView: View {
    @StateObject private var store = ScholarshipStore()
    @State private var selectedTags: Set<String> = []
    @State private var showFilters = false
    
    let availableTags = [
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
        if selectedTags.isEmpty {
            return store.scholarships
        }
        return store.scholarships.filter { scholarship in
            !Set(scholarship.tags).isDisjoint(with: selectedTags)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                        .padding()
                    }
                    
                    // Selected Filters
                    if !selectedTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedTags), id: \.self) { tag in
                                    HStack {
                                        Text(availableTags[tag] ?? tag)
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
                                ScholarshipRow(scholarship: scholarship)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Scholarships")
            .sheet(isPresented: $showFilters) {
                FilterView(selectedTags: $selectedTags, availableTags: availableTags)
            }
        }
    }
}

struct ScholarshipRow: View {
    let scholarship: Scholarship
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(scholarship.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("Due: \(scholarship.dueDate)")
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
                
                Link(destination: URL(string: scholarship.url)!) {
                    Text("Learn More")
                        .font(.caption)
                        .fontWeight(.medium)
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
