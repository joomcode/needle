//
//  AssemblyStorage.swift
//  Joom
//
//  Created by Artem Starosvetskiy on 01.12.2019.
//  Copyright © 2019 Joom. All rights reserved.
//

import Foundation

public enum AssemblyStoragePolicy {
    case strong
    case weak
}

public protocol AssemblyStorageProtocol {
    typealias StoragePolicy = AssemblyStoragePolicy

    func singleton<Args, Object>(function: StaticString, storage: StoragePolicy, args: Args, factory: () -> Object) -> Object
        where Object: AnyObject, Args: Hashable
}

public final class AssemblyStorage {
    private lazy var strongObjects: NSMapTable<AnyObject, AnyObject> = .strongToStrongObjects()
    private lazy var weakObjects: NSMapTable<AnyObject, AnyObject> = .strongToWeakObjects()

    public init() {}
}

extension AssemblyStorage: AssemblyStorageProtocol {
    public func singleton<Args, Object>(function: StaticString, storage: StoragePolicy, args: Args, factory: () -> Object) -> Object
        where Object: AnyObject, Args: Hashable
    {
        let key = Key(function: function, args: args, objectType: Object.self)
        let objects: NSMapTable<AnyObject, AnyObject>

        switch storage {
        case .strong:
            objects = strongObjects
        case .weak:
            objects = weakObjects
        }

        if let object = objects.object(forKey: key) {
            return object as! Object
        }

        let object = factory()
        objects.setObject(object, forKey: key)

        return object
    }
}

public extension AssemblyStorageProtocol {
    func weakSingleton<Args, Object>(function: StaticString = #function, args: Args, factory: () -> Object) -> Object
        where Object: AnyObject, Args: Hashable
    {
        singleton(function: function, storage: .weak, args: args, factory: factory)
    }

    func weakSingleton<Object>(function: StaticString = #function, factory: () -> Object) -> Object
        where Object: AnyObject
    {
        singleton(function: function, storage: .weak, args: Nothing(), factory: factory)
    }

    func singleton<Args, Object>(function: StaticString = #function, args: Args, factory: () -> Object) -> Object
        where Object: AnyObject, Args: Hashable
    {
        singleton(function: function, storage: .strong, args: args, factory: factory)
    }

    func singleton<Object>(function: StaticString = #function, factory: () -> Object) -> Object
        where Object: AnyObject
    {
        singleton(function: function, storage: .strong, args: Nothing(), factory: factory)
    }
}

private final class Key<Args, Object>: NSObject where Object: AnyObject, Args: Hashable {
    // MARK: - NSObject properties

    override var hash: Int {
        var hasher = Hasher()

        if function.hasPointerRepresentation {
            hasher.combine(function.utf8Start)
        } else {
            hasher.combine(function.unicodeScalar)
        }

        hasher.combine(args)

        return hasher.finalize()
    }

    // MARK: - Private properties

    private let function: StaticString
    private let args: Args

    // MARK: - Init

    init(function: StaticString, args: Args, objectType: Object.Type) {
        self.function = function
        self.args = args
    }

    // MARK: - NSObject methods

    override func isEqual(_ other: Any?) -> Bool {
        guard let other = other as? Key<Args, Object> else {
            return false
        }
        if self === other {
            return true
        }

        return Self.isSameFunction(function1: function, function2: other.function) && args == other.args
    }

    // MARK: - Private methods

    private static func isSameFunction(function1: StaticString, function2: StaticString) -> Bool {
        guard function1.hasPointerRepresentation == function2.hasPointerRepresentation else {
            return false
        }

        if function1.hasPointerRepresentation {
            return function1.utf8Start == function2.utf8Start
        } else {
            return function1.unicodeScalar == function2.unicodeScalar
        }
    }
}
