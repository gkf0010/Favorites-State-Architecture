// ContentView.swift : Favorites
// Copyright © 2025 Auburn University. All Rights Reserved.
import SwiftUI

private enum FavoritesStyle {
    static let accent = Color(red: 0.40, green: 0.35, blue: 0.73)
    static let backdrop = Color(uiColor: .systemGroupedBackground)
}

struct ContentView: View {
    @StateObject private var favorites = FavoritesViewModel()

    var body: some View {
        TabView {
            NavigationStack { HomeView(viewModel: favorites) }
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { SavedFavoritesView(viewModel: favorites) }
                .tabItem { Label("Favorites", systemImage: "heart.fill") }
            NavigationStack { SettingsView(viewModel: favorites) }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(FavoritesStyle.accent)
    }
}

private enum BrowseCategory: String, CaseIterable, Identifiable {
    case cities = "Cities", hobbies = "Hobbies", books = "Books"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .cities: return "building.2.crop.circle"
        case .hobbies: return "paintpalette"
        case .books: return "books.vertical"
        }
    }
}

private struct HomeView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @State private var category: BrowseCategory = .cities
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Find something to love")
                        .font(.title2.bold())
                    Text("Browse collections and tap a heart to save your favorites.")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 12)

                HStack(spacing: 8) {
                    ForEach(BrowseCategory.allCases) { item in
                        Button {
                            category = item
                            searchText = ""
                        } label: {
                            Label(item.rawValue, systemImage: item.icon)
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(category == item ? FavoritesStyle.accent : Color(uiColor: .secondarySystemGroupedBackground))
                                .foregroundStyle(category == item ? Color.white : Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(category == item ? .isSelected : [])
                    }
                }

                HStack {
                    Text(category.rawValue).font(.title3.bold())
                    Spacer()
                    Text("\(visibleCount) items")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                switch category {
                case .cities:
                    ForEach(filteredCities) { city in
                        CityCard(city: city, viewModel: viewModel)
                    }
                case .hobbies:
                    LazyVStack(spacing: 10) {
                        ForEach(filteredHobbies) { hobby in
                            HobbyRow(hobby: hobby, viewModel: viewModel)
                        }
                    }
                case .books:
                    LazyVStack(spacing: 10) {
                        ForEach(filteredBooks) { book in
                            BookRow(book: book, viewModel: viewModel)
                        }
                    }
                }

                if visibleCount == 0 {
                    ContentUnavailableView.search(text: searchText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .background(FavoritesStyle.backdrop)
        .navigationTitle("Explore")
        .searchable(text: $searchText, prompt: "Search \(category.rawValue.lowercased())")
    }

    private var filteredCities: [CityModel] {
        viewModel.cities.filter { searchText.isEmpty || $0.cityName.localizedCaseInsensitiveContains(searchText) }
    }
    private var filteredHobbies: [HobbyModel] {
        viewModel.hobbies.filter { searchText.isEmpty || $0.hobbyName.localizedCaseInsensitiveContains(searchText) }
    }
    private var filteredBooks: [BookModel] {
        viewModel.books.filter {
            searchText.isEmpty || $0.bookTitle.localizedCaseInsensitiveContains(searchText)
            || $0.bookAuthor.localizedCaseInsensitiveContains(searchText)
        }
    }
    private var visibleCount: Int {
        switch category {
        case .cities: filteredCities.count
        case .hobbies: filteredHobbies.count
        case .books: filteredBooks.count
        }
    }
}

private struct FavoriteHeart: View {
    let key: String
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { viewModel.toggleFavorite(key) }
        } label: {
            Image(systemName: viewModel.isFavorite(key) ? "heart.fill" : "heart")
                .font(.title3.weight(.semibold))
                .foregroundStyle(viewModel.isFavorite(key) ? Color.pink : FavoritesStyle.accent)
                .frame(width: 44, height: 44)
                .background(Color(uiColor: .tertiarySystemGroupedBackground).opacity(0.95))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.isFavorite(key) ? "Remove from favorites" : "Add to favorites")
    }
}

private struct CityCard: View {
    let city: CityModel
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                Image(city.cityImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            Text(city.cityName)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(18)
            VStack {
                HStack {
                    Spacer()
                    FavoriteHeart(key: city.favoriteKey, viewModel: viewModel)
                }
                Spacer()
            }
            .padding(12)
        }
        .frame(height: 188)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .contain)
    }
}

private struct HobbyRow: View {
    let hobby: HobbyModel
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        HStack(spacing: 14) {
            Text(hobby.hobbyIcon)
                .font(.largeTitle)
                .frame(width: 54, height: 54)
                .background(FavoritesStyle.accent.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 13))
            Text(hobby.hobbyName).font(.headline)
            Spacer(minLength: 4)
            FavoriteHeart(key: hobby.favoriteKey, viewModel: viewModel)
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }
}

private struct BookRow: View {
    let book: BookModel
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "book.closed.fill")
                .font(.title2)
                .foregroundStyle(FavoritesStyle.accent)
                .frame(width: 54, height: 54)
                .background(FavoritesStyle.accent.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 4) {
                Text(book.bookTitle).font(.headline)
                Text(book.bookAuthor).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            FavoriteHeart(key: book.favoriteKey, viewModel: viewModel)
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }
}

private struct SavedFavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        ScrollView {
            if viewModel.favoriteCount == 0 {
                ContentUnavailableView("No favorites yet", systemImage: "heart", description: Text("Visit Explore and tap a heart to save a city, hobby, or book."))
                    .padding(.top, 90)
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    Text("\(viewModel.favoriteCount) saved items")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                    if !viewModel.favoriteCities.isEmpty {
                        sectionHeading("Cities", symbol: "building.2")
                        ForEach(viewModel.favoriteCities) { city in
                            CityCard(city: city, viewModel: viewModel)
                        }
                    }
                    if !viewModel.favoriteHobbies.isEmpty {
                        sectionHeading("Hobbies", symbol: "paintpalette")
                        ForEach(viewModel.favoriteHobbies) { hobby in
                            HobbyRow(hobby: hobby, viewModel: viewModel)
                        }
                    }
                    if !viewModel.favoriteBooks.isEmpty {
                        sectionHeading("Books", symbol: "books.vertical")
                        ForEach(viewModel.favoriteBooks) { book in
                            BookRow(book: book, viewModel: viewModel)
                        }
                    }
                }
                .padding(18)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FavoritesStyle.backdrop)
        .navigationTitle("Favorites")
    }

    private func sectionHeading(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.title3.bold())
            .padding(.top, 12)
    }
}

private struct SettingsView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @AppStorage("preferredTheme") private var preferredTheme = "system"
    @State private var showingClearConfirmation = false

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $preferredTheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.menu)
                Text("Your appearance preference is saved on this device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Label("Theme", systemImage: "paintbrush")
            }

            Section {
                HStack {
                    Label("Saved favorites", systemImage: "heart")
                    Spacer()
                    Text("\(viewModel.favoriteCount)").foregroundStyle(.secondary)
                }
                Button(role: .destructive) {
                    showingClearConfirmation = true
                } label: {
                    Label("Clear All Favorites", systemImage: "trash")
                }
                .disabled(viewModel.favoriteCount == 0)
            } header: {
                Label("Your collection", systemImage: "square.stack")
            } footer: {
                Text("Clearing favorites removes saved cities, hobbies, and books. It does not change your appearance setting.")
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Remove all saved favorites?", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
            Button("Clear All Favorites", role: .destructive) {
                withAnimation { viewModel.clearFavorites() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This cannot be undone.")
        }
    }
}

#Preview {
    ContentView()
}
