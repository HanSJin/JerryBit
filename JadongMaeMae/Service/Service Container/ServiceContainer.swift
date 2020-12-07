//
//  ServiceContainer.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import Foundation

// MARK: -

extension ServiceContainer {

    enum ServiceKey {
        // Exchange API
        case accounts
        
        // Quote API
        case quote
    }
}

// MARK: - ServiceContainer

class ServiceContainer {

    // MARK: Lifecycle

    init() {
        do {
            try servicePool.register(key: .accounts, dependency: AccountsServiceImp())
            try servicePool.register(key: .quote, dependency: QuoteServiceImp())
        } catch {
            fatalError("ServiceContainer: register Fail")
        }
    }

    // MARK: Internal

    typealias PoolError = ServicePool.ServiceError

    static let shared: ServiceContainer = ServiceContainer()

    func getService<T>(key: ServiceKey) -> T {
        do {
            return try servicePool.pullOutDependency(key: key)
        } catch let error {
            fatalError("ServiceContainer: getDependency Error Occured \(error)")
        }
    }

    // MARK: Private

    private let servicePool = ServicePool()
}
