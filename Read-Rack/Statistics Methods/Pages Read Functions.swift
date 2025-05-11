//
//  Pages Read Functions.swift
//  Read-Rack
//
//  Created by Rohan Patel on 5/11/25.
//

import Foundation

enum StudyPeriodType: Int {
	case week = 7
	case month = 30
	case threeMonths = 90
	case year = 365
	case allTime = -1  // Special marker for all-time
}

enum AveragingPeriodType: Int {
	case daily = 1
	case weekly = 7
	case monthly = 30
}

extension ReadingStatsViewModel {
	func pagesRead(in period: StudyPeriodType) -> Int {
		var count = 0
		
		if period == .allTime {
			// Optional: if you have all entries across all dates
			for book in self.library.books {
				let entries = getReadingEntries(forBook: book)
				let maxEntry = entries.max(by: { $0.page.int() < $1.page.int() })?.page.int() ?? 0
				count += maxEntry
			}
			return count
		}
		
		// Otherwise, count day-by-day
		for dayOffset in 1...period.rawValue {
			if let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) {
				count += self.pagesRead(on: date)
			}
		}
		
		return count
	}
	
	func avgReadCount(over period: StudyPeriodType, per averagingType: AveragingPeriodType) -> Int {
		let count = self.pagesRead(in: period)
		return (count / period.rawValue) * averagingType.rawValue
	}
}
