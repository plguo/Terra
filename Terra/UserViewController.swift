//
//  UserViewController.swift
//  Terra
//
//  Created by Edward Guo on 2017-03-12.
//  Copyright © 2017 Terra Inc. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UINavigationBarDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    var screenEdgeRecognizer: UIScreenEdgePanGestureRecognizer!
    
    let rewards = [
        ["AAA Battery", "+1"],
        ["Bottled Water", "+2"],
        ["Coffee Cup", "+1"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navbar.delegate = self
        self.navbar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        
        tableView.dataSource = self
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewards.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = rewards[indexPath.row][0]
        cell.detailTextLabel?.text = rewards[indexPath.row][1]
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
