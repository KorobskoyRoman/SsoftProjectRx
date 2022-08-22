//
//  RxTraitsTest.swift
//  RxTrainingTests
//
//  Created by Aleksandr on 30/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import RxTraining

class RxTraitsTest: XCTestCase {
    typealias UserInfo = RxTraits.UserInfo
    
    let rxTraits = RxTraits()
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        rxTraits.shouldThrow = false
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil
    }
    
    func testReceiveUserInfo_noError() {
        rxTraits.shouldThrow = false
        
        let realObserver = scheduler.createObserver(UserInfo.self)
        
        rxTraits.receiveUserInfo().asObservable().bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, UserInfo(name: "Test", age: 0)),
            .completed(0)
        ])
    }
    
    func testReceiveUserInfo_hasError() {
        rxTraits.shouldThrow = true
        
        let realObserver = scheduler.createObserver(UserInfo.self)
        
        rxTraits.receiveUserInfo().asObservable().bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .error(0, ExpectedError())
        ])
    }
    
    func testSendAnalytics_noError() {
        rxTraits.shouldThrow = false
        
        let realObserver = scheduler.createObserver(Never.self)
        
        rxTraits.sendAnalytics().asObservable().bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .completed(0)
        ])
    }
    
    func testSendAnalytics_hasError() {
        rxTraits.shouldThrow = true
        
        let realObserver = scheduler.createObserver(Never.self)
        
        rxTraits.sendAnalytics().asObservable().bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .error(0, ExpectedError())
        ])
    }
    
    func testGetNext_value() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxTraits.getNext(afterInt: 3).asObservable().bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 4),
            .completed(0)
        ])
    }
    
    func testGetNext_noValue() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxTraits.getNext(afterInt: 9).asObservable().bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .completed(0)
        ])
    }
    
    func testGetNext_error() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxTraits.getNext(afterInt: 10).asObservable().bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .error(0, ExpectedError())
        ])
    }
    
    func testGetModels() {
        let firstRealObserver = scheduler.createObserver([String].self)
        let secondRealObserver = scheduler.createObserver([String].self)
        
        let models = rxTraits.getModels()
        
        models.drive(firstRealObserver).disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(firstRealObserver.events, [
            .next(0, []),
            .completed(0)
        ])
        
        models.drive(secondRealObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(secondRealObserver.events, [
            .next(0, [""]),
            .completed(0)
        ])
    }
    
    func testFocusPasswordField() {
        let firstRealObserver = scheduler.createObserver(Bool.self)
        let secondRealObserver = scheduler.createObserver(Bool.self)
        
        let focusEvents = rxTraits.focusPasswordField()
        
        focusEvents.emit(to: firstRealObserver).disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(firstRealObserver.events, [
            .next(0, true)
        ])
        
        focusEvents.emit(to: secondRealObserver).disposed(by: disposeBag)
        
        XCTAssertEqual(secondRealObserver.events, [])
    }
}
