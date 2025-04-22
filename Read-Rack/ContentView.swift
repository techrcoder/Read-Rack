//
//  ContentView.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/21/25.
//

import SwiftUI
import CoreData
import Foundation

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
							.fontWeight(.bold)
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

#Preview {
    ContentView()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
