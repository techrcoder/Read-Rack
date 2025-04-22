	//
	//  Book Detail View.swift
	//  Read-Rack
	//
	//  Created by Rohan Patel on 4/22/25.
	//

import Foundation
import SwiftUI
import Charts

struct BookDetailView: View {
	@State var book: Book
	@ObservedObject var library: BookLibrary		
	
	var body: some View {
		Form {
			Section(header: Text("Progress")) {
				Picker("Status", selection: $book.status) {
					ForEach(Book.BookStatus.allCases, id: \.self) { status in
						Text(status.rawValue).tag(status)
					}
				}
				.pickerStyle( SegmentedPickerStyle() )
				
				VStack(alignment: .leading, spacing: 10) {
					Text("Page \(book.currentPage) of \(book.pageCount)")
						.font(.subheadline)
						.foregroundColor(.secondary)
					
					Slider(
						value: Binding(
							get: { Double(book.currentPage) },
							set: { book.currentPage = Int($0) }
						),
						in: 0...Double(book.pageCount),
						step: 1
					)
						.onChange(of: book.currentPage) { oldValue, newValue in
							if oldValue == 0 && newValue > 0 && book.status == .wantToRead {
								book.status = .reading
							}
							
							if newValue == book.pageCount && book.status == .reading {
								book.status = .finished
							}
							
							DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
								if newValue == book.currentPage && (book.currentPage != (book.readingEntries.last?.page ?? -1)) {
									withAnimation {
										book.readingEntries.append(ReadingEntry(id: UUID(), date: Date(), page: book.currentPage))
									}
								}
							}
						}
					
					if !book.readingEntries.isEmpty {
						Section(header: Text("Reading Progress Over Time")) {
							Chart(book.readingEntries) {
								LineMark(
									x: .value("Date", $0.date),
									y: .value("Pages Read", $0.page)
								)
								.interpolationMethod(.monotone)
								.foregroundStyle(Color.accentColor)
							}
							.frame(height: 200)
						}
					}
				}
			}
			
			Section(header: Text("Notes")) {
				TextEditor(text: $book.notes)
					.frame(minHeight: 100)
					.overlay {
						if book.notes == "" {
							Text("Tap to Edit").opacity(0.6)
						}
					}
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
