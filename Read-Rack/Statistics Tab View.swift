//
//  Statistics Tab View.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/22/25.
//

import Foundation
import SwiftUI

struct StatisticsView: View {
	@ObservedObject var library: BookLibrary

	var body: some View {
		VStack(spacing: 20) {
			Text("Reading Statistics")
				.font(.largeTitle)

			let totalBooks = library.books.count
			let finished = library.books.filter { $0.status == .finished }.count
			let pagesRead = library.books.filter { $0.status == .finished }.map { $0.pageCount }.reduce(0, +)

			Text("Total Books in Library: \(totalBooks)")
			Text("Finished: \(finished)")
			Text("Pages Read: \(pagesRead)")
		}
		.padding()
	}
}
