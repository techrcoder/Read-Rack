//
//  Book Library.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/22/25.
//

import SwiftUI
import Foundation

class BookLibrary: ObservableObject {
	@Published var books: [Book] = [] {
		didSet { saveBooks() }
	}

	init() {
		loadBooks()
	}

	func add(_ book: Book) {
		books.append(book)
	}

	func update(_ book: Book) {
		if let index = books.firstIndex(where: { $0.id == book.id }) {
			books[index] = book
		}
	}

	func delete(at offsets: IndexSet) {
		books.remove(atOffsets: offsets)
	}

	private func saveBooks() {
		if let data = try? JSONEncoder().encode(books) {
			UserDefaults.standard.set(data, forKey: "books")
		}
	}

	private func loadBooks() {
		if let data = UserDefaults.standard.data(forKey: "books"),
		   let decoded = try? JSONDecoder().decode([Book].self, from: data) {
			books = decoded
		}
	}
}
