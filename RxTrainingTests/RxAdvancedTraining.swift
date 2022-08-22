//
//  RxAdvancedTraining.swift
//  RxTrainingTests
//
//  Created by Aleksandr on 30/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import RxTraining

class RxAdvancedTraining: XCTestCase {
    typealias Toggler = RxAdvanced.Toggler
    
    let rxAdvanced = RxAdvanced()
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
    
    func testUpdateByIdSignal() {
        let realObserver = scheduler.createObserver([Toggler].self)
        
        rxAdvanced.update(
            source: .of([
                Toggler(id: 0, enabled: false),
                Toggler(id: 1, enabled: false),
                Toggler(id: 2, enabled: false),
                Toggler(id: 3, enabled: false),
                Toggler(id: 4, enabled: false)
            ]),
            byIdSignal: scheduler.createColdObservable([
                .next(10, 2),
                .next(20, 4),
                .next(30, 0),
                .next(40, 2)
            ]).asObservable()
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events.last!,
            .next(0, [
                Toggler(id: 0, enabled: false),
                Toggler(id: 1, enabled: false),
                Toggler(id: 2, enabled: false),
                Toggler(id: 3, enabled: false),
                Toggler(id: 4, enabled: false)
            ])
        )
        
        scheduler.advanceTo(15)
        
        XCTAssertEqual(realObserver.events.last!,
            .next(10, [
                Toggler(id: 0, enabled: false),
                Toggler(id: 1, enabled: false),
                Toggler(id: 2, enabled: true),
                Toggler(id: 3, enabled: false),
                Toggler(id: 4, enabled: false)
            ])
        )
        
        scheduler.advanceTo(25)
        
        XCTAssertEqual(realObserver.events.last!,
            .next(20, [
                Toggler(id: 0, enabled: false),
                Toggler(id: 1, enabled: false),
                Toggler(id: 2, enabled: true),
                Toggler(id: 3, enabled: false),
                Toggler(id: 4, enabled: true)
            ])
        )
        
        scheduler.advanceTo(35)
        
        XCTAssertEqual(realObserver.events.last!,
            .next(30, [
                Toggler(id: 0, enabled: true),
                Toggler(id: 1, enabled: false),
                Toggler(id: 2, enabled: true),
                Toggler(id: 3, enabled: false),
                Toggler(id: 4, enabled: true)
            ])
        )
        
        scheduler.advanceTo(45)
        
        XCTAssertEqual(realObserver.events.last!,
            .next(40, [
                Toggler(id: 0, enabled: true),
                Toggler(id: 1, enabled: false),
                Toggler(id: 2, enabled: false),
                Toggler(id: 3, enabled: false),
                Toggler(id: 4, enabled: true)
            ])
        )
    }
    
    func testSumLast() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxAdvanced.sumLast(
            fromObservable: scheduler.createHotObservable([
                .next(0, 1),
                .next(10, 2),
                .next(20, 3),
                .next(40, 4),
                .next(50, -13),
                .next(60, 77),
                .next(70, 8),
                .error(80, ExpectedError())
            ]).asObservable(),
            bySignal: scheduler.createHotObservable([
                .next(5, ()),
                .next(25, ()),
                .next(45, ()),
                .next(55, ()),
                .next(75, ()),
                .next(85, ())
            ]).asObservable(),
            scheduler: scheduler
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(100)
        
        XCTAssertEqual(realObserver.events, [
            .next(45, 8),
            .next(85, 8),
            .completed(85)
        ])
    }
    
