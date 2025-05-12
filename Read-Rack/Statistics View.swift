//
//  Statistics Tab View.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/22/25.
//

import Foundation
import SwiftUI

struct StatisticsView: View {
	@EnvironmentObject var library: BookLibrary
	@EnvironmentObject var statsModel: ReadingStatsViewModel
	
//	@State var unreadBooks: [BookItem] = []
//	@State var readingBooks: [BookItem] = []
//	@State var finishedBooks: [BookItem] = []
//	
//	@State var totalBooksCount: Int = 0
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				Text("Reading Statistics")
					.font(.largeTitle)
					.fontWeight(.heavy)
				
				AvgPagesPerDayView()
				
				HistoricalTrackingView()
				
				VStack (alignment: .center, spacing: 8) {
					Text("More and More Stats Cells coming soon!")
					Text("Feel free to send me emails @ rohanp.development@gmail.com for requests, ideas, and feedback! I'd greatly appreciate it. \n \n Best regards, -Rohan")
						.italic()
				}
				.font(.caption)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 30)
			}
			.padding()
			.onChange(of: library.books) { _, newValue in
				statsModel.loadStatsValues(using: newValue)
			}
			.onAppear {
				statsModel.loadStatsValues(using: library.fetchBooks())
			}
		}
	}
}
