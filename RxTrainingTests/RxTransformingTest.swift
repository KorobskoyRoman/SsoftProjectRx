//
//  RxTransformingTest.swift
//  RxTrainingTests
//
//  Created by Aleksandr on 27/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxCocoa
import RxTest
@testable import RxTraining

class RxTransformingTest: XCTestCase {
    typealias Entity = RxTransforming.Entity
    
    let rxTransforming = RxTransforming()
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
    
    func testTransformIntToString() {
        let realObserver = scheduler.createObserver(String.self)

        rxTransforming.transformIntToString(source: .of(1,2,3,4,5))
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, "1"),
            .next(0, "2"),
            .next(0, "3"),
            .next(0, "4"),
            .next(0, "5"),
            .completed(0)
        ])
    }
    
    func testLoadEntityById() {
        let realObserver = scheduler.createObserver(Entity.self)
        
        rxTransforming.loadEntityById(idObservable: .of(1, 2, 3))
            .bind(to: realObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, Entity(id: 1)),
            .next(0, Entity(id: 2)),
            .next(0, Entity(id: 3)),
            .completed(0)
        ])
    }
    
    func testDistributeNamesByFirstLetter() {
        struct Pair: Equatable {
            let first: Character
            let second: String
        }
        
        let realObserver = scheduler.createObserver(Pair.self)
        
        rxTransforming.distributeNamesByFirstLetter(
            source: .of("Ashley", "Bobby", "Ashking", "Charles")
        ).flatMap { pair in pair.map { Pair(first: pair.key, second: $0) } }
        .bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(realObserver.events, [
            .next(0, Pair(first: Character("A"), second: "Ashley")),
            .next(0, Pair(first: Character("B"), second: "Bobby")),
            .next(0, Pair(first: Character("A"), second: "Ashking")),
            .next(0, Pair(first: Character("C"), second: "Charles")),
            .completed(0)
        ])
    }
    
    func testAggregateIntoArrays() {
        let realObserver = scheduler.createObserver([Int].self)
        
        rxTransforming.aggregateIntoArrays(
            source: scheduler.createColdObservable([
                .next(0, 1),
                .next(10, 2),
                .next(50, 3),
                .next(100, 4),
                .next(1000, 5),
                .next(1001, 6),
                .next(5000, 7),
                .completed(5000)
            ]).asObservable(),
            count: 5,
            scheduler: scheduler
        ).bind(to: realObserver)
        .disposed(by: disposeBag)
        
        scheduler.advanceTo(5000)
        
        XCTAssertEqual(realObserver.events, [
            .next(1000, [1, 2, 3, 4, 5]),
            .next(5000, [6, 7]),
            .completed(5000)
        ])
    }
}
