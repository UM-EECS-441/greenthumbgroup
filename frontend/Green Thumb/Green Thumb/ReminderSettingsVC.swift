//
//  ReminderSettingsVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 10/23/20.
//

import UIKit

class ReminderSettingsVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushSwitch.isOn = true
        dailySwitch.isOn = false
        weeklySwitch.isOn = false
        monthlySwitch.isOn = false
    }
    
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBAction func pushSwitchChange(_ sender: UISwitch) {
        if sender.isOn {
            dailySwitch.setOn(false, animated: true)
            weeklySwitch.setOn(false, animated: true)
            monthlySwitch.setOn(false, animated: true)
        }
    }
    
    @IBOutlet weak var dailySwitch: UISwitch!
    @IBAction func dailySwitchChange(_ sender: UISwitch) {
        if sender.isOn {
            pushSwitch.setOn(false, animated: true)
            weeklySwitch.setOn(false, animated: true)
            monthlySwitch.setOn(false, animated: true)
        }
    }
    
    @IBOutlet weak var weeklySwitch: UISwitch!
    @IBAction func weeklySwitchChange(_ sender: UISwitch) {
        if sender.isOn {
            dailySwitch.setOn(false, animated: true)
            pushSwitch.setOn(false, animated: true)
            monthlySwitch.setOn(false, animated: true)
        }
    }
    
    @IBOutlet weak var monthlySwitch: UISwitch!
    @IBAction func monthlySwitchChange(_ sender: UISwitch) {
        if sender.isOn {
            dailySwitch.setOn(false, animated: true)
            weeklySwitch.setOn(false, animated: true)
            pushSwitch.setOn(false, animated: true)
        }
    }
}

