//
//  RxError.swift
//  RxTraining
//
//  Created by Aleksandr on 30/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import RxSwift

class RxError {
    
    /**
     Последовательность source испускает элементы, которые необходимо передавать в результирующую последовательность.
     Любые ошибки необходимо заменять на значение defaultValue.
     - parameter source: Исходная последовательность
     - parameter defaultValue: Значение, на которое должны заменяться ошибки из source
     - returns: Результирующая последовательность
    */
    func handleErrorWithDefault<T>(source: Observable<T>, defaultValue: T) -> Observable<T> {
        return .error(NotImplemetedError())
    }
    
    /**
     Последовательность source испускает элементы, которые необходимо передавать в результирующую последовательность.
     Если испускается ошибка, то необходимо переключиться на последовательность onError.
     - parameter source: Исходная последовательность.
     - parameter onError: Последовательность, на которую необходимо переключиться, если в source пробросится ошибка
     - returns: Результирующая последовательность
    */
    func ifErrorThenSwitch<T>(source: Observable<T>, onError: Observable<T>) -> Observable<T> {
        return .error(NotImplemetedError())
    }
    
    /**
     Последовательность source испускает элементы, которые попадают в результирующую.
     Если испускается ошибка типа FixableError.fixable, то последовательность перезапускается.
     Если испускается ошибка FixableError.nonFixable или ошибка другого типа, то в результирующую последовательность пробрасывается эта же ошибка.
     - parameter source: Исходная последовательность
     - returns: Результирующая последовательность
    */
    func tryIfNeeded<T>(source: Observable<T>) -> Observable<T> {
        return .error(NotImplemetedError())
    }
    
    /**
     Последовательность source испускает элементы. Если очередной элемент не удовлетворяет условию filter,
     то последовательность перезапускается, иначе элемент попадает в результирующую последовательность.
     - parameter source: Исходная последовательность
     - parameter filter: Условие, которому должны удовлетворять элементы последовательности
     - returns: Результирующая последовательность
    */
    func tryUntil<T>(source: Observable<T>, filter: @escaping (T) -> Bool) -> Observable<T> {
        return .error(NotImplemetedError())
    }
}
