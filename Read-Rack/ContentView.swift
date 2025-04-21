//
//  ContentView.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/21/25.
//

import SwiftUI
import CoreData
import Foundation

struct Book: Identifiable, Codable, Equatable {
	enum BookStatus: String, CaseIterable, Codable {
		case wantToRead = "Want to Read"
		case reading = "Reading"
		case finished = "Finished"

		var color: Color {
			switch self {
			case .wantToRead: return .orange
			case .reading: return .blue
			case .finished: return .green
			}
		}
	}

	let id: UUID
	var title: String
	var author: String
	var pageCount: Int
	var notes: String
	var currentPage: Int
	var status: BookStatus
	var startDate: Date?
	var endDate: Date?
}

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

struct ContentView: View {
	@StateObject var library = BookLibrary()
	@State private var selectedStatus: Book.BookStatus? = nil
	@State private var searchText = ""

	var filteredBooks: [Book] {
		library.books.filter { book in
			(selectedStatus == nil || book.status == selectedStatus) &&
			(searchText.isEmpty || book.title.localizedCaseInsensitiveContains(searchText) || book.author.localizedCaseInsensitiveContains(searchText))
		}
	}

	var body: some View {
		TabView {
			NavigationView {
				VStack {
					Picker("Status", selection: $selectedStatus) {
						Text("All").tag(Book.BookStatus?.none)
						ForEach(Book.BookStatus.allCases, id: \..self) { status in
							Text(status.rawValue).tag(Optional(status))
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					.padding()

					List {
						ForEach(filteredBooks) { book in
							NavigationLink(destination: BookDetailView(book: book, library: library)) {
								HStack {
									VStack(alignment: .leading) {
										Text(book.title).font(.headline)
										Text(book.author).font(.subheadline).foregroundColor(.secondary)
									}
									Spacer()
									Circle().fill(book.status.color).frame(width: 12, height: 12)
								}
							}
						}
						.onDelete(perform: library.delete)
					}
					.searchable(text: $searchText)
				}
				.navigationTitle("My Library")
				.toolbar {
					NavigationLink(destination: AddBookView(library: library)) {
						Image(systemName: "plus")
					}
				}
			}
			.tabItem {
				Label("Library", systemImage: "books.vertical")
			}

			StatisticsView(library: library)
				.tabItem {
					Label("Stats", systemImage: "chart.bar.xaxis")
				}
		}
		.font(.custom("SF Pro Display", size: 17))
	}
}

struct AddBookView: View {
	@Environment(\.dismiss) var dismiss

	@ObservedObject var library: BookLibrary
	@State private var title = ""
	@State private var author = ""
	@State private var pageCount = ""

	var body: some View {
		Form {
			Section(header: Text("Book Info")) {
				TextField("Title", text: $title)
				TextField("Author", text: $author)
				#if os(iOS)
				TextField("Page Count", text: $pageCount)
					.keyboardType(.numberPad)
				#else
				TextField("Page Count", text: $pageCount)
					.onSubmit {
						let number = Int(pageCount)
						print(number)
					}
				#endif
			}
		}
		.navigationTitle("Add Book")
		.toolbar {
			ToolbarItem(placement: .confirmationAction) {
				Button("Save") {
					let newBook = Book(
						id: UUID(),
						title: title,
						author: author,
						pageCount: Int(pageCount) ?? 0,
						notes: "",
						currentPage: 0,
						status: .wantToRead,
						startDate: nil,
						endDate: nil
					)
					library.add(newBook)
					dismiss()
				}
			}
		}
	}
}

struct BookDetailView: View {
	@State var book: Book
	@ObservedObject var library: BookLibrary

	var body: some View {
		Form {
			Section(header: Text("Progress")) {
				Picker("Status", selection: $book.status) {
					ForEach(Book.BookStatus.allCases, id: \..self) { status in
						Text(status.rawValue).tag(status)
					}
				}
				.pickerStyle(SegmentedPickerStyle())

				Stepper("Current Page: \(book.currentPage)", value: $book.currentPage, in: 0...(book.pageCount))
			}

			Section(header: Text("Notes")) {
				TextEditor(text: $book.notes)
					.frame(minHeight: 100)
			}
		}
		.navigationTitle(book.title)
		.onChange(of: book.status) { newStatus in
			if newStatus == .reading {
				book.startDate = Date()
			} else if newStatus == .finished {
				book.endDate = Date()
			}
			library.update(book)
		}
		.onDisappear {
			library.update(book)
		}
	}
}

struct StatisticsView: View {
	@ObservedObject var library: BookLibrary

	var body: some View {
		VStack(spacing: 20) {
			Text("Reading Statistics")
				.font(.largeTitle)

			let totalBooks = library.books.count
			let finished = library.books.filter { $0.status == .finished }.count
			let pagesRead = library.books.filter { $0.status == .finished }.map { $0.pageCount }.reduce(0, +)

			Text("Total Books: \(totalBooks)")
			Text("Finished: \(finished)")
			Text("Pages Read: \(pagesRead)")
		}
		.padding()
	}
}

//@main
//struct ReadingTrackerApp: App {
//	var body: some Scene {
//		WindowGroup {
//			ContentView()
//		}
//	}
//}


#Preview {
    ContentView()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
