//
//  RxErrorTest.swift
//  RxTrainingTests
//
//  Created by Aleksandr on 30/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxCocoa
import RxTest
@testable import RxTraining

class RxErrorTest: XCTestCase {
    let rxError = RxError()
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
    
    func testHandleErrorWithDefault_hasError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxError.handleErrorWithDefault(
            source: Observable<Int>.of(1 , 2, 3).concat(Observable<Int>.error(ExpectedError())),
            defaultValue: 13
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(0, 2),
            .next(0, 3),
            .next(0, 13),
            .completed(0)
        ])
    }
    
    func testHandleErrorWithDefault_noError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxError.handleErrorWithDefault(
            source: Observable<Int>.of(1,2,3),
            defaultValue: 13
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(0, 2),
            .next(0, 3),
            .completed(0)
        ])
    }
    
    func testIfErrorThenSwitch_hasError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxError.ifErrorThenSwitch(
            source: Observable<Int>.of(1, 2, 3).concat(Observable<Int>.error(ExpectedError())),
            onError: .of(999, 1000)
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(0, 2),
            .next(0, 3),
            .next(0, 999),
            .next(0, 1000),
            .completed(0)
        ])
    }
    
    func testIfErrorThenSwitch_noError() {
        let realObserver = scheduler.createObserver(Int.self)
        
        rxError.ifErrorThenSwitch(
            source: Observable<Int>.of(3, 4, 5),
            onError: .of(999, 1000)
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 3),
            .next(0, 4),
            .next(0, 5),
            .completed(0)
        ])
    }
    
    func testTryIfNeeded_fixableError() {
        let realObserver = scheduler.createObserver(Int.self)
        var throwError = true
        
        rxError.tryIfNeeded(source: Observable<Int>.create { observer in
            observer.onNext(1)
            observer.onNext(2)
            if throwError {
                throwError = false
                observer.onError(FixableError.fixable)
                
                return Disposables.create()
            }
            observer.onNext(3)
            observer.onCompleted()
            
            return Disposables.create()
        }).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(0, 2),
            .next(0, 1),
            .next(0, 2),
            .next(0, 3),
            .completed(0)
        ])
    }
    
    func testTryIfNeeded_nonFixableError() {
        let realObserver = scheduler.createObserver(Int.self)
        var fixableError = true
        
        rxError.tryIfNeeded(source: Observable<Int>.create { observer in
            observer.onNext(1)
            observer.onNext(2)
            if fixableError {
                fixableError = false
                observer.onError(FixableError.fixable)
                
                return Disposables.create()
            }
            fixableError = false
            observer.onError(FixableError.nonFixable)
            
            return Disposables.create()
        }).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 1),
            .next(0, 2),
            .next(0, 1),
            .next(0, 2),
            .error(0, FixableError.nonFixable)
        ])
    }
    
    func testTryUntil() {
        let realObserver = scheduler.createObserver(Int.self)
        var nextNumber = 0
        
        rxError.tryUntil(
            source: Observable<Int>.create { observer in
                nextNumber += 1
                observer.onNext(nextNumber)
                
                if nextNumber == 5 {
                    observer.onCompleted()
                }
                
                return Disposables.create()
            },
            filter: { $0 == 5 }
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        XCTAssertEqual(realObserver.events, [
            .next(0, 5),
            .completed(0)
        ])
    }
}
