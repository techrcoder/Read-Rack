//
//  Statistics Tab View.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/22/25.
//

import Foundation
import SwiftUI

struct StatisticsView: View {
	@Environment(BookLibrary.self) var library
	
	@State var unreadBooks: [BookItem] = []
	@State var readingBooks: [BookItem] = []
	@State var finishedBooks: [BookItem] = []
	
	@State var totalBooksCount: Int = 0
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Reading Statistics")
				.font(.largeTitle)
			
			let totalBooks = library.books.count
			let finished = library.books.filter { BookStatus(rawValue: $0.status!) == .finished }.count
			let pagesRead = library.books.filter { BookStatus(rawValue: $0.status!) == .finished }.map { $0.pageCount }.reduce(0, +)
			
			Text("Total Books in Library: \(totalBooks)")
			Text("Finished: \(finished)")
			Text("Pages Read: \(pagesRead)")
		}
		.padding()
		.onChange(of: library.books) { _, newValue in
			reloadView(newValue)
		}
		.onAppear(perform: loadView)
	}
	
		/// On start, forces library to fetch new data
	private func loadView() {
		let books = library.fetchBooks()
		unreadBooks = filterBooks(books, filterStatus: .wantToRead)
		readingBooks = filterBooks(books, filterStatus: .reading)
		finishedBooks = filterBooks(books, filterStatus: .finished)
	}
		
		/// Reloads the view when needed without causing more changes in library.
	private func reloadView(_ books : [BookItem]) {
		unreadBooks = filterBooks(books, filterStatus: .wantToRead)
		readingBooks = filterBooks(books, filterStatus: .reading)
		finishedBooks = filterBooks(books, filterStatus: .finished)
	}
	
	private func getTotalBooksCount() {
		withAnimation {
			totalBooksCount = library.books.count
		}
	}
}

extension StatisticsView {
		/// - Parameters:
		///   - bookList: An array of `BookItem` objects to filter.
		///   - filterStatus: The `BookStatus` to filter the books by.
		///   - Returns: An array of `BookItem` objects whose `bookStatusEnum` matches the specified `filterStatus`.
	private func filterBooks(_ bookList: [BookItem], filterStatus: BookStatus) -> [BookItem] {
		return bookList.filter { book in
			book.bookStatusEnum == filterStatus
		}
	}
	
		/// Provides array of progress entries for given book.
		/// - Parameter bookItem: The `BookItem` to search for.
		/// - Returns: Array of type `[ReadingEntry]`
	private func getReadingEntries(forBook bookItem: BookItem) -> [ReadingEntry] {
		return library.readingEntries
			.filter({$0.book != nil})
			.filter({$0.date != nil})
			.filter({$0.book!.id == bookItem.id})
			.sorted { entry1, entry2 in
				entry1.date! > entry2.date!
			}
	}
	
		/// Calculates the total number of pages read on a specific date.
		/// - Parameter date: The `Date` to check progress for.
		/// - Returns: The number of pages read on that date.
	private func pagesRead(on date: Date) -> Int {
		let calendar = Calendar.current
		
			// Define start and end of the day
		guard let dayStart = calendar.startOfDay(for: date) as Date?,
			  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)?.addingTimeInterval(-1) else {
			return 0
		}
		
		var totalPagesRead = 0
		
		for book in library.books {
			let entries = getReadingEntries(forBook: book)
			
				// Entries made *on* the date
			let dailyEntries = entries.filter {
				guard let entryDate = $0.date else { return false }
				return entryDate >= dayStart && entryDate <= dayEnd
			}
			
			guard let maxDailyEntry = dailyEntries.max(by: { $0.page.int() < $1.page.int() }) else {
				continue // No valid entries for that day
			}
			
				// Find the latest entry made *before* the day started
			let previousEntries = entries.filter {
				guard let entryDate = $0.date else { return false }
				return entryDate < dayStart
			}
			
			let previousEntry = previousEntries.sorted(by: { $0.date! > $1.date! }).first
			let previousPageCount : Int = previousEntry?.page.int() ?? 0
			
			let pagesRead : Int = maxDailyEntry.page.int() - previousPageCount // change in page count
			
			if pagesRead > 0 { // check that positive.
				totalPagesRead += pagesRead
			}
		}
		
		return totalPagesRead
	}
}

extension Int16 {
	func int() -> Int {
		return Int(self)
	}
}
