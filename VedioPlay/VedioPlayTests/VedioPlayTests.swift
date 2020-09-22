//
//  VedioPlayTests.swift
//  VedioPlayTests
//
//  Created by wenze on 2020/6/12.
//  Copyright © 2020 wenze. All rights reserved.
//

import XCTest
@testable import VedioPlay

class VedioPlayTests: XCTestCase {
    // transultcent
    // translutcent
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
/**
 1、值类型通常被分配在栈上，它的变量直接包含变量的实例，使用效率比较高。
 2、引用类型分配在托管堆上，引用类型的变量通常包含一个指向实例的指针，变量通过该指针来引用实例。
 3、值类型继承自ValueType（注意：而System.ValueType又继承自System.Object）；而引用类型继承自System.Object。
 4、值类型变量包含其实例数据，每个变量保存了其本身的数据拷贝（副本），因此在默认情况下，值类型的参数传递不会影响参数本身；而引用类型变量保存了其数据的引用地址，因此以引用方式进行参数传递时会影响到参数本身，因为两个变量会引用了内存中的同一块地址。
 5、值类型有两种表示：装箱与拆箱；引用类型只有装箱一种形式
 6、典型的值类型为：struct，enum以及大量的内置值类型；而能称为类的都可以说是引用类型。
 7、值类型的内存不由GC（垃圾回收，Gabage Collection）控制，作用域结束时，值类型会自行释放，减少了托管堆的压力，因此具有性能上的优势。例如，通常struct比class更高效；而引用类型的内存回收，由GC来完成，
 8、值类型是密封的（sealed），因此值类型不能作为其他任何类型的基类，但是可以单继承或者多继承接口；而引用类型一般都有继承性。
 9、值类型不具有多态性；而引用类型有多态性。
 10、值类型变量不可为null值，值类型都会自行初始化为0值；而引用类型变量默认情况下，创建为null值，表示没有指向任何托管堆的引用地址。对值为null的引用类型的任何操作，都会抛出NullReferenceException异常。
 11、值类型有两种状态：装箱和未装箱，运行库提供了所有值类型的已装箱形式；而引用类型通常只有一种形式：装箱。
 
 
 */
