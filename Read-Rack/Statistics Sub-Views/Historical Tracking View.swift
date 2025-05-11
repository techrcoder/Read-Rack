//
//  Historical Tracking.swift
//  Read-Rack
//
//  Created by Rohan Patel on 5/12/25.
//

import SwiftUI

struct HistoricalTrackingView : View {
	@EnvironmentObject var statsModel: ReadingStatsViewModel
	@State private var studyPeriod: StudyPeriodType = .month
	
	// values to track
	@State var booksFinished : Int = 0 // how many books with finishDate marked in the past time period (studyPeriod) marked for the view in UI
	
	@State var bestStreakLength : Int = 0 // how many consistent days with any readingprogress marked. look within the last study period.
	@State var bestStreakStartDate : Date?
	@State var bestStreakEndDate : Date?
	
	@State var mostActiveHour : Int? = nil // uses 24 hour time. Make sure to display based on user localization. Take average hour of all the readingprogress entries over the time period.
	
	// longest streak in the past time frame... (center)
	// best reading time/most active reading time in the past etc time frame... (right)
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack {
				Text("Historical Reading")
					.font(.subheadline)
					.bold()
				Spacer()
				Menu {
					Picker("Period", selection: $studyPeriod) {
						Text("Week").tag(StudyPeriodType.week)
						Text("Month").tag(StudyPeriodType.month)
						Text("3 Months").tag(StudyPeriodType.threeMonths)
						Text("Year").tag(StudyPeriodType.year)
						Text("All Time").tag(StudyPeriodType.allTime)
					}
				} label: {
					Label("Past \(studyPeriod.label)", systemImage: "chevron.down")
						.font(.footnote)
						.foregroundColor(.accentColor)
				}
			}

			HStack (spacing: 8) {
				Spacer()
				
				// Books Finished
				VStack (alignment: .center, spacing: 3) {
					Text("\(booksFinished)")
						.font(.title3)
						.fontWeight(.heavy)
					Text("Books Finished")
						.font(.caption2)
						.fontWeight(.medium)
				}
				
				Spacer()
				
				Divider()
				
				Spacer()
				
				// Streak
				VStack (alignment: .center, spacing: 3) {
					if bestStreakLength >= 2 {
						Text("\(bestStreakLength) Days")
							.font(.title3)
							.fontWeight(.heavy)
						Text("Longest Streak")
							.font(.caption2)
							.fontWeight(.medium)
					} else {
						Text("No Streak")
							.font(.caption2)
							.fontWeight(.medium)
					}
				}
				
				Spacer()
				
				Divider()
				
				Spacer()
				
				VStack (alignment: .center, spacing: 3) {
					if let hour = mostActiveHour {
						Text("\(hour)")
							.font(.title3)
							.fontWeight(.heavy)
					} else {
						Text("?")
							.font(.title3)
							.fontWeight(.bold)
					}
					
					Text("Most Active Reading Hour")
						.font(.caption2)
						.fontWeight(.medium)
				}
				
				Spacer()
			}
			.multilineTextAlignment(.center)
			.frame(maxWidth: .infinity)
			.padding()
			.background(Color(.systemGray6))
			.cornerRadius(10)
			.shadow(radius: 1)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 25)
				.fill(Color(.systemGray4))
		)
		.onAppear(perform: populateValues)
		.onChange(of: studyPeriod) { _, _ in
			populateValues()
		}
	}
	
	private func populateValues() {
		booksFinished = statsModel.booksFinished(in: studyPeriod)
		
		let streakResult = statsModel.longestReadingStreak(in: studyPeriod)
		bestStreakLength = streakResult.length
		bestStreakStartDate = streakResult.start
		bestStreakEndDate = streakResult.end
		
		mostActiveHour = statsModel.mostActiveHour(in: studyPeriod)
	}
}

extension ReadingStatsViewModel {
	// functions go here
	
		// Helper: returns start and end date for the period
	func dateRange(for period: StudyPeriodType) -> (start: Date, end: Date) {
		let calendar = Calendar.current
		let endDate = Date()
		let startDate: Date

		if period == .allTime {
			startDate = Date.distantPast
		} else {
			startDate = calendar.date(byAdding: .day, value: -period.rawValue + 1, to: endDate)!
		}
		return (startDate, endDate)
	}

	// Helper: returns reading entries in the period
	func readingEntries(in period: StudyPeriodType) -> [ReadingEntry] {
		let range = dateRange(for: period)
		return library.books.flatMap { getReadingEntries(forBook: $0) }
			.filter { entry in
				guard let date = entry.date else { return false }
				return (range.start...range.end).contains(date)
			}
	}

	// Number of books finished in period
	func booksFinished(in period: StudyPeriodType) -> Int {
		let range = dateRange(for: period)
		let books = self.library.books.filter({
			guard let finishDate = $0.endDate else { return false }
			return (range.start...range.end).contains(finishDate)
		})
		return books.count
	}

	// Longest reading streak in period
	func longestReadingStreak(in period: StudyPeriodType) -> (length: Int, start: Date?, end: Date?) {
		let entries = readingEntries(in: period)
		let calendar = Calendar.current
		let dates = Set(entries.compactMap { entry in
			entry.date.map { calendar.startOfDay(for: $0) }
		}).sorted()

		var maxLength = 0
		var currentLength = 0
		var streakStart: Date?
		var streakEnd: Date?
		var previousDate: Date?

		for date in dates {
			if let prev = previousDate, calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: prev)!) {
				currentLength += 1
				streakEnd = date
			} else {
				currentLength = 1
				streakStart = date
				streakEnd = date
			}
			if currentLength > maxLength {
				maxLength = currentLength
			}
			previousDate = date
		}
		return (maxLength, streakStart, streakEnd)
	}

	// Most active hour in period
	func mostActiveHour(in period: StudyPeriodType) -> Int {
		let entries = readingEntries(in: period)
		let calendar = Calendar.current
		let hours = entries.compactMap { entry in
			entry.date.map { calendar.component(.hour, from: $0) }
		}
		guard !hours.isEmpty else { return 12 }

		let hourFrequencies = Dictionary(grouping: hours, by: { $0 }).mapValues { $0.count }
		return hourFrequencies.max(by: { $0.value < $1.value })?.key ?? 12
	}
}
