//
//  RxCreating.swift
//  RxTraining
//
//  Created by Aleksandr on 25/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

class RxCreating {
    var someService = SomeService()
    /**
     Преобразует элемент в последовательность.
     Если элемент меньше 0, то эмитится только это число и последовательность НЕ завершается.
     Иначе эмитится этот элемент и последовательность завершается.
     - parameter value: Значение, которое должно быть преобразовано в последовательность
     - returns: Результирующая последовательность с value
    */
    func convertToObservable(value: Int) -> Observable<Int> {
        Observable<Int>.create { obs in
            if value <= 0 {
                obs.onNext(value)
            } else {
                obs.onNext(value)
                obs.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    /**
     Преобразует элементы массива в последовательность этих же элементов, последовательность должна завершиться Completed.
     - parameter array: Массив, который должен быть преобразован в последовательность
     - returns: Результирующая последовательность с элементами массива
    */
    func arrayToObservable<T>(_ array: [T]) -> Observable<T> {

        let obs = Observable<T>.create { el in
            array.forEach { el.onNext($0) }
            el.onCompleted()
            return Disposables.create()
        }
        return obs
    }
    
    /**
     Преобразует элементы массива в последовательность этих же элементов, последовательность должна завершиться Completed.
     Каждый элемент должен эмититься с задержкой в 1 секунду (т.е.  1 сек - 1 элемент - 1 сек - 2 элемент и т.д.)
     - parameter array: Массив, который должен быть преобразован в последовательность
     - parameter scheduler: Scheduler на котором должны эмититься элементы
     - attention: Для решения этого задания потребуются знания операторов комбинирования (RxCombining)
     - returns: Результирующая последовательность с элементами массива
    */
    func arrayToObservableWithTimer<T>(_ array: [T], scheduler: SchedulerType) -> Observable<T> where T: FixedWidthInteger {
        let result = Observable<T>.create { el in
            array.forEach { el.onNext($0)}
            el.onCompleted()
            return Disposables.create()
        }

        let obs = Observable.from(array)
            .concatMap { _ in result.delay(.seconds(1), scheduler: scheduler) }
            .take(array.count)

        return obs
    }
    
    /**
     Выполнение метода с длительными вычислениями: expensiveMethod() из someService. Необходимо, чтобы метод
     вызывался только при подписке на Observable.
     - returns: Результирующая последовательность с элементами результата вызова expensiveMethod()
    */
    func expensiveMethodResult() -> Observable<Int> {
//        return .error(NotImplemetedError())
        let obs = Observable<Int>.deferred {
            Observable.of(self.someService.expensiveMethod())
        }
        return obs
    }
    
    /**
    Последовательный вызов нескольких методов с длительными вычислениями. Ни один из методов не должен быть вызван,
     пока не будут произведена подписка на Observable
     - parameter unstableCondition: условие, которое необходимо передавать в unstableMethod
     - returns: Observable который последовательно эмитит результаты выполнения методов, в следующем порядке:
     1. expensiveMethod()
     2. anotherExpensiveMethod()
     3. unstableMethod(unstableCondition:)
    */
    func combinationExpensiveMethods(unstableCondition: Bool) -> Observable<Int> {
        let obs = Observable<Int>.create { sub in
            sub.onNext(self.someService.expensiveMethod())
            sub.onNext(self.someService.anotherExpensiveMethod())
            do {
                sub.onNext(try self.someService.unstableMethod(unstableCondition: unstableCondition))
            } catch {
                sub.onError(ExpectedError())
            }
            return Disposables.create()
        }
        return obs
    }
}

extension RxCreating {
    class SomeService {
        private(set) var wasExpensiveMethodCalled = false
        private(set) var wasAnotherExpensiveMethodCalled = false
        private(set) var unstableMethodCalled = false
        
        func expensiveMethod() -> Int {
            wasExpensiveMethodCalled = true
            return Int.max
        }
        
        func anotherExpensiveMethod() -> Int {
            wasAnotherExpensiveMethodCalled = true
            return Int.min
        }
        
        func unstableMethod(unstableCondition: Bool) throws -> Int {
            unstableMethodCalled = true
            if unstableCondition {
                throw ExpectedError()
            }
            return 0
        }
    }
}
