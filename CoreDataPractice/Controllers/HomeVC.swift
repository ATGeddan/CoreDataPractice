//
//  HomeVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/20/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData
import CVCalendar

class HomeVC: UIViewController, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
  
  @IBOutlet weak var monthLabel: UILabel! {
    didSet {
      monthLabel.text = getMonthName(Date())
    }
  }
  @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
  @IBOutlet weak var calendarView: CVCalendarView!
  
  let container = AppDelegate.persistentContainer
  var appointDates = [CVDate]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCalendar()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    fetchAppointments()

  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    calendarMenuView.commitMenuViewUpdate()
    calendarView.commitCalendarViewUpdate()
  }
  
  private func setupCalendar() {
    calendarView.calendarDelegate = self
    calendarMenuView.menuViewDelegate = self
    calendarView.animatorDelegate = self
  }
  
  private func fetchAppointments() {
    let context = container.viewContext
    let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
    let sort = NSSortDescriptor(key: "date", ascending: true)
    request.sortDescriptors = [sort]
    do {
      let appointments = try context.fetch(request)
      appointDates = []
      for appointment in appointments {
        guard let theDate = appointment.date else {return}
        let appDate = CVDate(date: theDate)
        appointDates.append(appDate)
      }
      calendarView.contentController.refreshPresentedMonth()
    } catch {
      print(error)
    }

    
  }
  
  func presentationMode() -> CalendarMode {
    return .monthView
  }
  
  func firstWeekday() -> Weekday {
    return .saturday
  }
  
  func dayOfWeekFont() -> UIFont {
    let font = UIFont(name: "Avenir Next Demi Bold", size: 15.0)
    return font!
  }
  
  func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
    if dayView.dotMarkers != [] {
      toggleShowAppointsButton(hasAppoints: true)
    } else {
      toggleShowAppointsButton(hasAppoints: false)
    }
  }
  
  private func toggleShowAppointsButton(hasAppoints: Bool) {
    if hasAppoints {
      // Show the Button
      print("Showing Button")
    } else {
      // Hide the Button
      print("Hiding Button")
    }
  }
  
  func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
    for date in appointDates {
      if dayView.date.commonDescription == date.commonDescription {
        return true
      }
    }
    return false
  }
  
  func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
    return [.blue,.blue]
  }
  
  func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
    return 15
  }
  
  func presentedDateUpdated(_ date: CVDate) {
    monthLabel.text = getMonthName(date.convertedDate()!)
  }
  
  func didShowNextMonthView(_ date: Date) {
    calendarView.contentController.refreshPresentedMonth()
  }
  
  func didShowPreviousMonthView(_ date: Date) {
    calendarView.contentController.refreshPresentedMonth()
  }
  
  func shouldAutoSelectDayOnMonthChange() -> Bool {
    return false
  }
  
  private func getMonthName(_ date: Date) -> String {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "MMMM yyyy"
    let monthName = dateformatter.string(from: date)
    return monthName
  }
  
}
