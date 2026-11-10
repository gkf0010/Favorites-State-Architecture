// FavoritesViewModel.swift : Favorites
// Shared state for the Home and Favorites tabs.
import Foundation
import SwiftUI

struct CityModel: Identifiable {
    let id: Int
    let cityName: String
    let cityImage: String
    var favoriteKey: String { "city-\(id)" }
}

struct HobbyModel: Identifiable {
    let id: Int
    let hobbyName: String
    let hobbyIcon: String
    var favoriteKey: String { "hobby-\(id)" }
}

struct BookModel: Identifiable {
    let id: Int
    let bookTitle: String
    let bookAuthor: String
    var favoriteKey: String { "book-\(id)" }
}

final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favoriteKeys: Set<String> = []
    private let storageKey = "savedFavoriteKeys"

    let cities: [CityModel] = [
        .init(id: 1, cityName: "Cape Town", cityImage: "capetown"),
        .init(id: 2, cityName: "Copenhagen", cityImage: "copenhagen"),
        .init(id: 3, cityName: "Lisbon", cityImage: "lisbon"),
        .init(id: 4, cityName: "Reykjavik", cityImage: "reykjavik"),
        .init(id: 5, cityName: "Warsaw", cityImage: "warsaw"),
        .init(id: 6, cityName: "London", cityImage: "london"),
        .init(id: 7, cityName: "Monaco", cityImage: "monaco"),
        .init(id: 8, cityName: "Amsterdam", cityImage: "amsterdam"),
        .init(id: 9, cityName: "Los Angeles", cityImage: "losangeles")
    ]

    let hobbies: [HobbyModel] = [
        .init(id: 1, hobbyName: "Painting", hobbyIcon: "🎨"),
        .init(id: 2, hobbyName: "Photography", hobbyIcon: "📷"),
        .init(id: 3, hobbyName: "Guitar", hobbyIcon: "🎸"),
        .init(id: 4, hobbyName: "Yoga", hobbyIcon: "🧘‍♀️"),
        .init(id: 5, hobbyName: "Gardening", hobbyIcon: "🪴"),
        .init(id: 6, hobbyName: "Cooking", hobbyIcon: "🍳"),
        .init(id: 7, hobbyName: "Hiking", hobbyIcon: "🥾"),
        .init(id: 8, hobbyName: "Writing", hobbyIcon: "✍️"),
        .init(id: 9, hobbyName: "Dancing", hobbyIcon: "💃"),
        .init(id: 10, hobbyName: "Knitting", hobbyIcon: "🧶"),
        .init(id: 11, hobbyName: "Gaming", hobbyIcon: "🎮"),
        .init(id: 12, hobbyName: "Calligraphy", hobbyIcon: "✒️")
    ]

    let books: [BookModel] = [
        .init(id: 1, bookTitle: "To Kill a Mockingbird", bookAuthor: "Harper Lee"),
        .init(id: 2, bookTitle: "1984", bookAuthor: "George Orwell"),
        .init(id: 3, bookTitle: "Pride and Prejudice", bookAuthor: "Jane Austen"),
        .init(id: 4, bookTitle: "The Great Gatsby", bookAuthor: "F. Scott Fitzgerald"),
        .init(id: 5, bookTitle: "The Catcher in the Rye", bookAuthor: "J.D. Salinger"),
        .init(id: 6, bookTitle: "The Hobbit", bookAuthor: "J.R.R. Tolkien"),
        .init(id: 7, bookTitle: "Fahrenheit 451", bookAuthor: "Ray Bradbury"),
        .init(id: 8, bookTitle: "Jane Eyre", bookAuthor: "Charlotte Brontë"),
        .init(id: 9, bookTitle: "The Alchemist", bookAuthor: "Paulo Coelho"),
        .init(id: 10, bookTitle: "The Book Thief", bookAuthor: "Markus Zusak"),
        .init(id: 11, bookTitle: "Moby-Dick", bookAuthor: "Herman Melville"),
        .init(id: 12, bookTitle: "Crime and Punishment", bookAuthor: "Fyodor Dostoevsky")
    ]

    init() {
        favoriteKeys = Set(UserDefaults.standard.stringArray(forKey: storageKey) ?? [])
    }

    func isFavorite(_ key: String) -> Bool { favoriteKeys.contains(key) }

    func toggleFavorite(_ key: String) {
        if favoriteKeys.contains(key) { favoriteKeys.remove(key) }
        else { favoriteKeys.insert(key) }
        save()
    }

    func clearFavorites() {
        favoriteKeys.removeAll()
        save()
    }

    var favoriteCount: Int { favoriteKeys.count }
    var favoriteCities: [CityModel] { cities.filter { isFavorite($0.favoriteKey) } }
    var favoriteHobbies: [HobbyModel] { hobbies.filter { isFavorite($0.favoriteKey) } }
    var favoriteBooks: [BookModel] { books.filter { isFavorite($0.favoriteKey) } }

    private func save() {
        UserDefaults.standard.set(Array(favoriteKeys).sorted(), forKey: storageKey)
    }
}
