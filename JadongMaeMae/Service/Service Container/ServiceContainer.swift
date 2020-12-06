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
        // Rest API
        case accounts
    }
}

// MARK: - ServiceContainer

class ServiceContainer {

    // MARK: Lifecycle

    init() {
        do {
            try servicePool.register(key: .accounts, dependency: AccountsServiceImp())
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
