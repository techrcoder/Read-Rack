//
//  Statistics Model.swift
//  Read-Rack
//
//  Created by Rohan Patel on 5/11/25.
//

import Foundation

final class ReadingStatsViewModel: ObservableObject {
	@Published public var unreadBooks: [BookItem] = []
	@Published public var readingBooks: [BookItem] = []
	@Published public var finishedBooks: [BookItem] = []
	
	@Published public var totalBooksCount: Int = 0
	
	let library: BookLibrary

	init(library: BookLibrary) {
		self.library = library
		loadStatsValues()
	}

	func loadStatsValues(using books: [BookItem]? = nil) {
		let sourceBooks = books ?? library.books
		
		self.unreadBooks = filterBooks(sourceBooks, status: .wantToRead)
		self.readingBooks = filterBooks(sourceBooks, status: .reading)
		self.finishedBooks = filterBooks(sourceBooks, status: .finished)
		
		self.totalBooksCount = sourceBooks.count
	}
	
	func filterBooks(_ books: [BookItem], status: BookStatus) -> [BookItem] {
		books.filter { $0.bookStatusEnum == status }
	}
}

// Functions that take in parameters to be used

extension ReadingStatsViewModel {
		/// - Parameters:
		///   - bookList: An array of `BookItem` objects to filter.
		///   - filterStatus: The `BookStatus` to filter the books by.
		///   - Returns: An array of `BookItem` objects whose `bookStatusEnum` matches the specified `filterStatus`.
	func filterBooks(_ bookList: [BookItem], filterStatus: BookStatus) -> [BookItem] {
		return bookList.filter { book in
			book.bookStatusEnum == filterStatus
		}
	}
	
		/// Provides array of progress entries for given book.
		/// - Parameter bookItem: The `BookItem` to search for.
		/// - Returns: Array of type `[ReadingEntry]`
	func getReadingEntries(forBook bookItem: BookItem) -> [ReadingEntry] {
		return self.library.readingEntries
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
	func pagesRead(on date: Date) -> Int {
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

