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
						endDate: nil,
						readingEntries: [ReadingEntry(id: UUID(), date: Date(), page: 0)]
					)
					
					library.add(newBook)
					dismiss()
				}
			}
		}
	}
}