    func testCompareLast() {
        let realObserver = scheduler.createObserver(Bool.self)
        
        rxAdvanced.compareLast(source: .of(1, 2, 5, 4, 3, 10))
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, true),
            .next(0, true),
            .next(0, false),
            .next(0, false),
            .next(0, true),
            .completed(0)
        ])
    }
    
    func testMaxIndex() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxAdvanced.maxIndex(source: .of(-1000, 5, -300, 12, 50, -4234, 43))
            .asObservable()
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 4),
            .completed(0)
        ])
    }
    
    func testMaxIndex_noElements() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxAdvanced.maxIndex(source: .empty())
            .asObservable()
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .completed(0)
        ])
    }
    
    func testMaxIndex_intMinElement() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxAdvanced.maxIndex(source: .of(Int.min))
            .asObservable()
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 0),
            .completed(0)
        ])
    }
    
    func testMultipleRequest() {
        let realObserver = scheduler.createObserver([String].self)
        
        var requestCount = 0
        
        rxAdvanced.multipleRequest(
            bySignal: scheduler.createHotObservable([
                .next(0, ()),
                .next(5, ()),
                .next(10, ()),
                .completed(10)
            ]).asObservable(),
            request: Observable<[String]>.create { observer in
                switch requestCount {
                case 0: observer.onNext(["A", "B", "C"])
                case 2: observer.onNext(["G", "H", "I"])
                case 1: observer.onNext(["D", "E", "F"])
                default: observer.onError(ExpectedError())
                }
                
                observer.onCompleted()
                
                requestCount += 1
                
                return Disposables.create()
            }.delay(RxTimeInterval.seconds(9), scheduler: scheduler)
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(10)
        
        XCTAssertEqual(realObserver.events, [])
        
        scheduler.advanceTo(15)
        
        XCTAssertEqual(realObserver.events, [])
        
        scheduler.advanceTo(100)
        
        XCTAssertEqual(realObserver.events, [
            .next(20, ["A", "B", "C", "D", "E", "F", "G", "H", "I"]),
            .completed(20)
        ])
    }
    
    func testMultipleRequest_notCompletedSignal() {
        let realObserver = scheduler.createObserver([String].self)
        
        var requestCount = 0
        
        rxAdvanced.multipleRequest(
            bySignal: scheduler.createHotObservable([
                .next(0, ()),
                .next(5, ()),
                .next(10, ())
            ]).asObservable(),
            request: Observable<[String]>.create { observer in
                switch requestCount {
                case 0: observer.onNext(["A", "B", "C"])
                case 2: observer.onNext(["G", "H", "I"])
                case 1: observer.onNext(["D", "E", "F"])
                default: observer.onError(ExpectedError())
                }
                
                observer.onCompleted()
                
                requestCount += 1
                
                return Disposables.create()
            }.delay(RxTimeInterval.seconds(9), scheduler: scheduler)
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(10)
        
        XCTAssertEqual(realObserver.events, [])
        
        scheduler.advanceTo(15)
        
        XCTAssertEqual(realObserver.events, [])
        
        scheduler.advanceTo(100)
        
        XCTAssertEqual(realObserver.events, [])
    }
    
    func testMultipleRequest_slowSignalsWithFastRequests() {
        let realObserver = scheduler.createObserver([String].self)
        
        var requestCount = 0
        
        rxAdvanced.multipleRequest(
            bySignal: scheduler.createHotObservable([
                .next(0, ()),
                .next(5, ()),
                .next(10, ()),
                .completed(10)
            ]).asObservable(),
            request: Observable<[String]>.create { observer in
                switch requestCount {
                case 0: observer.onNext(["A", "B", "C"])
                case 2: observer.onNext(["G", "H", "I"])
                case 1: observer.onNext(["D", "E", "F"])
                default: observer.onError(ExpectedError())
                }
                
                observer.onCompleted()
                
                requestCount += 1
                
                return Disposables.create()
            }
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(5)
        
        XCTAssertEqual(realObserver.events, [])
        
        scheduler.advanceTo(9)
        
        XCTAssertEqual(realObserver.events, [])
        
        scheduler.advanceTo(10)
        
        XCTAssertEqual(realObserver.events, [
            .next(10, ["A", "B", "C", "D", "E", "F", "G", "H", "I"]),
            .completed(10)
        ])
    }
}
