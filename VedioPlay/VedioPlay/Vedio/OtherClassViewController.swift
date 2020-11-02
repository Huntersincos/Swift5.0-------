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
       // self.creatLockalloc()
       // self.creatNSCondition()
        
        // 2 RunLoop 参考https://blog.ibireme.com/2015/05/18/runloop/
        // 2.1 RunLoop是个对象 ,这个对象管理了需要的对象的事件和消息,并提供一个入口函数来执行Evnet-loop模型的逻辑,线程执行了这个函数后,就会一直一直处于这个函数内部,接收消息 --- 等待 -- 处理  循环中,直到这个循环结束,函数返回
        // 2.2 在macos/ios NSRunLoop和CFRunLoopRef(线程安全,开源)
        // 2.3 runloop和线程关系:CFRunLoop是基于pthread管理的,开发者不能直接创建runloop对象,而是通过CFRunLoopGetMain() 和 CFRunLoopGetCurrent 和线程一一对应 线程刚创建时并没有runloop,需要主动获取,只能在一个线程的内部获取其 RunLoop（主线程除外）
        
        
        
        
        
        
    }
    
    
    /// 使用lock实现 条件锁
    func creatLockalloc(){
        
        // 定义个GCD 队列  initiallyInactive
        let queue = DispatchQueue.init(label: "com.thread.OtherClassViewController", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        //let queue = DispatchQueue.init(label: "com.thread.OtherClassViewController")
        let  lock = NSLock.init()
        #if DEBUG
        print(Thread.current)
        #else
        #endif
        queue.async {
            
            #if DEBUG
                   print(Thread.current)
                   #else
                   #endif
            while self.numberOne < 100{
                lock.lock()
//                #if DEBUG
//                print("奇线程\(self.numberOne)")
//                #else
//                #endif
                self.numberOne += 1
                lock.unlock()
            }
        }
        
        queue.async {
            #if DEBUG
                   print(Thread.current)
                   #else
                   #endif
            while self.numberOne < 100 {
               lock.lock()
//                #if DEBUG
//                print("偶线程\(self.numberOne)")
//                #else
//                #endif
                self.numberOne += 1
                lock.unlock()
                
            }
        }
        
    }
    
    func creatNSCondition(){
        
        let  queue = DispatchQueue.init(label: "com.thread.creatNSCondition", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        let conditionLock = NSCondition.init()
        queue.async {
            while self.numberTwo < 100{
                conditionLock.lock()
                if self.numberTwo%2 != 0 {
                    #if DEBUG
                        print("奇线程\(self.numberTwo)")
                       #else
                       #endif
                }
                
                if self.numberTwo%2 != 0 {
                    conditionLock.signal()
                    conditionLock.wait()
                }
                self.numberTwo += 1
                conditionLock.unlock()
            }
            
            
        }
        
        queue.async {
            while self.numberTwo < 100{
                conditionLock.lock()
                if self.numberTwo%2 == 0 {
                    #if DEBUG
                     print("偶线程\(self.numberTwo)")
                    #else
                    #endif
                }
                
                if self.numberTwo%2 == 0 {
                    conditionLock.signal()
                    conditionLock.wait()
                }
                self.numberTwo += 1
                conditionLock.unlock()
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
