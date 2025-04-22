	//
	//  Book Detail View.swift
	//  Read-Rack
	//
	//  Created by Rohan Patel on 4/22/25.
	//

	import Foundation
	import SwiftUI

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
						.onChange(of: book.currentPage) { oldPage, newPage in
							if newPage > 0 && book.status == .wantToRead {
								book.status = .reading
							}
							if newPage >= book.pageCount && book.status == .reading {
								book.status = .finished								
							}
						}
				}

				Section(header: Text("Notes")) {
					TextEditor(text: $book.notes)
						.frame(minHeight: 100)
				}
			}
			.navigationTitle(book.title)
			.onChange(of: book.status) { oldStatus, newStatus in
				if oldStatus == .wantToRead && newStatus == .reading {
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
