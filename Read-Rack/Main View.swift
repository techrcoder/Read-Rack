//
//  Main View.swift
//  Read-Rack
//
//  Created by Rohan Patel on 5/11/25.
//

import SwiftUI
import Foundation

struct MainView: View {
	@EnvironmentObject var library: BookLibrary
	
	@State private var selectedStatus: BookStatus? = nil
	@State private var searchText = ""

	var filteredBooks: [BookItem] {
		return library.books.filter { book in
			(selectedStatus == nil || BookStatus(rawValue: book.status!) == selectedStatus) &&
			(searchText.isEmpty || book.title!.localizedCaseInsensitiveContains(searchText) || book.author!.localizedCaseInsensitiveContains(searchText))
		}
	}
	
	var body: some View {
		NavigationView {
			VStack {
				picker

				list
			}
			.navigationTitle("My Library")
			.toolbar {
				NavigationLink {
					AddBookView()
				} label: {
					Image(systemName: "plus.circle.fill")
						.fontWeight(.bold)
						.shadow(radius: 3)
				}
			}
		}
	}
	
	private var picker : some View {
		Picker("Status", selection: $selectedStatus) {
			Text("All").tag(BookStatus?.none)
			Text("Want to Read").tag(Optional(BookStatus.wantToRead))
			Text("Reading").tag(Optional(BookStatus.reading))
			Text("Finished").tag(Optional(BookStatus.finished))
		}
		.pickerStyle(SegmentedPickerStyle())
		.padding()
	}
	
	private var list : some View {
		List {
			ForEach(filteredBooks, id: \.self) { book in
				BookList_cellController(bookItem: book)
			}
		}
		.searchable(text: $searchText)
	}
}

struct BookList_cellController: View {
	@State var bookItem : BookItem
	
	var body: some View {
		NavigationLink {
			BookDetailView(book: $bookItem)
		} label: {
			BookList_cellView(book: $bookItem)
		}
	}
}

struct BookList_cellView : View {
	@Binding var book : BookItem
	
	@State var bookStatus : BookStatus = .wantToRead
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(book.title!)
					.font(.headline)
				Text(book.author!)
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
			
			Spacer()
			
			switch book.bookStatusEnum {
			case .wantToRead:
				Circle()
					.fill(bookStatus.color)
					.frame(width: 12, height: 12)
					.onAppear {
						bookStatus = BookStatus(rawValue: book.status!)!
					}
			case .reading:
				HStack {
					Text("\(Int(book.currentPage))/\(Int(book.pageCount))")
						.font(.caption)
						.fontDesign(.monospaced)
					
					Circle()
						.fill(bookStatus.color)
						.frame(width: 12, height: 12)
						.onAppear {
							bookStatus = BookStatus(rawValue: book.status!)!
						}
				}
			case .finished:
				HStack {
					Image(systemName: "checkmark")
						.font(.caption)
						.foregroundStyle(bookStatus.color)
					
					Circle()
						.fill(bookStatus.color)
						.frame(width: 12, height: 12)
						.onAppear {
							bookStatus = BookStatus(rawValue: book.status!)!
						}
				}
			}
			
			
		}
	}
}
