//
//  NativeEventExample.swift
//  Example
//
//  Created by Mathias Claassen on 3/15/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Eureka

class NativeEventNavigationController: UINavigationController, RowControllerType {
    var onDismissCallback : ((UIViewController) -> ())?
}

class NativeEventFormViewController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeForm()

        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(NativeEventFormViewController.cancelTapped(_:))
        
        // uncomment and notice the difference
//         self.defaultScrollPosition = .top
    }

    private func initializeForm() {

        form +++

            TextRow("Title").cellSetup { cell, row in
                cell.textField.placeholder = row.tag
            }

            <<< TextRow("Location").cellSetup {
                $1.cell.textField.placeholder = $0.row.tag
            }

            +++

            SwitchRow("All-day") {
                $0.title = $0.tag
                }.onChange { [weak self] row in
                    let startDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                    let endDate: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")

                    if row.value ?? false {
                        startDate.dateFormatter?.dateStyle = .medium
                        startDate.dateFormatter?.timeStyle = .none
                        endDate.dateFormatter?.dateStyle = .medium
                        endDate.dateFormatter?.timeStyle = .none
                    }
                    else {
                        startDate.dateFormatter?.dateStyle = .short
                        startDate.dateFormatter?.timeStyle = .short
                        endDate.dateFormatter?.dateStyle = .short
                        endDate.dateFormatter?.timeStyle = .short
                    }
                    startDate.updateCell()
                    endDate.updateCell()
                    startDate.inlineRow?.updateCell()
                    endDate.inlineRow?.updateCell()
            }

            <<< DateTimeInlineRow("Starts") {
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*24)
                }
                .onChange { [weak self] row in
                    let endRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                    if row.value?.compare(endRow.value!) == .orderedDescending {
                        endRow.value = Date(timeInterval: 60*60*24, since: row.value!)
                        endRow.cell!.backgroundColor = .white
                        endRow.updateCell()
                    }
                }
                .onExpandInlineRow { [weak self] cell, row, inlineRow in
                    inlineRow.cellUpdate() { cell, row in
                        let allRow: SwitchRow! = self?.form.rowBy(tag: "All-day")
                        if allRow.value ?? false {
                            cell.datePicker.datePickerMode = .date
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                        }
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
            }

            <<< DateTimeInlineRow("Ends"){
                $0.title = $0.tag
                $0.value = Date().addingTimeInterval(60*60*25)
                }
                .onChange { [weak self] row in
                    let startRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                    if row.value?.compare(startRow.value!) == .orderedAscending {
                        row.cell!.backgroundColor = .red
                    }
                    else{
                        row.cell!.backgroundColor = .white
                    }
                    row.updateCell()
                }
                .onExpandInlineRow { [weak self] cell, row, inlineRow in
                    inlineRow.cellUpdate { cell, dateRow in
                        let allRow: SwitchRow! = self?.form.rowBy(tag: "All-day")
                        if allRow.value ?? false {
                            cell.datePicker.datePickerMode = .date
                        }
                        else {
                            cell.datePicker.datePickerMode = .dateAndTime
                        }
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
        }

        form +++

            PushRow<RepeatInterval>("Repeat") {
                $0.title = $0.tag
                $0.options = RepeatInterval.allCases
                $0.value = .Never
                }.onPresent({ (_, vc) in
                    vc.enableDeselection = false
                    vc.dismissOnSelection = false
                })

        form +++

            PushRow<EventAlert>() {
                $0.title = "Alert"
                $0.options = EventAlert.allCases
                $0.value = .Never
                }
                .onChange { [weak self] row in
                    if row.value == .Never {
                        if let second : PushRow<EventAlert> = self?.form.rowBy(tag: "Another Alert"), let secondIndexPath = second.indexPath {
                            row.section?.remove(at: secondIndexPath.row)
                        }
                    }
                    else{
                        guard let _ : PushRow<EventAlert> = self?.form.rowBy(tag: "Another Alert") else {
                            let second = PushRow<EventAlert>("Another Alert") {
                                $0.title = $0.tag
                                $0.value = .Never
                                $0.options = EventAlert.allCases
                            }
                            let secondIndex = row.indexPath!.row + 1
                            row.section?.insert(second, at: secondIndex)
                            return
                        }
                    }
        }

        form +++
            PushRow<EventState>("Show As") {
                $0.title = "Show As"
                $0.options = EventState.allCases
        }

        form +++
            Section(header: "Last Section",
                    footer: .loremIpsum)
            
            <<< URLRow("URL") {
                $0.placeholder = "URL"
            }
            
            <<< TextAreaRow("notes") {
                $0.placeholder = "Notes"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
            }
        
        form +++
            TextAreaRow("last") {
                $0.placeholder = "last"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 50)
                
            }
    }

    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        (navigationController as? NativeEventNavigationController)?.onDismissCallback?(self)
    }

    enum RepeatInterval : String, CaseIterable, CustomStringConvertible {
        case Never = "Never"
        case Every_Day = "Every Day"
        case Every_Week = "Every Week"
        case Every_2_Weeks = "Every 2 Weeks"
        case Every_Month = "Every Month"
        case Every_Year = "Every Year"

        var description : String { return rawValue }
    }

    enum EventAlert : String, CaseIterable, CustomStringConvertible {
        case Never = "None"
        case At_time_of_event = "At time of event"
        case Five_Minutes = "5 minutes before"
        case FifTeen_Minutes = "15 minutes before"
        case Half_Hour = "30 minutes before"
        case One_Hour = "1 hour before"
        case Two_Hour = "2 hours before"
        case One_Day = "1 day before"
        case Two_Days = "2 days before"

        var description : String { return rawValue }
    }

    enum EventState : CaseIterable {
        case busy
        case free
    }
}

