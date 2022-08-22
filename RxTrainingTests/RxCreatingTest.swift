//
//  RxCreatingTest.swift
//  RxTrainingTests
//
//  Created by Aleksandr on 25/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
@testable import RxTraining

class RxCreatingTest: XCTestCase {
    let rxCreating = RxCreating()
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        rxCreating.someService = RxCreating.SomeService()
    }

    override func tearDown() {
        scheduler = nil
        disposeBag = nil
    }

    func testConvertToObservablePositiveValue() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCreating.convertToObservable(value: 10)
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 10),
            .completed(0)
        ])
    }
    
    func testConvertToObservableNegativeValue() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCreating.convertToObservable(value: -10)
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, -10)
        ])
    }
    
    func testArrayToObservable() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCreating.arrayToObservable([1, 2, 3, 4, 5])
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(0, 2),
            .next(0, 3),
            .next(0, 4),
            .next(0, 5),
            .completed(0)
        ])
    }
    
    func testArrayToObservableWithTimer() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxCreating.arrayToObservableWithTimer([1, 2, 3, 4, 5], scheduler: scheduler)
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        scheduler.advanceTo(10)
        
        XCTAssertEqual(realObserver.events, [
            .next(1, 1),
            .next(2, 2),
            .next(3, 3),
            .next(4, 4),
            .next(5, 5),
            .completed(5)
        ])
    }
    
    func testExpensiveMethodResult() {
        let realObserver = scheduler.createObserver(Int.self)
        
        let testObservable = rxCreating.expensiveMethodResult()
        
        scheduler.start()
        
        XCTAssertFalse(rxCreating.someService.wasExpensiveMethodCalled)
        
        testObservable.bind(to: realObserver).disposed(by: disposeBag)
        
        XCTAssertTrue(rxCreating.someService.wasExpensiveMethodCalled)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, Int.max),
            .completed(0)
        ])
    }
    
    func testCombinationExpensiveMethodsNoError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        let testObservable = rxCreating.combinationExpensiveMethods(unstableCondition: true)
        
        XCTAssertFalse(rxCreating.someService.wasExpensiveMethodCalled)
        XCTAssertFalse(rxCreating.someService.wasAnotherExpensiveMethodCalled)
        XCTAssertFalse(rxCreating.someService.unstableMethodCalled)

        testObservable.bind(to: realObserver).disposed(by: disposeBag)
        
        scheduler.start()

        XCTAssertTrue(rxCreating.someService.wasExpensiveMethodCalled)
        XCTAssertTrue(rxCreating.someService.wasAnotherExpensiveMethodCalled)
        XCTAssertTrue(rxCreating.someService.unstableMethodCalled)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, Int.max),
            .next(0, Int.min),
            .error(0, ExpectedError())
        ])
    }
    
    func testCombinationExpensiveMethodsHasError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        let testObservable = rxCreating.combinationExpensiveMethods(unstableCondition: false)
        
        XCTAssertFalse(rxCreating.someService.wasExpensiveMethodCalled)
        XCTAssertFalse(rxCreating.someService.wasAnotherExpensiveMethodCalled)
        XCTAssertFalse(rxCreating.someService.unstableMethodCalled)

        testObservable.bind(to: realObserver).disposed(by: disposeBag)
        
        scheduler.start()

        XCTAssertTrue(rxCreating.someService.wasExpensiveMethodCalled)
        XCTAssertTrue(rxCreating.someService.wasAnotherExpensiveMethodCalled)
        XCTAssertTrue(rxCreating.someService.unstableMethodCalled)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, Int.max),
            .next(0, Int.min),
            .next(0, 0)
        ])
    }
}
