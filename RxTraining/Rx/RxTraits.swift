//
//  RxTraits.swift
//  RxTraining
//
//  Created by Aleksandr on 30/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import RxSwift
import RxCocoa
import RxRelay

class RxTraits {
    var shouldThrow = false
    
    /**
     Последовательность возвращает результат вызова getUserInfo() и завершается. Если getUserInfo() пробрасывает ошибку,
     то результирующая последовательность должна испустить эту ошибку.
     - returns: Результирующая последовательность Single
    */
    func receiveUserInfo() -> Single<UserInfo> {
        Single.create { single in
            let disposable = Disposables.create()
            do {
                single(.success(try self.getUserInfo()))
            } catch {
                single(.error(error))
            }
            return disposable
        }
    }
    
    /**
     Последовательность возвращает результат вызова sendAnalyticsInfo(). Если вызов успешен, то испускается Completed,
     иначе - та ошибка, которая пробрасывается из sendAnalyticsInfo().
     - returns: Результирующая последовательность Completable
    */
    func sendAnalytics() -> Completable {
//        return .error(NotImplemetedError())
        Completable.create { compl in
            let disposable = Disposables.create()
            do {
                try self.sendAnalyticsInfo()
                compl(.completed)
            } catch {
                compl(.error(error))
            }
            return disposable
        }
    }
    
    /**
     Последовательность возвращает цифру, следующую после afterInt.
     Если после afterInt нет следующей цифры, то испускается Completed.
     Если afterInt не цифра, то испускается ошибка типа ExpectedError.
     Цифры: 0-9.
     - parameter afterInt: Цифра, от которой необходимо получить следующую после неё
     - returns: Результирующая последовательность Maybe
    */
    func getNext(afterInt: Int) -> Maybe<Int> {
        Maybe.create { maybe in
            let disposable = Disposables.create()
            if afterInt == 9 {
                maybe(.completed)
            } else if afterInt >= 10 {
                maybe(.error(ExpectedError()))
            } else {
                maybe(.success(afterInt + 1))
            }
            return disposable
        }
    }
    
    /**
     Возвращает последовательность - результат вызова loadModels(). Тип возвращаемой последовательности - SharedSequence,
     при повторной подписке на которую должен должен повторяться последний испущенный элемент.
     При ошибке возвращать пустой массив.
     - returns: Результирующая последовательность SharedSequence
    */
    func getModels() -> SharedSequence<DriverSharingStrategy, [String]> {
         loadModels()
            .asDriver(onErrorJustReturn: [])
    }
    
    /**
     Возвращает последовательность, которая один раз испускает true и НЕ завершается. Тип возвращаемой последовательности -
     SharedSequence, при повторной подписке на которую НЕ должен повторяться последний испущенный элемент.
     При ошибке возвращать false.
     - returns: Результирующая последовательность SharedSequence
    */
    func focusPasswordField() -> SharedSequence<SignalSharingStrategy, Bool> {
//        return .just(false)
        Observable.create { sub in
            sub.onNext(true)
            return Disposables.create()
        }
        .asSignal(onErrorJustReturn: false)
    }
}

// Вспомогательные методы - не изменять!
private extension RxTraits {
    func getUserInfo() throws -> UserInfo {
        if shouldThrow {
            throw ExpectedError()
        }
        
        return UserInfo(name: "Test", age: 0)
    }
    
    func sendAnalyticsInfo() throws {
        if shouldThrow {
            throw ExpectedError()
        }
    }
    
    func loadModels() -> Observable<[String]> {
        return .just([""])
    }
}

extension RxTraits {
    struct UserInfo: Equatable {
        let name: String
        let age: Int
    }
}
