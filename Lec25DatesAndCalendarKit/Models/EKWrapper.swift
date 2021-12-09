//
//  EKWrapper.swift
//  Lec25DatesAndCalendarKit
//
//  Created by Tomer Buzaglo 
//  
//

import UIKit
import CalendarKit
import EventKit

//we want to show EKEvents from Apple Calendar.
//the library has a built in Event Class.

public final class EKWrapper: EventDescriptor {
 
    //the event we get from the apple Calendar
    public private (set) var ekEvent: EKEvent
    
    public init(_ ekEvent: EKEvent) {
        self.ekEvent = ekEvent
        updateColors()
    }
    
    //computed props:
    //take all the data we need from the apple event:
    public var startDate: Date{
        ekEvent.startDate
    }
    
    public var endDate: Date{
        ekEvent.endDate
    }
    
    public var dateInterval:DateInterval{
        get{
            DateInterval(start: startDate, end: endDate)
        }
        set{
            ekEvent.startDate = newValue.start
            ekEvent.endDate = newValue.end
        }
    }
    public var isAllDay: Bool{
        get{
            ekEvent.isAllDay
        }set{
            ekEvent.isAllDay = newValue
        }
    }
    public var text:String{
        get{
            ekEvent.title
        }
        set{
            ekEvent.title = newValue
        }
    }
    
    //
    public var attributedText: NSAttributedString?
    public var lineBreakMode: NSLineBreakMode?
    public var color: UIColor{
        //updateColors()//
        return UIColor(cgColor: ekEvent.calendar.cgColor)
    }
    public var backgroundColor = SystemColors.systemBlue.withAlphaComponent(0.3)
    public var textColor = SystemColors.label
    public var font = UIFont.boldSystemFont(ofSize: 12)
    public var userInfo: Any?
    public weak var editedEvent: EventDescriptor? {
        didSet {
            updateColors()
        }
    }
    
    public func makeEditable() -> EKWrapper {
        let clone = Self(ekEvent)
        //the copy holds a ref to the original => when the finger is lifted
        
        clone.editedEvent = self
        return clone
    }
    
    public func commitEditing() {
        guard let edited = editedEvent else {return}
        edited.dateInterval = dateInterval
    }
    
    private func updateColors() {
        (editedEvent != nil) ? applyEditingColors() : applyStandardColors()
    }
    
    /// Colors used when event is not in editing mode
    private func applyStandardColors() {
        backgroundColor = dynamicStandardBackgroundColor()
        textColor = dynamicStandardTextColor()
    }
    
    /// Colors used in editing mode
    private func applyEditingColors() {
        backgroundColor = color.withAlphaComponent(0.95)
        textColor = .white
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardBackgroundColor() -> UIColor {
        let light = backgroundColorForLightTheme(baseColor: color)
        let dark = backgroundColorForDarkTheme(baseColor: color)
        return dynamicColor(light: light, dark: dark)
    }
    
    /// Dynamic color that changes depending on the user interface style (dark / light)
    private func dynamicStandardTextColor() -> UIColor {
        let light = textColorForLightTheme(baseColor: color)
        return dynamicColor(light: light, dark: color)
    }
    
    private func textColorForLightTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a)
    }
    
    private func backgroundColorForLightTheme(baseColor: UIColor) -> UIColor {
        baseColor.withAlphaComponent(0.3)
    }
    
    private func backgroundColorForDarkTheme(baseColor: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.4, alpha: a * 0.8)
    }
    
    private func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                let interfaceStyle = traitCollection.userInterfaceStyle
                switch interfaceStyle {
                case .dark:
                    return dark
                default:
                    return light
                }
            }
        } else {
            return light
        }
    }
}
