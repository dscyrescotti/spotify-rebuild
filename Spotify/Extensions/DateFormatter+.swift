//
//  DateFormatter+.swift
//  Spotify
//
//  Created by Dscyre Scotti on 14/04/2021.
//

import Foundation

extension DateFormatter {
    static let inputDateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let outputDateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static func format(_ string: String) -> String {
        guard let date = inputDateFormatter.date(from: string) else { return string }
        return outputDateFormatter.string(from: date)
    }
}
