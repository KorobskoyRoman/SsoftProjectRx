//
//  RxAdvanced.swift
//  RxTraining
//
//  Created by Aleksandr on 30/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

class RxAdvanced {
    
    /**
     При первом эмите последовательности source просто дублирует этот элемент в результирующую последовательность.
     После этого при каждом эмите последовательности byIdSignal находит в массиве [Toggler] из source структуру с id равным элементу signal
     и изменяет его свойство enabled на противоположное. После чего эмитит обновленный массив в результирующую последовательность.
     При этом необходимо сохранять предыдущее состояние массива из source и использовать его при следующем эмите
     signal. То есть если в первый раз была изменена структура с id=1, то когда signal испустит следующий элемент у
     структуры с id=1 уже будет enabled=true.
     - attention: Для решения данной задачи и последующих могут потребоваться операторы агрегирования
     - parameter source: Исходная последовательность, эмитится только один раз
     - parameter signal: Последовательность с id структуры, для которой необходимо изменить enabled свойство на противоположную.
     Эмитится несколько раз
     - returns: Результирующая последовательность с массивом [Toggler]
    */
    func update(source: Observable<[Toggler]>, byIdSignal signal: Observable<Int>) -> Observable<[Toggler]> {
        return .error(NotImplemetedError())
    }
    
    /**
     Каждый раз, когда эмитит signal из source берется последний элемент и сохраняется (если он еще ни разу не брался).
     Так повторяется 3 раза, после чего сохраненные 3 элемента суммируются и передаются в результирующую последовательность.
     Если source испускает ошибку, то она заменяется на число 13 и последовательность завершается. При этом это число
     также добавляется к сохраненным.
     Если source завершается, то необходимо брать все сохраненные на данные элементы суммировать и передавать в результирующую
     последовательность (только если число сохраненных элементов БОЛЬШЕ 0).
     - parameter source: Исходная последовательность, которая эмитит целые числа
     - parameter signal: Последовательность, которая эмимтит сигналы, по которым берутся последние элементы из source
     - returns: Результирующая последовательность с суммами
    */
    func sumLast(fromObservable source: Observable<Int>, bySignal signal: Observable<Void>, scheduler: SchedulerType) -> Observable<Int> {
//        return .error(NotImplemetedError())
        signal.bind { _ in
            source
                .takeLast(3)
                .share(replay: 3, scope: .whileConnected)
                .asSignal(onErrorJustReturn: 13)
                .asObservable()
                .reduce(1, accumulator: +)
        }
    }
    
    /**
     Последовательнсть source эмитит целые числа. Когда очередной элемент испущен, необходимо этот элемент сравнить
     с предыдущим и результат сравнения передать в результирующую последовательность. При этом сравнивать нужно
     КАЖДЫЙ элемент с предыдущим (если этот элемент не первый в последовательности). Т.е. для последовательности 3 5 2
     результирующая последовательность испустит true false (т.к. 5 > 3 = true и 2 > 5 = false). Как только исходная последовательность
     завершится, завершается и результирующая последовательность.
     - parameter source: Исходная последовательность, которая эмитит целые числа
     - returns: Результирующая последовательность с результатами сравнения двух последних элементов
    */
    func compareLast(source: Observable<Int>) -> Observable<Bool> {
//        return .error(NotImplemetedError())
        let obs = Observable.zip(source, source.skip(1))
        let obs2 = obs.map { prev, current in
            return current > prev ? true : false
        }
        return obs2
    }
    
    /**
     Последовательнсть source эмитит целые числа. Когда последовательность завершится, испускается один элемент типа
     целое число, которое является индексом элемента с наибольшим значением. Если несколько элементов являются наибольшими,
     то необходимо эмитить индекс последнего из них. Если элементов в source нет, то результирующая последовательность
     должна просто завершиться.
     - parameter source: Исходная последовательность, которая эмитит целые числа
     - returns: Результирующая последовательность, которая эмитит только один элемент с индеком наибольшего числа или просто завершается
    */
    func maxIndex(source: Observable<Int>) -> Maybe<Int> {
//        source
//            .enumerated()
//            .scan(0, accumulator: { (last, arg1) in
//                return last > arg1.index ? last : arg1.index
//            })
//        Observable.zip(source, source.skip(1))
//            .enumerated()
//            .takeLast(1)
//            .asObservable()
//            .asMaybe()
//        source
//            .enumerated()
//            .scan(0, accumulator: { last, new in
//                return last > new.element ? last : new.index
//            })
//            .map { $0 }
//            .takeLast(1)
//            .asMaybe()
        source
            .enumerated()
            .withPrevious()
//            .map { $0.0?.element ?? 0 > $0.1.element ? $0.0?.index ?? 0 : $0.1.index }
//            .map({ old, new in
////                return (old?.element ?? 0) > new.element ? (old?.index ?? 0) : new.index
//                if old?.element ?? 0 < new.element {
//                    return new.index
//                }
//                return 0
//            })
//            .map({ old, new in
//                if old?.element ?? 0 < new.element {
//                    return new.element
//                } else {
//                    source.skip(1)
//                    return 0
//                }
//            })
//            .takeLast(1)
            .takeWhile { $0.1.element > $0.0?.element ?? 0 }
            .map {$0.1.index}
            .asMaybe()
    }
    
    /**
     Каждый раз, когда последовательность signal эмитит элемент, происходит подписка на request. Элементы всех request
     должны быть объединены в один массив в том порядке, в котором они приходят из каждого request. Последовательность
     request может выпустить элементы не сразу, а только через некоторое время. При этом, даже если уже был получен очередной
     элемент из signal, необходимо дождаться элементов из предыдущего request. То есть если signal выпустил 3 элемента подряд,
     а request выполняется долго, то необходимо дождаться выполнения каждого request. Как только отработают все request и
     последовательность source завершилась, необходимо передать в результирующую последовательность объединенные элементы.
     - parameter signal: Исходная последовательность, которая эмитит сигналы. по которым должны происходить запросы
     - parameter request: Последовательность для запроса, на которую необходимо подписываться при каждом сигнале из signal
     - returns: Результирующая последовательность, которая эмитит один раз объединенные элементы из запросов и завершается
    */
    func multipleRequest<T>(
        bySignal signal: Observable<Void>,
        request: Observable<[T]>
    ) -> Observable<[T]> {
        return .error(NotImplemetedError())
    }
}

extension RxAdvanced {
    struct Toggler: Equatable {
        let id: Int
        var enabled: Bool
    }
}

extension ObservableType {
    func withPrevious() -> Observable<(Element?, Element)> {
        return scan([], accumulator: { (previous, current) in
            Array(previous + [current]).suffix(2)
          })
          .map({ (arr) -> (previous: Element?, current: Element) in
            (arr.count > 1 ? arr.first : nil, arr.last!)
          })
      }
}
