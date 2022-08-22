//
//  RxTransforming.swift
//  RxTraining
//
//  Created by Aleksandr on 27/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import RxSwift

class RxTransforming {
    
    /**
     Преобразует целые числа из source в строки.
     - parameter source: Исходная последовательность c целыми числами
     - returns: Результирующая последовательность
    */
    func transformIntToString(source: Observable<Int>) -> Observable<String> {
        return .error(NotImplemetedError())
    }
    
    /**
     idObservable испускает id, по которым необходимо делать запрос через requestEntityBy(id:) и
     возвращать последовательность с Entity, которая возвращается этим методом.
     - parameter idObservable: Исходная последовательность c id, которые необходимы для запроса Entity
     - returns: Результирующая последовательность
    */
    func loadEntityById(idObservable: Observable<Int>) -> Observable<Entity> {
        return .error(NotImplemetedError())
    }
    
    /**
     source испускает строки, которые необходимо объединить по первой букве и
     передать в результирующую последовательность, которая эмитит сгруппированные пары
     - parameter source: Исходная последовательность c id, которые необходимы для запроса Entity
     - returns: Результирующая последовательность
    */
    func distributeNamesByFirstLetter(
        source: Observable<String>
    ) -> Observable<GroupedObservable<Character, String>> {
        return .error(NotImplemetedError())
    }
    
    /**
     Каждый раз, когда source испустит count элементов, необходимо эти элементы объединить в массив
     и передать в результирующую последовательность. Когда последовательность source завершается,
     необходимо также передать оставшиеся элементы в массиве, даже если их количество не равно count.
     - parameter source: Исходная последовательность, которая испускает элементы с различной частотой
     - parameter count: Количество элементов в одном массиве
     - parameter scheduler: Scheduler, на котором должно происходить ожидание элементов массива
     - returns: Результирующая последовательность
    */
    func aggregateIntoArrays<T>(
        source: Observable<T>,
        count: Int,
        scheduler: SchedulerType
    ) -> Observable<[T]> {
        return .error(NotImplemetedError())
    }
}

// Вспомогательные методы - не изменять!
extension RxTransforming {
    struct Entity: Equatable {
        let id: Int
    }
    
    func requestEntityBy(id: Int) -> Observable<Entity> {
        return .just(Entity(id: id))
    }
}
