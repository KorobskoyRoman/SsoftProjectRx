//
//  RxFiltering.swift
//  RxTraining
//
//  Created by Aleksandr on 26/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

class RxFiltering {
    
    /**
     Результирующая последовательность испускает только ОДИН элемент из source, который удовлетворяет условию condition.
     После этого последовательность завершается, даже если не выпустится ни одного элемента.
     - parameter source: Исходная последовательность
     - parameter condition:  Условие, которому должен удовлетворять элемент
     - returns: Результирующая последовательность
     */
    func firstValueWithCondition<T>(
        source: Observable<T>,
        condition: @escaping (T) -> Bool
    ) -> Observable<T> {
        source
            .filter { condition($0) }
            .take(1)
    }
    
    /**
     Из source последовательности пропускается notPickFirstValuesCount элементов и после этого берутся pickFirstValuesCount элементов.
     После этого последовательность завершается Completed.
     - parameter source: Исходная последовательность
     - parameter pickFirstValuesCount: Кол-во элементов, которые должны попасть в последовательность
     - parameter notPickFirstValuesCount: Кол-во элементов, которые должны быть пропущены
     - returns: Результирующая последовательность
     */
    func pickFirstValues<T>(
        source: Observable<T>,
        pickFirstValuesCount: Int,
        notPickFirstValuesCount: Int
    ) -> Observable<T> {
        source
            .skip(notPickFirstValuesCount)
            .take(pickFirstValuesCount)
    }
    
    /**
     Из source последовательности сначала берутся элементы, сгенерированные в интервал времени interval,
     затем из этих элементов берется последний и эмитится в результирующую последовательность, которая завершается Completed.
     - parameter source: Исходная последовательность
     - parameter scheduler:  Scheduler, на котором должно производиться ожидание элементов
     - parameter interval: Время, в течение которого происходит ожидание элементов
     - returns: Результирующая последовательность
     */
    func takeLastWithDuration<T>(
        source: Observable<T>,
        scheduler: SchedulerType,
        interval: DispatchTimeInterval
    ) -> Observable<T> {
        source
            .take(interval, scheduler: scheduler)
            .takeLast(1)
    }
    
    /**
     Из source последовательности берутся только элементы, которые не повторяются подряд (например: 1,1,2,2,1,2 - > 1,2,1,2).
     Если такой элемент не был выпущен в течение интервала времени waitingTime, то выбрасывается ошибка RxError.timeout.
     - parameter source: Исходная последовательность
     - parameter waitingTime: Время ожидания следующего элемента
     - parameter scheduler: Scheduler, на котором должно производиться ожидание элементов
     - returns: Результирующая последовательность
     */
    func ignoreDublicatesWithWaitingError<T: Comparable>(
        source: Observable<T>,
        waitingTime: DispatchTimeInterval,
        scheduler: SchedulerType
    ) -> Observable<T> {
        source.distinctUntilChanged()
            .timeout(waitingTime, scheduler: scheduler)
    }
    
    /**
     В searchStringObservable приходят поисковые строки. Если после последней выпущенной строки проходит время waitingTime,
     то необходимо осуществить поиск по searchCatalog и передать в результирующую последовательность все подходящие строки.
     Алгоритм поиска: если в строке из searchCatalog присутствует подстрока из очередного элемента searchStringObservable,
     то такая строка должна попасть в результирующий массив.
     - parameter source: Исходная последовательность
     - parameter waitingTime:   Время ожидания следующего элемента
     - parameter scheduler: Scheduler, на котором должно производиться ожидание элементов
     - attention: Для реализации данной последовательности необходимо использовать методы трансформации
     (рекомендуется решить задания из RxTransforming)
     - returns: Результирующая последовательность
     */
    func searchWhenFinishedTyping(
        searchStringObservable: Observable<String>,
        waitingTime: DispatchTimeInterval,
        scheduler: SchedulerType
    ) -> Observable<[String]> {
        // Каталог, в котором необходимо осуществлять поиск строк
        let searchCatalog = ["unicorns", "popcorn", "corn", "porridge", "pork", "portal"]
        
//                return Observable<[String]>.just(searchCatalog)
//                    .concat(Observable<[String]>.error(NotImplemetedError()))
//        let source = Observable.just(searchStringObservable)
//            .map {
//                $0.filter{ $0.hasPrefix(searchCatalog[$0]) }
//            }

//        return source
//        let searchObs = Observable<[String]>.create {
//            $0.onNext(searchCatalog)
//            return Disposables.create()
//        }

        let searchObs = Observable<[String]>.just(searchCatalog)
//            .throttle(waitingTime, scheduler: scheduler)
//            .map {
//                $0.filter { $0.hasPrefix("p") }
//            }

        let res = Observable.zip(searchObs, searchStringObservable)
            .throttle(waitingTime, scheduler: scheduler)
            .filter { $0.0.contains($0.1) }
            .map { $0.0 }
        return res
    }
    /**
     Каждый раз, когда switcher испускает false, а затем true (или если true первый элемент),
     то в результирующую последовательность попадает последний элемент из source (если он уже не попал туда ранее):
     - parameter source: Исходная последовательность
     - parameter switcher: Последовательность, по событиям которой происходит дублирование элементов из source
     - returns: Результирующая последовательность
     */
    func releaseElementWhenSwitched<T>(source: Observable<T>, switcher: Observable<Bool>) -> Observable<T> {
//        return .error(NotImplemetedError())
//        Observable
//            .combineLatest(switcher.startWith(true), source)
//            .filter {$0.0 == true}
//            .map {$0.1}

//        Observable
//            .combineLatest(switcher.distinctUntilChanged(), source.sample(switcher))
////            .sample(switcher)
//            .filter { $0.0 == true }
//            .map { $0.1 }

        Observable.combineLatest(switcher.distinctUntilChanged(), source.sample(switcher))
            .sample(source)
            .filter { $0.0 == true }
            .map { $0.1 }
    }
}
