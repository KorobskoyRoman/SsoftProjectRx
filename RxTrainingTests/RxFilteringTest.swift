//
//  RxFilteringTest.swift
//  RxTrainingTests
//
//  Created by Aleksandr on 26/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import RxTraining

class RxFilteringTest: XCTestCase {
    let rxFiltering = RxFiltering()
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil
    }
    
    func testFirstValueWithCondition() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxFiltering.firstValueWithCondition(
            source: .of(3, 2, 1, 0, -1, -2, -3),
            condition: { $0 < 0 }
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, -1),
            .completed(0)
        ])
    }
    
    func testFirstValueWithCondition_noValues() {
        let realObserver = scheduler.createObserver(String.self)
        
        rxFiltering.firstValueWithCondition(
            source: .of("aaa", "bbbb", "ccc", "edfg"),
            condition: { $0.count == 2 }
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .completed(0)
        ])
    }
    
    func testPickFirstValues() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxFiltering.pickFirstValues(
            source: .of(1, 2, 3, 4, 5),
            pickFirstValuesCount: 2,
            notPickFirstValuesCount: 1
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 2),
            .next(0, 3),
            .completed(0)
        ])
    }
    
    func testPickFirstValues_oneValue() {
        let realObserver = scheduler.createObserver(String.self)
        
        rxFiltering.pickFirstValues(
            source: .of("a", "b", "c"),
            pickFirstValuesCount: 5,
            notPickFirstValuesCount: 2
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, "c"),
            .completed(0)
        ])
    }
    
    func testTakeLastWithDuration() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxFiltering.takeLastWithDuration(
            source: scheduler.createColdObservable([
                .next(0, 1),
                .next(1, 2),
                .next(5, 3),
                .next(10, 4),
                .next(11, 5),
                .next(15, 99)
            ]).asObservable(),
            scheduler: scheduler,
            interval: DispatchTimeInterval.seconds(10)
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(20)
        
        XCTAssertEqual(realObserver.events, [
            .next(10, 3),
            .completed(10)
        ])
    }
    
    func testIgnoreDublicatesWithWaitingError_noError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxFiltering.ignoreDublicatesWithWaitingError(
            source: scheduler.createColdObservable([
                .next(0, 1),
                .next(1, 1),
                .next(5, 3),
                .next(10, 4),
                .next(11, 4),
                .next(15, 4),
                .completed(15)
            ]).asObservable(),
            waitingTime: DispatchTimeInterval.seconds(5),
            scheduler: scheduler
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(20)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(5, 3),
            .next(10, 4),
            .completed(15)
        ])
    }
    
    func testIgnoreDublicatesWithWaitingError_hasError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxFiltering.ignoreDublicatesWithWaitingError(
            source: scheduler.createColdObservable([
                .next(0, 1),
                .next(1, 1),
                .next(5, 3),
                .next(10, 4),
                .next(11, 4),
                .next(15, 4),
                .next(21, 5),
                .next(22, 5),
                .completed(22)
            ]).asObservable(),
            waitingTime: DispatchTimeInterval.seconds(5),
            scheduler: scheduler
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(20)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(5, 3),
            .next(10, 4),
            .error(15, RxError.timeout)
        ])
    }
    
    func testSearchWhenFinishedTyping() {
        let realObserver = scheduler.createObserver([String].self)
        
        rxFiltering.searchWhenFinishedTyping(
            searchStringObservable: scheduler.createColdObservable([
                .next(0, "p"),
                .next(101, "po"),
                .next(120, "por"),
                .next(221, "porr"),
                .next(322, "co"),
                .next(423, "")
            ]).asObservable(),
            waitingTime: DispatchTimeInterval.seconds(100),
            scheduler: scheduler
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(1000)
        
        XCTAssertEqual(realObserver.events, [
            .next(100, ["popcorn", "porridge", "pork", "portal"]),
            .next(220, ["porridge", "pork", "portal"]),
            .next(321, ["porridge"]),
            .next(422, ["unicorns", "popcorn", "corn"]),
            .next(523, [])
        ])
    }
    
    func testReleaseElementWhenSwitched() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxFiltering.releaseElementWhenSwitched(
            source: scheduler.createColdObservable([
                .next(0, 1),
                .next(10, 2),
                .next(20, 3),
                .next(30, 4),
                .next(40, 5),
                .next(50, 6),
                .next(60, 7),
                .next(70, 8)
            ]).asObservable(),
            switcher: scheduler.createColdObservable([
                .next(5, false),
                .next(15, true),
                .next(16, false),
                .next(17, true),
                .next(35, false),
                .next(45, false),
                .next(55, false),
                .next(65, true),
                .next(95, true)
            ]).asObservable()
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(100)
        
        XCTAssertEqual(realObserver.events, [
            .next(15, 2),
            .next(65, 7)
        ])
    }
}
