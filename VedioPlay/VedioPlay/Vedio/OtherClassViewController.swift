//
//  OtherClassViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/9/25.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit

class OtherClassViewController: UIViewController {

    var numberOne = 0
    var numberTwo = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 1 开两个异步线程,交替打印数字 这样可以保证结果是顺序输出，但保证不了奇线程打印奇数，偶线程打印偶数
        self.creatLockalloc()
        
    }
    
    
    /// 使用lock实现 条件锁
    func creatLockalloc(){
        
        // 定义个GCD 队列
        let queue = DispatchQueue.init(label: "com.thread.OtherClassViewController", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        //let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        let  lock = NSLock.init()
        queue.async {
            while self.numberOne < 100{
                lock.lock()
                #if DEBUG
                print("奇线程\(self.numberOne)")
                #else
                #endif
                self.numberOne += 1
                lock.unlock()
            }
        }
        
        queue.async {
            while self.numberOne < 100 {
                lock.lock()
                #if DEBUG
                print("偶线程\(self.numberOne)")
                #else
                #endif
                self.numberOne += 1
                lock.unlock()
                
            }
        }
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
