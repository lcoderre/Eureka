//
//  VanillaTableViewController.swift
//  Example
//
//  Created by Laurens Coderre on 2020-10-30.
//  Copyright © 2020 Xmartlabs. All rights reserved.
//

import Foundation
import UIKit


class VanillaTableViewController: UITableViewController {
    
    // change me to .top
    var position: UITableView.ScrollPosition = .none
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return .loremIpsum
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = indexPath.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: position, animated: true)
    }
    
}
