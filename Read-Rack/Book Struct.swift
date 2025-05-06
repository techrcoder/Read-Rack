//
//  Book Struct.swift
//  Read-Rack
//
//  Created by Rohan Patel on 4/22/25.
//

import Foundation
import SwiftUI

public enum BookStatus: String, CaseIterable, Codable {
	case wantToRead = "Want to Read"
	case reading = "Reading"
	case finished = "Finished"

	var color: Color {
		switch self {
		case .wantToRead: return .orange
		case .reading: return .blue
		case .finished: return .green
		}
	}
}

/*

struct Book: Identifiable, Codable, Equatable {
	enum BookStatus: String, CaseIterable, Codable {
		case wantToRead = "Want to Read"
		case reading = "Reading"
		case finished = "Finished"

		var color: Color {
			switch self {
			case .wantToRead: return .orange
			case .reading: return .blue
			case .finished: return .green
			}
		}
	}

	let id: UUID
	var title: String
	var author: String
	var pageCount: Int
	var notes: String
	var currentPage: Int
	var status: BookStatus
	var startDate: Date?
	var endDate: Date?
	
	// tracking progress
	var readingEntries: [ReadingEntry] = []
}

struct ReadingEntry: Codable, Equatable, Identifiable {
	let id : UUID
	let date: Date
	let page: Int
}
*/
