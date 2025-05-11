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
