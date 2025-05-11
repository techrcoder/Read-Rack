	//
	//  Avg Pages per Period View.swift
	//  Read-Rack
	//
	//  Created by Rohan Patel on 5/11/25.
	//

import SwiftUI

	// Averages pages read 'per day' or 'per week' or 'per month'
	// Over the last 'week', 'month', '3 months'
struct AvgPagesPerDayView: View {
	@EnvironmentObject var statsModel: ReadingStatsViewModel
	
		// How far back should the data look to display the user trend? If .month, go over the last 30 days, if .week, only the last 7's average. so on.
	@State private var studyPeriod: StudyPeriodType = .month
	
		// What increment are we looking at? Pages read per day, pages read per week? Pages read per month?
	@State private var periodBookmarkType: AveragingPeriodType = .daily
	
	/* Functions Available in statsModel:
	 func avgReadCount(over period: StudyPeriodType, per averagingType: AveragingPeriodType) -> Int
	 -> Main use for this view. Use with two variables in this view that UI can control
	 */
	
	@State var averageValue: Int = 0
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack {
				Text("Your Reading Trend")
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

			Picker("Avg By", selection: $periodBookmarkType) {
				Text("Per Day").tag(AveragingPeriodType.daily)
				Text("Per Week").tag(AveragingPeriodType.weekly)
				Text("Per Month").tag(AveragingPeriodType.monthly)
			}
			.pickerStyle(SegmentedPickerStyle())

			VStack(spacing: 8) {
				Text("Average Pages")
					.font(.caption)
					.foregroundColor(.secondary)

				Text("\(averageValue)")
					.font(.system(size: 36, weight: .semibold, design: .rounded))
					.foregroundColor(.accentColor)
			}
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
		.onAppear(perform: loadAverage)
		.onChange(of: studyPeriod) { _, _ in
			loadAverage()
		}
		.onChange(of: periodBookmarkType) { _, _ in
			loadAverage()
		}
	}
	
	private func loadAverage() {
		withAnimation {
			averageValue = statsModel.avgReadCount(over: studyPeriod, per: periodBookmarkType)
		}
	}
}

// Computed property for StudyPeriodType picker label
extension StudyPeriodType {
	var label: String {
		switch self {
		case .week: return "Week"
		case .month: return "Month"
		case .threeMonths: return "3 Months"
		case .year: return "Year"
		case .allTime: return "All Time"
		}
	}
}
