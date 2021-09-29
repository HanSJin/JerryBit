//
//  ServicePool.swift
//  JerryBit
//
//  Created by USER on 2020/12/07.
//

import Foundation

// MARK: -

extension ServicePool {

    enum ServiceError: Error {
        case unknownKey
        case typeError
        case alreadyExist
    }
}

// MARK: - ServicePool

class ServicePool {

    // MARK: Internal

    typealias ServiceKey = ServiceContainer.ServiceKey

    func register<T>(key: ServiceKey, dependency: T) throws {
        guard servicePool[key] == nil else {
            throw ServiceError.alreadyExist
        }
        servicePool.updateValue(dependency, forKey: key)
    }

    func pullOutDependency<T>(key: ServiceKey) throws -> T {
        guard let serviceValue = servicePool[key] else {
            throw ServiceError.unknownKey
        }
        guard let service = serviceValue as? T else {
            throw ServiceError.typeError
        }
        return service
    }

    // MARK: Private

    private var servicePool: [ServiceKey: Any] = [:]
}
