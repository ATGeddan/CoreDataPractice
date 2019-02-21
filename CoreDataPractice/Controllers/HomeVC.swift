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
  
  @IBOutlet weak var monthLabel: CLTypingLabel! {
    didSet {
      monthLabel.text = getMonthName(Date())
    }
  }
  @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
  @IBOutlet weak var calendarView: CVCalendarView!
  @IBOutlet weak var showAppointsBtn: UIButton!
  @IBOutlet weak var buttonsToBottom: NSLayoutConstraint!
  
  let container = AppDelegate.persistentContainer
  var appointDates = [CVDate]()
  var highlightedDate: Date!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCalendar()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    fetchAppointments()

  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    toggleShowAppointsButton(hasAppoints: false)
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
    calendarView.appearance.dayLabelWeekdaySelectedBackgroundColor = #colorLiteral(red: 0.7128025293, green: 0.5533084869, blue: 0.2515522838, alpha: 1)
    calendarView.appearance.dayLabelPresentWeekdaySelectedBackgroundColor = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
    calendarView.appearance.dayLabelPresentWeekdayTextColor = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
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
    if hasAppointments(dayView) {
      highlightedDate = dayView.date.convertedDate()
      toggleShowAppointsButton(hasAppoints: true)
    } else {
      highlightedDate = nil
      toggleShowAppointsButton(hasAppoints: false)
    }
  }
  
  private func hasAppointments(_ dayView: DayView) -> Bool {
    for date in appointDates {
      if date.commonDescription == dayView.date.commonDescription {
        return true
      }
    }
    return false
  }
  
  private func toggleShowAppointsButton(hasAppoints: Bool) {
    if hasAppoints {
      // Show the Button
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {[weak self] in
        self?.buttonsToBottom.constant = 45
        self?.view.layoutIfNeeded()
      }) {[weak self] ended in
        if ended {
          self?.showAppointsBtn.isEnabled = true
        }
      }
    } else {
      // Hide the Button
      showAppointsBtn.isEnabled = false
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {[weak self] in
        self?.buttonsToBottom.constant = 135
        self?.view.layoutIfNeeded()
      })
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
    return [#colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1),#colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1),#colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)]
  }
  
  func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
    return 15
  }
  
  func presentedDateUpdated(_ date: CVDate) {
    let newMonth = getMonthName(date.convertedDate()!)
    let oldMonth = monthLabel.fullText
    if newMonth != oldMonth {
      monthLabel.pauseTyping()
      monthLabel.text = ""
      monthLabel.text = newMonth
    }
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
  
  
  @IBAction func showAppointsClicked(_ sender: UIButton) {
    performSegue(withIdentifier: "showAppointments", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let destination = segue.destination as? AppointmentsTableViewController, let theDate = highlightedDate {
      destination.dateFromCalendar = theDate
    }
  }
}
