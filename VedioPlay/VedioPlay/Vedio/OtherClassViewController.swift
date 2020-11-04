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
        
        // 一 开两个异步线程,交替打印数字 这样可以保证结果是顺序输出，但保证不了奇线程打印奇数，偶线程打印偶数
       // self.creatLockalloc()
       // self.creatNSCondition()
        
        // 二 RunLoop 参考学习https://blog.ibireme.com/2015/05/18/runloop/
        // 2.1 RunLoop是个对象 ,这个对象管理了需要的对象的事件和消息,并提供一个入口函数来执行Evnet-loop模型的逻辑,线程执行了这个函数后,就会一直一直处于这个函数内部,接收消息 --- 等待 -- 处理  循环中,直到这个循环结束,函数返回
        // 2.2 在macos/ios NSRunLoop和CFRunLoopRef(线程安全,开源)
        // 2.3 runloop和线程关系:CFRunLoop是基于pthread管理的,开发者不能直接创建runloop对象,而是通过CFRunLoopGetMain() 和 CFRunLoopGetCurrent 和线程一一对应 线程刚创建时并没有runloop,需要主动获取,只能在一个线程的内部获取其 RunLoop（主线程除外）
        
        // 2.4 RunLoopRef:线程安全的
        // 2.5 CFRunLoopModeRef:一个RunLopp包含若干Model 每个Model 若干个 Sourece(set)/Timer(array)/Observer(array),每次调用只能调用RunLoop 只能指定其中一个Mode 如果要切换Model,只能退出Loop 在重新进入一个model 一个Sourece(set)/Timer(array)/Observer(array)itme 可以加入多个model,但一个 item 被重复加入同一个 mode 时是不会有效果的。如果一个 mode 中一个 item 都没有，则 RunLoop 会直接退出
        // 2.6 CFRunLoopSourceRef:是事件产生的地方
        
        // 2.7 CFRunLoopTimerRef:基于时间的触发器
        
        // 2.8 CFRunLoopObserverRef:观察者
        
//        struct __CFRunLoopMode {
//            CFStringRef _name;            // Mode Name, 例如 @"kCFRunLoopDefaultMode"
//            CFMutableSetRef _sources0;    // Set
//            CFMutableSetRef _sources1;    // Set
//            CFMutableArrayRef _observers; // Array
//            CFMutableArrayRef _timers;    // Array
//            ...
//        };
//
//        struct __CFRunLoop {
//            CFMutableSetRef _commonModes;     // Set
//            CFMutableSetRef _commonModeItems; // Set<Source/Observer/Timer>
//            CFRunLoopModeRef _currentMode;    // Current Runloop Mode
//            CFMutableSetRef _modes;           // Set
//            ...
//        }
        
        // 2.9 CommonModels:一个Mode的的标记"Common"属性 runloop的内容方式改变时,将 _commonModeItems 里的 Source/Observer/Timer 同步到具有 “Common” 标记的所有Mode里。
        
        // 2.10 RunLoop的内部逻辑:
           //2.10.1 通知observer(观察者),即将进入Loop
           //2.10.2 通知observer,即将处理Timer(定时器)
           //2.10.3 通知observer,即将处理sources0
           //2.10.4 处理sources0
           //2.10.5  如果有source1 跳转到 2.10.9
           // 2.10.6 通知observer 线程即将休眠
           // 2.10.7 休眠等待唤醒 唤醒方式有 1 外部手动唤醒 2  Timer 3 source 0
           // 2.10.8 通知observer,线程被唤醒
           // 2.10.9 处理唤醒的收到的消息,之后返回 2.10.2
           // 2.10.10 通知observer,退出Loop
        
        // 2.11 RunLoop底层实现:RunLoop核心基于mach port 进入休眠调用mach_msg
          /*
             额外了解下iOS/OSX核心框架层
              1 应用层
              2 应用框架层:开发人员主要使用这层的
              3 核心框架层:OpenGL
              4 Darwin 操作系统核心 这层是开源的
 
          */
        
         // 2.12 RunLoop实现的功能
            // 2.12.1 AutoreleasePool: 在ARC 调研模式下怎么使用??? 在App启动是,RunLoop会注册两个Observer,其回调都是_wrapRunLoopWithAutoreleasePoolHandler
        
        
           
        
        
        
        
        
        
        
        
        
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
