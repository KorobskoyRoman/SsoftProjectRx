//
//  RxCombining.swift
//  RxTraining
//
//  Created by Aleksandr on 23/12/2019.
//  Copyright © 2019 Aleksandr. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

class RxCombining {
    /**
    Суммирование элементов двух последовательностей.
     - parameter firstIntObservable: Observable c произвольным количеством рандомных чисел
     - parameter secondIntObservable: Observable с произвольным количеством рандомных чисел
     - returns: Observable, который эмитит числа, где i-й элемент равен сумме i-го элемента
      firstIntObservable и i-го элемента secondIntObservable. Если в одной из
      входящих последовательностей пробросится Complete или Error, то и в
      результирующую последовательность тоже сработает этот метод.
     */
    func sum(firstIntObservable: Observable<Int>, secondIntObservable: Observable<Int>) -> Observable<Int> {
        let obs = Observable.zip(firstIntObservable,secondIntObservable)
            .map {$0 + $1}

        return obs
    }
    
    /**
    Поиск элементов по выбранной строке и в выбранной категории. Необходимо осуществлять поиск каждый раз,
     когда появляется новая строка или категория. Если передается номер категории больше, чем количество доступных категорий,
     то должен возвращаться пустой массив. Если в качестве поисковой строки передается пустая строка,
     то должны возвращаться все элементы из выбранной категории.
    - parameter searchObservable: Последовательность поисковых строк (в приложении может быть введёнными строками в поисковую строку)
    - parameter categoryObservable: Последовательность с номерами категорий, в которых необходимо осуществить поиск
    - returns: Observable,  который эмитит списки с элементами из категорий с учётом поисковой строки из
    searchObservable и выбранного номера категории из categoryObservable
    */
    func requestItems(searchObservable: Observable<String>, categoryObservable: Observable<Int>) -> Observable<[String]> {
        // Категории, в которых необходимо осуществить поиск
        let categories = [
            ["cat", "dog", "bear", "bearcat", "catfish", "dogfish", "fish"],
            ["shirt", "shoes", "dress", "bra", "pant", "bowler", "skirt"],
            ["table", "sofa", "stool", "throne", "bed", "bar"]
        ]
        let obs = Observable
            .combineLatest(searchObservable, categoryObservable)
            .map({ string, index -> [String] in
                guard index <= categories.count-1 else { return [] }
                if string == "" {
                    return categories[index]
                }
                if categories[index].contains(where: { str in
                    str.contains(string)
                }) {
                    var arr = categories[index]
                    arr.removeAll(where: { !$0.contains(string)})
                    return arr
                }
                else {
                    return []
                }
            })

        return obs
    }
    
    /**
    Объединение потоков, обращение с несколькими объектами Observable, как с одним.
    - parameter intObservable1: Observable с произвольным количеством рандомных чисел
    - parameter intObservable2: Observable с произвольным количеством рандомных чисел
    - returns: Observable который дублирует элементы как из intObservable1, так и intObservable2
    */
    func composition(intObservable1: Observable<Int>, intObservable2: Observable<Int>) -> Observable<Int> {
        let obs = Observable<Int>
            .merge(intObservable2, intObservable1)
        return obs
    }
    
    /**
    Добавляет один дополнительный элемент перед всеми элементами потока.
    - parameter firstItem: Первый элемент, который необходимо добавить
    - parameter intObservable: Observable с произвольным количеством рандомных чисел
    - returns: Observable, который сначала эмитит элемент firstItem, а потом все
      элементы из последовательности intObservable
    */
    func prependItem(_ firstItem: Int, toObservable: Observable<Int>) -> Observable<Int> {
//        return .error(NotImplemetedError())
        let obsItems = Observable.of(firstItem)
        let obs = Observable
            .concat(obsItems, toObservable)

        return obs
    }
    
    /**
    Сначала эмитятся элементы из source последовательности.
     Как только начинает эмитить последовательность another — переключается на неё и начинает дублировать её элементы.
    - parameter source: Исходная последовательность
    - parameter another:  Другая последовательность
    - returns: Результирующая последовательность
    */
    func switchWhenNeeded<E>(source: Observable<E>, another: Observable<E>) -> Observable<E> {
        Observable.merge(source.takeUntil(another), another)
    }
}
