//
//  Book Library.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/22/25.
//

import SwiftUI
import Foundation
import CoreData

final class BookLibrary: ObservableObject {
	var context = PersistenceController.shared.container.viewContext

	@Published public var books: [BookItem] = []
	@Published public var readingEntries: [ReadingEntry] = []
	
	public func delete(_ book : BookItem) {
		context.delete(book)
	}

	public func saveLibrary() {
		do {
			try self.context.save()
		} catch {
			print(error)
		}
		
		self.fetchBooks()
		self.fetchEntries()
	}
	
	@discardableResult func fetchBooks() -> [BookItem] {

		var booksArray : [BookItem] = []

		let fetchRequest: NSFetchRequest<BookItem>

		fetchRequest = BookItem.fetchRequest()

		do {
			booksArray = try self.context.fetch(fetchRequest)
		} catch {
			print("Error fetching tasks")
		}

		self.books = booksArray

		return booksArray
	}
	
	@discardableResult func fetchEntries() -> [ReadingEntry] {

		var entriesArray : [ReadingEntry] = []

		let fetchRequest: NSFetchRequest<ReadingEntry>

		fetchRequest = ReadingEntry.fetchRequest()

		do {
			entriesArray = try self.context.fetch(fetchRequest)
		} catch {
			print("Error fetching tasks")
		}

		self.readingEntries = entriesArray

		return entriesArray
	}
}
