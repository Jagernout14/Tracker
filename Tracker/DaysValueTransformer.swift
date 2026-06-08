//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Роман Пичугин on 05.06.2026.
//
import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDays] else {
            return nil
        }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }
        return try? JSONDecoder().decode([WeekDays].self, from: data)
    }
    
    static func register() {
        let name = NSValueTransformerName(String(describing: DaysValueTransformer.self))
        ValueTransformer.setValueTransformer(DaysValueTransformer(), forName: name)
    }
}
