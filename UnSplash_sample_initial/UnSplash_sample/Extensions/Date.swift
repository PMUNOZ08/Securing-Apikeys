//
//  Date.swift
//  UnSplash_sample
//
//  Created by Pedro on 24/6/23.
//

import Foundation

extension Date {
    
    // "2023-06-13T20:49:26Z"
    init(string: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = formatter.date(from: string) ?? Date()
        self.init(timeInterval: 0, since: date)
    }
    
    private var shortFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    func asShortDateString() -> String {
        return shortFormatter.string(from: self)
    }
    
}
