//
//  CalendarKitViewController.swift
//  Lec25DatesAndCalendarKit
//
//  Created by Tomer Buzaglo 
//  
//

//the library we use:
import CalendarKit //ui that mimics the apple calendar (in our app)

//apple calendar:
import EventKit
import EventKitUI


import UIKit

class CalendarKitViewController: DayViewController{
    private var eventStore = EKEventStore() //apple
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAccessToCalendar()
        
        //cmd + shift + o: search a file in the entire project:
        
        //model -> EventDescriptor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //get the current hour:
        let hour = Date().component(.hour) ?? 12
        //get the minutes as a fraction
        let minutes = (Date().component(.minute) ?? 0) / 60
        
        let hourAsFloat = Float(hour) + Float(minutes)
        
        dayView.scrollTo(hour24: hourAsFloat)
    }
    
    func requestAccessToCalendar(){
        eventStore.requestAccess(to: .event) {[weak self] granted, err in
            
            //when we get a permission: restart the eventStore
            self?.eventStore = EKEventStore()
        }
    }
    
    
    //אירועים של היום
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let start = date
        let end = date.adjust(.day, offset: 1)
        
        //we want to request events for today from the calendar
        let predicate = eventStore.predicateForEvents(
            withStart: start,
            end: end,
            calendars: nil //all calendars
        )
        
        let esEvents = eventStore.events(matching: predicate)
        
        let ckEvents = esEvents.map(EKWrapper.init)
        
        return ckEvents
    }
}

 
