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
    var thread:HunterThread?
    var time:DispatchSourceTimer?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 一 开两个异步线程,交替打印数字 这样可以保证结果是顺序输出，但保证不了奇线程打印奇数，偶线程打印偶数
        
       // self.creatNSCondition()
        
        
        
        // 二 RunLoop 参考学习https://blog.ibireme.com/2015/05/18/runloop/
        // 2.1 RunLoop是个对象 ,这个对象管理了需要的对象的事件和消息,并提供一个入口函数来执行Evnet-loop模型的逻辑,线程执行了这个函数后,就会一直一直处于这个函数内部,接收消息 --- 等待 -- 处理  循环中,直到这个循环结束,函数返回 在main函数会开启个Runloop
        
        //作用:
         //2.1.1 保证程序不退出
         // 2.1.1 负责监听事件 触摸/时钟事件  网络事件
        //Timer.init(timeInterval: 1, target: self, selector: #selector(timeAction), userInfo: nil, repeats: true)  不会调用
        
       // Timer.scheduledTimer(timeInterval: <#T##TimeInterval#>, target: <#T##Any#>, selector: <#T##Selector#>, userInfo: <#T##Any?#>, repeats: <#T##Bool#>) ====  RunLoop.current.add(Timer.init(timeInterval: 1, target: self, selector: #selector(timeAction), userInfo: nil, repeats: true), forMode: .default)
       
        // 让当前runloop监听
//        RunLoop.current.add(Timer.init(timeInterval: 1, target: self, selector: #selector(timeAction), userInfo: nil, repeats: true), forMode: .default)
        
        // 在子线程中执行Timer demo演示
        
        if #available(iOS 10.0, *) {
            // 1  线程对象释放了
           let thread =   HunterThread.init {
               
                RunLoop.current.add(Timer.init(timeInterval: 1, target: self, selector: #selector(self.timeAction), userInfo: nil, repeats: true), forMode: .default)
            }
             
            thread.start()
            
            DispatchQueue.global().async {
                RunLoop.current.add(Timer.init(timeInterval: 1, target: self, selector: #selector(self.timeAction), userInfo: nil, repeats: true), forMode: .default)
            }
            
            // 2 释放了 保活对象,但线程已经挂起
            
//            self.thread =   HunterThread.init {
//                 RunLoop.current.add(Timer.init(timeInterval: 1, target: self, selector: #selector(self.timeAction), userInfo: nil, repeats: true), forMode: .default)
//             }
//
//            self.thread?.start()
            
            
            // 3 保活线程,添加一个死循环 runloop 本身就是一个循环,在子线程中,需要手动开启,主线程中系统在UIApplicationMain中已经被开启,关闭线程任务:1 做个标记将RunLoop停止调动,2 将线程关闭
                
            
            self.thread =   HunterThread.init {
                
//                while(true){
//                   // RunLoop.current.add(Timer.init(timeInterval: 1, target: self, selector: #selector(self.timeAction), userInfo: nil, repeats: true), forMode: .default)
//                }
                
                RunLoop.current.add(Timer.init(timeInterval: 1, target: self, selector: #selector(self.timeAction), userInfo: nil, repeats: true), forMode: .default)
                // 开启runloop
                RunLoop.current.run()
                
                print("不会执行这个打印,除非RunLoop.current.run()停止")
              
             }
              
            self.thread?.start()
            
            

            
            
        } else {
            // Fallback on earlier versions
        }
        
        
        // 使用CCD 创建一个定时器 dispatch_source_set_timer  不受model影响
        
        self.time = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        // milliseconds 毫秒  repeating 间隔的时间， leeway以及剩余持续的时间
        self.time?.schedule(deadline: .now(), repeating: DispatchTimeInterval.milliseconds(20), leeway: DispatchTimeInterval.milliseconds(2000))
        
        self.time?.setEventHandler(handler: {
            print("你好 定时器")
        })
        
        if #available(iOS 10.0, *) {
            self.time?.activate()
        } else {
            // Fallback on earlier versions
            
            self.time?.resume()
        };
        
        
        
        
        
        
        
        
        
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
            
             // 2.12.2 事件响应: Source1 用来接收系统事件 当一个硬件事件发生后,由IOKit.framework生成一个IOHIDEvent事件并由SpringBoard接收,SpringBoard只接收按键,触摸等,然后使用mach_port转发给需要进程的App,随后Source1触发回调,_UIAppLicationHandelEventQueue进行内部分发,_UIAppLicationHandelEventQueue会将IOHIDEvent事件封装成UIEvnet进行处理分发
               
             // 2.12.3 手势识别 _UIAppLicationHandelEventQuenue识别,识别一个手势

        
       
        
             // 2.12.4 界面更新
             // 2.12.5 定时器:
             // 2.12.6 PerformSelecter
             //
           
        self.creatLockalloc()
    }
    
    
    /// 使用lock实现 条件锁
    func creatLockalloc(){
        
        // 定义个GCD 队列  initiallyInactive
        let queue = DispatchQueue.init(label: "com.thread.OtherClassViewController", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        //let queue = DispatchQueue.init(label: "com.thread.OtherClassViewController")
        let  lock = NSLock.init()
        #if DEBUG
       // print(Thread.current)
        #else
        #endif
        queue.async {
            
           // print(Thread.current)
            #if DEBUG
                   print("async +\(Thread.current)")
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
    
    
    @objc func timeAction(){
        
        // 关闭这个子线程,这种方式很极端 但不会影响主线程和其他子线程的执行,在主线程禁止使用这种方式
        Thread.exit()
        
        print(Thread.current)
        HunterThread.sleep(forTimeInterval: 1)
        print("定时器")
    }
    
    /// iOS消息转发机制
    
    func messageReceiver(){
        
        // 参考 https://blog.ibireme.com/2013/11/26/objective-c-messaging/
        // 1 使用clang命令 :打开Xcode 在菜单栏 File->New->Project->OS X->Command Line Tool创建一个Command Line Tool工程，
            //打开终端，拿到这个工程的路径， cd 加你的工程名
           // 输入clang -rewrite-objc 你的.c文件或.m文件
            //就出来.cpp文件，即中间代码
//        'UIKit/UIKit.h' file not found
//       #import <UIKit/UIKit.h>
//        clang -rewrite-objc AppDelegate.swift
//        clang: warning: AppDelegate.swift: 'linker' input unused [-Wunused-command-line-argument]

//               ^~~~~~~~~~~~~~~
        
        // 2 objc_msgSend(id self, SEL _cmd, ...) 方法
        // self 消息的接受者
        // _cmd  SEL 可变参数
        
        
        
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
