//
//  Router+Business.swift
//  URLRouter
//
//  Created by Michael Row on 2019/10/12.
//

public extension Router {
    
    /// Bind an interface to an implementation type
    ///
    /// - parameter interfaceType:      interface identifying the registered type
    /// - parameter implementationType: type of the actual interface implementation
    /// - parameter singleton:          flag indicating whether to use the singleton pattern
    /// - parameter initializer:        closure creating an instance of the object
    func bind<P, T : Any>(business interfaceType: P.Type, toImplementation implementationType:T.Type, asSingleton singleton:Bool, initializer: @escaping () -> T) {
        let name = key(for: interfaceType)
        return bindBusiness(named: name, toImplementation: implementationType, asSingleton: singleton, initializer: initializer)
    }

    /// Bind a protocol to an implementation type
    ///
    /// - parameter interfaceName: name of the interface identifying the registered type
    /// - parameter implementationType: type of the actual protocol implementation
    /// - parameter singleton: flag indicating whether to use the singleton pattern
    /// - parameter initializer: closure creating an instance of the object
    func bindBusiness<T : Any>(named interfaceName: String, toImplementation implementationType:T.Type, asSingleton singleton:Bool, initializer: @escaping () -> T) {
        // Check that the protocol has been registered
        if self.businessInstantiators[interfaceName] == nil {
            // Instantiation closure
            let instantiator = { () -> T in
                // Create an instance
                let instance: T = initializer()
                
                // If it's registered as singleton, stores the instance
                if (singleton) {
                    self.businessSingletons[interfaceName] = instance
                }
                
                return instance
            }
            
            // Store the instantiator
            self.businessInstantiators[interfaceName] = instantiator
        }
    }
    
    func unbind<P>(business interfaceType: P.Type) {
        let name = key(for: interfaceType)
        self.businessSingletons.removeValue(forKey: name)
        self.businessInstantiators.removeValue(forKey: name)
    }
    
    /// Return the implementation corresponding to the interface type
    /// identified by the return value, using type inference to detect
    /// the correct type
    ///
    /// - returns: implementation for the type inferred interface type
    func instanceBusiness<P>() -> P? {
        return instance(business: P.self)
    }


    /// Retrieve the implementaton type for the specified `interfaceType`
    /// interface, and return an instance of it
    ///
    /// - parameter interfaceType: type of the interface (protocol or base class) bound to the implementation type to retrieve
    ///
    /// - returns: instance of the implementation type bound to `interfaceType`

    func instance<P>(business interfaceType: P.Type) -> P? {
        let name = key(for: interfaceType)
        return instance(business: name)
    }
    
    func instance<P>(business interfaceName: String) -> P? {
        guard let _instance = instance(named: interfaceName) else { return .none }
        return _instance as? P
    }
    
    func reset() {
        self.businessInstantiators.removeAll(keepingCapacity: true)
        self.businessSingletons.removeAll(keepingCapacity: true)
    }
}

// MARK: - Internals
extension Router {
    /// Retrieve a name for an interface type
    ///
    /// - parameter interfaceType: type of the interface
    ///
    /// - returns: name (key) identifying the interface
    func key<P>(for interfaceType: P.Type) -> String {
        return ("\(interfaceType)")
    }
    
    /// Return the implementation corresponding to the interface type
    ///
    /// - parameter interfaceType: the key identifying the protocol
    ///
    /// - returns: an instance of the specified type, or .None if the type has not been registered
    func instance(named interfaceType: String) -> Any? {
        if let _instance : Any = self.businessSingletons[interfaceType] {
            return _instance
        }
        
        if let instantiator = self.businessInstantiators[interfaceType] {
            return instantiator()
        }
        
        return .none
    }
}
