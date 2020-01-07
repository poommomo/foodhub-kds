//
//  TypeExtension.swift
//  FoodHub-KDS
//
//  Created by Poom Penghiran on 23/12/2562 BE.
//  Copyright © 2562 Poom Penghiran. All rights reserved.
//

import UIKit

extension Int {
    
    func secondsToHoursMinutesSeconds() -> (Int, Int, Int) {
      return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
}

extension String {
    
    public func dateFromStringUTC() -> String {
        // TODO: Check with API for milliseconds?
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        var convertedDate = Date()
        
        if let dateTmp = dateFormatter.date(from: self) {
            convertedDate = dateTmp
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
            guard let dateTmp2 = dateFormatter.date(from: self) else { return "N/A" }
            convertedDate = dateTmp2
        }
        
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: convertedDate)
    }
    
    func getTimeDifference() -> DateComponents? {
        let locale = "en_US"
        var userCalendar = Calendar(identifier: .gregorian)
        userCalendar.timeZone = .current
        userCalendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [.hour,.minute,.second]
        let startTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let inputDate = dateFormatter.date(from: self) else { return nil }
        let timeDifference = userCalendar.dateComponents(requestedComponent, from: inputDate, to: startTime)
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: locale)
        
        return timeDifference
    }
        
    func getTimeDifferenceColor() -> UIColor {
        let locale = "en_US"
        var userCalendar = Calendar(identifier: .gregorian)
        userCalendar.timeZone = .current
        userCalendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [.hour,.minute,.second]
        let startTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let inputDate = dateFormatter.date(from: self) else { return UIColor.systemGray2 }
        let timeDifference = userCalendar.dateComponents(requestedComponent, from: inputDate, to: startTime)
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: locale)
        if let hourDifference = timeDifference.hour, let minDifference = timeDifference.minute {
            if minDifference >= 3 || hourDifference >= 1 {
                return UIColor.systemRed
            } else if minDifference >= 2 {
                return UIColor.systemOrange
            } else {
                return UIColor.systemGreen
            }
        }
        return UIColor.systemGray2
    }

}

extension DateComponents {
    
    func dateComponentToString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
//        formatter.includesApproximationPhrase = true
//        formatter.includesTimeRemainingPhrase = true
        formatter.allowedUnits = [.hour, .minute, .second]
        
        return formatter.string(for: self) ?? "" 
    }
    
}
