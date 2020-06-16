//
//  ViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
/**
 采集视频资源
   1 在相册中
   2 在相机中
*/
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    let array = ["相册","相机"]
    @IBOutlet weak var dataTabView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .orange
        title = "采集"
        self.tabBarItem.title = "采集"
    
        
    }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return array.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           //HomePageTabveiwCellID
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePageTabveiwCellID", for: indexPath)
        let title = array[indexPath.row]
        cell.textLabel?.text = title
        return cell
          
        
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


}

