//
//  ContentView.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/21/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
	@StateObject var library : BookLibrary
	@StateObject var readingStatsModel : ReadingStatsViewModel

	init() {
		let lib = BookLibrary()
		_library = StateObject(wrappedValue: lib)
		_readingStatsModel = StateObject(wrappedValue: ReadingStatsViewModel(library: lib))
	}
	
	var body: some View {
		TabView {
			MainView()
			.tabItem {
				Label("Library", systemImage: "books.vertical")
			}

			StatisticsView()
				.tabItem {
					Label("Stats", systemImage: "chart.bar.xaxis")
				}
		}
		.font(.custom("SF Pro Display", size: 17))
		.onAppear(perform: {
			loadView()
		})
		.environmentObject(library)
		.environmentObject(readingStatsModel)
	}
	
	func loadView() {
		library.fetchBooks()
		library.fetchEntries()
	}
}
