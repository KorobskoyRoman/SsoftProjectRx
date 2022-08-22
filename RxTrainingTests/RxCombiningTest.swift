//
//  RxCombiningTest.swift
//  RxTrainingTests
//
//  Created by Aleksandr on 23/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import RxTraining

class RxCombiningTest: XCTestCase {
    let rxCombining = RxCombining()
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

    func testSum() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCombining.sum(
            firstIntObservable: Observable<Int>.of(1, 2, 3, 4, 5, 6),
            secondIntObservable: Observable<Int>.of(10, 20, 30, 40, 50)
        )
        .bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 11),
            .next(0, 22),
            .next(0, 33),
            .next(0, 44),
            .next(0, 55),
            .completed(0)
        ])
    }
    
    func testRequestItems() {
        let realObserver = scheduler.createObserver([String].self)
        
        rxCombining.requestItems(
            searchObservable: scheduler.createHotObservable([
                .next(0, ""),
                .next(10, "b"),
                .next(15, "bear"),
                .next(20, "bearc"),
                .next(35, "be")
            ]).asObservable(),
            categoryObservable: scheduler.createHotObservable([
                .next(5, 0),
                .next(25, 3),
                .next(30, 2)
            ]).asObservable()
        )
        .bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(100)
        
        XCTAssertEqual(realObserver.events, [
            .next(5, ["cat", "dog", "bear", "bearcat", "catfish", "dogfish", "fish"]),
            .next(10, ["bear", "bearcat"]),
            .next(15, ["bear", "bearcat"]),
            .next(20, ["bearcat"]),
            .next(25, []),
            .next(30, []),
            .next(35, ["bed"])
        ])
    }
    
    func testComposition() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCombining.composition(
            intObservable1: scheduler.createHotObservable([
                .next(10, 1),
                .next(30, 3),
                .completed(35)
            ]).asObservable(),
            intObservable2: scheduler.createHotObservable([
                .next(15, 2),
                .next(40, 4),
                .completed(45)
            ]).asObservable()
        )
        .bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(50)
        
        XCTAssertEqual(realObserver.events, [
            .next(10, 1),
            .next(15, 2),
            .next(30, 3),
            .next(40, 4),
            .completed(45)
        ])
    }
    
    func testPrependItem() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCombining
            .prependItem(1, toObservable: scheduler.createHotObservable([
                .next(5, 2),
                .next(10, 3)
            ]).asObservable()
        )
        .bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(50)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(5, 2),
            .next(10, 3)
        ])
    }
    
    func testSwitchWhenNeeded() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCombining.switchWhenNeeded(
            source: scheduler.createHotObservable([
                .next(0, 1),
                .next(5, 2),
                .next(20, -999),
                .completed(25)
            ]).asObservable(),
            another: scheduler.createHotObservable([
                .next(10, 3),
                .next(15, 4),
                .next(30, 5),
                .completed(30)
            ]).asObservable()
        )
        .bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(50)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(5, 2),
            .next(10, 3),
            .next(15, 4),
            .next(30, 5),
            .completed(30)
        ])
    }
}
