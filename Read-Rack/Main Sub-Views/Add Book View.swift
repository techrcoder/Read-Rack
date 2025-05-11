//
//  Add Book View.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/22/25.
//

import Foundation
import SwiftUI

struct AddBookView: View {
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var library: BookLibrary
	
	var context = PersistenceController.shared.container.viewContext
	
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
					let newBook = BookItem(context: context)
					newBook.title = title
					newBook.author = author
					newBook.pageCount = Int16(Int(pageCount) ?? 0)
					newBook.currentPage = 0
					newBook.status = "Want to Read"
					newBook.addDate = Date()
					newBook.startDate = nil
					newBook.endDate = nil
					newBook.id = UUID()
					
					do {
						try context.save()
						library.fetchBooks()
						dismiss()
					} catch {
						print("Error")
					}
				}
				.disabled(Int(pageCount) == nil || title == "")
			}
		}
	}
}
