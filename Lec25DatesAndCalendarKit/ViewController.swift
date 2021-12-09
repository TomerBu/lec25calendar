//
//  ViewController.swift
//  Lec25DatesAndCalendarKit
//
//  Created by Tomer Buzaglo 
//  
//


import UIKit
import FSCalendar

class ViewController: UIViewController {
    @IBOutlet weak var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.allowsMultipleSelection = true
        calendar.backgroundColor = .black
        
        //pre selected dates:
        calendar.select(Date())
        calendar.select(Date().adjust(.day, offset: 1))
        calendar.select(Date().adjust(.day, offset: 3))
    }
}

extension ViewController: FSCalendarDataSource{
    func minimumDate(for calendar: FSCalendar) -> Date {
        Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        Date().adjust(.month, offset: 1).dateFor(.endOfMonth)
    }
}

extension ViewController: FSCalendarDelegate{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Selected \(date)")
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Removed \(date)")
    }
    
    //disable selection for odd days
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        return date.component(.day)! % 2 == 0
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let result = calendar.selectedDates.contains { date in
            date == date
        }

        return !result
    }
    
}


extension ViewController: FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        [UIColor.red, UIColor.black]
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        .orange
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        .green
    }
    
    //border color for selected date
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        .systemBlue
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        .systemRed
    }
}
