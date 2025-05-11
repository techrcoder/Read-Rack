//
//  ContentView.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/21/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
	@State var library : BookLibrary = BookLibrary()		

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
		.environment(library)
	}
	
	func loadView() {
		library.fetchBooks()
		library.fetchEntries()
	}
}
