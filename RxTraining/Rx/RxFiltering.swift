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
       return .error(NotImplemetedError())
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
        return .error(NotImplemetedError())
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
        return .error(NotImplemetedError())
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
        return .error(NotImplemetedError())
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
        
        return Observable<[String]>.just(searchCatalog)
            .concat(Observable<[String]>.error(NotImplemetedError()))
    }
    
    /**
     Каждый раз, когда switcher испускает false, а затем true (или если true первый элемент),
     то в результирующую последовательность попадает последний элемент из source (если он уже не попал туда ранее):
     - parameter source: Исходная последовательность
     - parameter switcher: Последовательность, по событиям которой происходит дублирование элементов из source
     - returns: Результирующая последовательность
    */
    func releaseElementWhenSwitched<T>(source: Observable<T>, switcher: Observable<Bool>) -> Observable<T> {
        return .error(NotImplemetedError())
    }
}
