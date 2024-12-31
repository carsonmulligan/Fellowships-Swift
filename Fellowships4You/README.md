# Fellowships4You iOS App

A modern iOS application that helps students discover and track fellowship opportunities worldwide. Built with SwiftUI, this app provides an intuitive interface for browsing, filtering, and bookmarking scholarships and fellowships.

## Features

- 🔍 Browse through 60+ prestigious fellowships and scholarships
- 🏷️ Filter opportunities by region (e.g., UK, US, Global) and field (e.g., STEM, Law, Medicine)
- 🔖 Bookmark favorite opportunities for later reference
- 📱 Clean, modern iOS interface built with SwiftUI
- 📅 View application deadlines in a user-friendly format
- 🌍 International opportunities across multiple regions and disciplines

## Getting Started

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- macOS Monterey or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Fellowships4You.git
cd Fellowships4You
```

2. Open the project in Xcode:
```bash
open Fellowships4You.xcodeproj
```

3. Build and run the project (⌘+R)

## Data Structure

The app uses a JSON data structure for scholarships with the following fields:
- name: Name of the fellowship/scholarship
- description: Detailed description
- url: Application website
- dueDate: Application deadline
- value: Scholarship value indicator
- tags: Array of categories (e.g., ["united_states", "stem", "medical"])

## Features in Detail

### Scholarship List View
- Main view displaying all available scholarships
- Each scholarship card shows:
  - Title with relevant emojis
  - Brief description
  - Due date
  - Quick bookmark toggle

### Detail View
- Comprehensive information about each scholarship
- Direct link to application website
- Bookmark management
- Tag display

### Filtering System
- Filter by geographic regions:
  - 🇬🇧 United Kingdom
  - 🇺🇸 United States
  - 🇨🇳 China
  - 🌍 Africa
  - 🌏 Asia
  - 🌎 Latin America
  - 🌐 Global
  - And more...

- Filter by fields:
  - 🧑‍🔬 STEM
  - ⚕️ Medical
  - ⚖️ Law
  - 🗽 Social Justice
  - ✌️ Peace Studies
  - 💰 Financial
  - 🎵 Music
  - 🗣 Language
  - And more...

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with SwiftUI
- Uses UserDefaults for bookmark persistence
- Scholarship data curated from various fellowship programs worldwide 