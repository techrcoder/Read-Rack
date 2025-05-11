//
//  Book Detail - Edit Progress.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/30/25.
//

import SwiftUI
import Foundation
import Charts

struct bookDetail_EditProgress: View {
	@Binding var book : BookItem
	@EnvironmentObject var library: BookLibrary
	
//	var readingEntries : [ReadingEntry] {
//		let bookEntries = library.readingEntries.filter( { $0.book?.id == book.id })
//		return bookEntries.sorted { entry1, entry2 in
//			entry1.date! < entry2.date!
//		}
//	}
	@State var readingEntries : [ReadingEntry] = []
	
	let dateFormatter : DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}()
	
	@State var newEntryDate : Date = Date()
	@State var newPageCount : Int = 0
	
	var context = PersistenceController.shared.container.viewContext
		
	var body: some View {
		ScrollView (showsIndicators: false) {
			VStack(alignment: .leading, spacing: 15) {
				HStack {
					Text("Edit Progress Points")
						.font(.title)
						.fontWeight(.bold)
					
					Spacer()
				}
					
				ForEach(readingEntries) { entry in
					HStack {
						Button {
							withAnimation {
								context.delete(entry)
								library.saveLibrary()
								readingEntries = getEntries()
							}
						} label: {
							Image(systemName: "xmark.circle.fill")
						}
						.padding(5)
						
						Text("\(entry.date!, formatter: dateFormatter)")
						Spacer()
						Text("\(entry.page)")
					}
				}
								
				// chart
				SectionContainer(title: "Reading Progress Over Time") {
					Chart(readingEntries) {
						LineMark(
							x: .value("Date", $0.date!),
							y: .value("Pages Read", $0.page)
						)
						.interpolationMethod(.monotone)
						.foregroundStyle(Color.accentColor)
					}
					.frame(height: 200)
				}
				
				// new entry
				VStack {
					HStack {
						Text("Enter a new Progress Entry")
							.font(.headline)
							.fontWeight(.semibold)
						
						Spacer()
						
						Button {
							let newEntry = ReadingEntry(context: context)
							newEntry.id = UUID()
							newEntry.date = newEntryDate
							newEntry.page = Int16(newPageCount)
							
							newEntry.book = book
							
							library.saveLibrary()
							readingEntries = getEntries()
						} label: {
							Text("Add")
								.foregroundStyle(.black)
								.padding(8)
								.background(
									RoundedRectangle(cornerRadius: 20)
								)
						}
					}
					
					VStack {
						DatePicker(selection: $newEntryDate, displayedComponents: [.date, .hourAndMinute]) {
							Text("New Entry Date")
						}
						
						Spacer()
						
						Stepper(value: $newPageCount, in: 1...Int(book.pageCount)) {
							Text("New Page Count: \(newPageCount)")
						}
						
						Picker("Select a number", selection: $newPageCount) {
							ForEach(1...Int(book.pageCount), id: \.self) { number in
								Text("\(number)").tag(number)
							}
						}
						.pickerStyle(WheelPickerStyle())
					}
				}
				.padding(12)
				.background(
					RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1))
				)
				
				Spacer()
			}
			.padding()
			.onAppear {
				readingEntries = getEntries()
				newPageCount = Int(book.currentPage)
			}
		}
	}
	
	func getEntries() -> [ReadingEntry] {
		let bookEntries = library.fetchEntries().filter( { $0.book?.id == book.id })
		return bookEntries.sorted { entry1, entry2 in
			entry1.date! < entry2.date!
		}
	}
}
