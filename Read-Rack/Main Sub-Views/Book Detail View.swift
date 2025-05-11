	//
	//  Book Detail View.swift
	//  Read-Rack
	//
	//  Created by Rohan Patel on 4/22/25.
	//

import Foundation
import SwiftUI
import Charts

extension BookItem {
	var bookStatusEnum: BookStatus {
		get { BookStatus(rawValue: self.status!) ?? .wantToRead }
		set { self.status = newValue.rawValue }
	}
}

struct BookDetailView: View {
	@Binding var book: BookItem
	@EnvironmentObject var library: BookLibrary
	
	var context = PersistenceController.shared.container.viewContext
	
	@State var showEditList: Bool = false
	
	@State var readingEntries : [ReadingEntry] = []
	
	@State var bookStatus : BookStatus = .wantToRead
	@State var bookNotes = ""
	@State var currentPage : Double = -100
	
	var body: some View {
		ScrollView {
			VStack (alignment: .leading, spacing: 15) {
				detailsSection
				
				progressSection
				
				notesSection
			}
			.padding()
			.navigationTitle(book.title!)
			.onChange(of: book.bookStatusEnum) { oldStatus, newStatus in
				if oldStatus == .wantToRead && newStatus == .reading {
					book.startDate = Date()
				} else if newStatus == .finished {
					book.endDate = Date()
				}
				library.saveLibrary()
			}
			.onAppear(perform: {
				readingEntries = getBookProgress()
				currentPage = Double(book.currentPage)
			})
			.onDisappear {
				library.saveLibrary()
			}
			.toolbar {
				ToolbarItem {
					Circle().fill(bookStatus.color).frame(width: 14, height: 14)
				}
			}
			.onAppear {
				bookStatus = book.bookStatusEnum
				bookNotes = book.notes!
			}
		}
	}
	
	var detailsSection : some View {
		SectionContainer(title: "Book Details") {
			Text("Author: \(book.author!)")
			Text("Page Count: \(book.pageCount)")
		}
	}
	
	var progressSection : some View {
		SectionContainer(title: "Progress") {
			Picker("Status", selection: $bookStatus) {
					Text("Want to Read").tag(BookStatus.wantToRead)
					Text("Reading").tag(BookStatus.reading)
					Text("Finished").tag(BookStatus.finished)
			}
			.pickerStyle(SegmentedPickerStyle())
			.onChange(of: bookStatus) { _, newValue in
				book.bookStatusEnum = newValue				
			}
			
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Text("Page \(book.currentPage) of \(book.pageCount)")
						.font(.subheadline)
						.foregroundColor(.secondary)
					
					Spacer()
					
					Group {
						if UIDevice.current.userInterfaceIdiom == .pad {
							Button {
								showEditList.toggle()
							} label: {
								Text("Edit Points")
							}
							.fullScreenCover(isPresented: $showEditList) {
								// on dismiss
							} content: {
								bookDetail_EditProgress(book: $book)
							}

							
						} else if UIDevice.current.userInterfaceIdiom == .phone {
							Button {
								showEditList = true
							} label: {
								Text("Edit Points")
							}
							.sheet(isPresented: $showEditList) {
								bookDetail_EditProgress(book: $book)
							}
						}
					}
					.onChange(of: showEditList) { oldValue, newValue in
						if newValue == false {
							readingEntries = getBookProgress()
						}
					}
				}
				
				Slider(
					value: $currentPage,
					in: 0...Double(book.pageCount),
					step: 1
				)
				.onChange(of: currentPage) { oldValue, newValue in
					book.currentPage = Int16(currentPage)
					if oldValue == 0 && newValue > 0 && book.bookStatusEnum == .wantToRead {
						book.bookStatusEnum = .reading
						addEntry(Int16(0))
						book.startDate = Date()
					}
					
					if Int16(newValue) == book.pageCount && book.bookStatusEnum == .reading {
						book.bookStatusEnum = .finished
					}
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
						if Int16(newValue) == book.currentPage && (book.currentPage != (readingEntries.last?.page ?? -1)) {
							addEntry(Int16(newValue))
						}
					}
				}
				
				if !readingEntries.isEmpty {
					Section(header: Text("Reading Progress Over Time")) {
						Chart(readingEntries) {
							LineMark(
								x: .value("Date", $0.date ?? Date()),
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
	}
	
	var notesSection : some View {
		SectionContainer(title: "Notes") {
			VStack (alignment: .leading, spacing: 5){
				if let added = book.addDate {
					Text("Added to Library: \(DateFormatter.localizedString(from: added, dateStyle: .medium, timeStyle: .none))")
				}
				
				if let start = book.startDate {
					Text("Started Reading: \(DateFormatter.localizedString(from: start, dateStyle: .medium, timeStyle: .none))")
				}
				
				if let finish = book.endDate {
					Text("Finished Reading: \(DateFormatter.localizedString(from: finish, dateStyle: .medium, timeStyle: .none))")
				}
			}
			
			TextEditor(text: $bookNotes)
				.frame(minHeight: 100)
				.overlay {
					if bookNotes == "" {
						Text("Tap to Edit").opacity(0.6)
					}
				}
				.onChange(of: bookNotes) { _, newValue in
					book.notes = newValue
					do {
						try? context.save()
					}
				}
		}
	}
	
	func getBookProgress() -> [ReadingEntry] {
		let bookEntries = library.fetchEntries().filter( { $0.book?.id == book.id })
		return bookEntries.sorted { entry1, entry2 in
			entry1.date! < entry2.date!
		}
	}
	
	func addEntry(_ count: Int16) {
		let newEntry = ReadingEntry(context: context)
		newEntry.id = UUID()
		newEntry.date = Date()
		newEntry.page = Int16(count)
		
		newEntry.book = book
		
		do {
			try context.save()
		} catch {
			print(error)
		}
		
		readingEntries = getBookProgress()
		if readingEntries.contains(where: { entry in
			entry.id == newEntry.id
		}) {
			print("All good - Time: \(Date()) & Count: \(Int(count))")
			
		} else {
			readingEntries.append(newEntry)
		}
	}
}


struct SectionContainer<Content: View>: View {
	// Section header properties
	var title: String
	@State var showHeader: Bool = true
	var tapToToggleHeader: Bool = false
	var headerFont: Font = .headline
	var headerColor: Color = .primary
	
	// Background styling properties
	var cornerRadius: CGFloat = 10
	var backgroundColor: Color = Color.gray.opacity(0.1)
	var padding: CGFloat = 12
	
	// Content spacing properties
	var contentSpacing: CGFloat = 10
	var contentTopPadding: CGFloat = 14
	
	// Content builder
	@ViewBuilder var content: () -> Content
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Section header
			if showHeader {
				HStack {
					Text(title)
						.font(headerFont)
						.fontWeight(.semibold)
						.foregroundColor(headerColor)
					
					Spacer()
				}
				.padding(.bottom, contentTopPadding)
				.onTapGesture {
					if tapToToggleHeader {
						withAnimation {
							showHeader.toggle()
						}
					}
				}
			}
			
			// Section content
			VStack(alignment: .leading, spacing: contentSpacing) {
				content()
			}
		}
		.padding(padding)
		.background(
			RoundedRectangle(cornerRadius: cornerRadius)
				.fill(backgroundColor)
		)
	}
}
