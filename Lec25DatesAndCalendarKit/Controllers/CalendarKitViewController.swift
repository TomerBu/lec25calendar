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
import Combine

class CalendarKitViewController: DayViewController{
    //private var eventStore = EKEventStore() //apple
    lazy var eventStore = EKEventStore()
    
    var subscriptions: Set<AnyCancellable> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAccessToCalendar()
        
        //cmd + shift + o: search a file in the entire project:
        
        //model -> EventDescriptor
        
        NotificationCenter.default.publisher(
            for: .EKEventStoreChanged, object: nil)
            .sink {[weak self] notification in
                DispatchQueue.main.async {
                self?.reloadData()
                self?.scrollToNow()
                }
            }.store(in: &subscriptions)
    }
    
    fileprivate func scrollToNow() {
        //get the current hour:
        let hour = Date().component(.hour) ?? 12
        //get the minutes as a fraction
        let minutes = (Date().component(.minute) ?? 0) / 60
        
        let hourAsFloat = Float(hour) + Float(minutes)
        
        dayView.scrollTo(hour24: hourAsFloat)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToNow()
    }
    
    func requestAccessToCalendar(){
        eventStore.requestAccess(to: .event) {[weak self] granted, err in
            DispatchQueue.main.async {
                //when we get a permission: restart the eventStore
                self?.eventStore = EKEventStore()
                self?.reloadData()
            }
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
    
    //handle clicks:
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        print("Evnet Clicked")
        
        guard let ckEvent = eventView.descriptor as? EKWrapper else {return}
        
        let ekEvent = ckEvent.ekEvent
        
        //present Event Deails: write this method now
        presentEventDetails(event: ekEvent)
                
    }
    //custom method using EKEventViewController to display event details
    //can edit from here using the edit button.
    func presentEventDetails(event: EKEvent){
        let eventViewController = EKEventViewController()
        
        eventViewController.event = event
        
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        
        navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    //long click on an event item:
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else{return}
        //let ekEvent = ckEvent.ekEvent
        
        endEventEditing()
        beginEditing(event: ckEvent, animated: true)
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else{return}
        
        //if we are editing an event - the event is cloned and it has an edited event prop.
        if let originalEvent = editingEvent.editedEvent{
            event.commitEditing()
            
            if originalEvent === editingEvent{
                //edit before save:
                presentEditingViewForEvent(ekEvent: editingEvent.ekEvent)
            }else{
                try? eventStore.save(editingEvent.ekEvent, span: .thisEvent)
            }
        }
        
        reloadData()
    }
    
    func presentEditingViewForEvent(ekEvent: EKEvent){
        let editingViewController = EKEventEditViewController()
        
        editingViewController.event = ekEvent
        editingViewController.eventStore = eventStore
        editingViewController.editViewDelegate = self //conform
        
        
        present(editingViewController, animated: true)
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    

    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        let newEkEvent = EKEvent(eventStore: eventStore)
        
        newEkEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        let startDate = date
        let endDate = date.adjust(.hour, offset: 1)
        
        newEkEvent.title = "New Event"
        newEkEvent.startDate = startDate
        newEkEvent.endDate = endDate
        
        let newEkEventWrapper = EKWrapper(newEkEvent)
        newEkEventWrapper.editedEvent = newEkEventWrapper//new event -> Editing self
        
        //calls didUpdate
        create(event: newEkEventWrapper)
    }
}


extension CalendarKitViewController: EKEventEditViewDelegate{
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true)
    }
    
    
}