extension String {
    static var loremIpsum: String = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer consequat laoreet sem a elementum. Curabitur condimentum scelerisque purus, a tincidunt ligula molestie eget. In hac habitasse platea dictumst. Proin ullamcorper ultrices rhoncus. Nulla eget ante in ligula tristique consectetur quis scelerisque tortor. In sit amet sagittis leo. Vivamus aliquet cursus felis, vitae consectetur nulla. Nullam ipsum lorem, suscipit id consectetur id, luctus in arcu. Proin tincidunt sit amet mauris eget tristique. Etiam finibus dolor sed nulla iaculis lacinia. Pellentesque nec tempor purus, vel feugiat nibh. Cras feugiat vestibulum est, a vehicula neque facilisis vitae. Nunc cursus, augue ac elementum elementum, arcu lectus maximus nunc, eget sollicitudin odio purus eget ex. Curabitur eget scelerisque justo. Morbi a efficitur arcu. Praesent arcu diam, tincidunt quis facilisis ac, luctus eget orci.

Aenean eget interdum mauris. Curabitur purus risus, lobortis venenatis hendrerit non, semper nec eros. Pellentesque lacinia sagittis faucibus. Proin est orci, aliquam ac odio non, lacinia pulvinar diam. Sed orci magna, laoreet in tincidunt non, finibus quis sapien. Duis commodo pretium iaculis. Donec bibendum nisi dui, et volutpat velit porta vel. Donec facilisis sagittis odio nec cursus. Curabitur imperdiet aliquet ante at mattis. Vestibulum facilisis vestibulum dolor tempus placerat. Aliquam dapibus maximus neque, et efficitur felis sagittis at. Duis vitae erat eleifend turpis tincidunt vestibulum ut ut elit. Vivamus ut augue eget ligula laoreet euismod quis non risus.

Curabitur ornare ex magna, et tempus enim laoreet ut. Nulla aliquet, diam vel fringilla sagittis, est est luctus lectus, non faucibus nulla lacus in arcu. Fusce dignissim turpis a ornare maximus. Curabitur auctor malesuada lorem, imperdiet tempor nisl accumsan eget. Ut sed sem tellus. Nam leo felis, eleifend in egestas non, facilisis at ipsum. Integer pharetra turpis vitae nisl dignissim, ut elementum odio ullamcorper. Etiam ut auctor augue. Nunc egestas magna purus. Aenean finibus sem nec augue ornare luctus. Fusce viverra porta est at posuere.

Pellentesque rutrum ipsum dignissim, dapibus elit ac, consectetur massa. Aliquam ut risus semper, sodales ipsum vitae, vehicula tortor. Aliquam convallis euismod tincidunt. Pellentesque id ex leo. Nullam finibus accumsan est at tempus. Cras fringilla tristique ipsum, quis consequat mi porttitor eu. Morbi dapibus odio ut dui facilisis, sed suscipit nisi tincidunt. Sed ornare eros sed mattis viverra. Nulla facilisi. Phasellus at fringilla urna. Integer vestibulum bibendum eros, quis egestas erat mattis vel. Vivamus id posuere sem. Morbi id lacus pretium, blandit dui eu, viverra felis. Cras sed dolor mi. Sed aliquam dictum quam in laoreet. Praesent venenatis finibus dui, in dictum mi gravida ac.
"""
}
