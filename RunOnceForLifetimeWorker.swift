//
//  RunOnceForLifetimeWorker.swift
//
//  Created by Mikhail Lazarau on 12/12/2023.
//

import Foundation

func runOnceForLifetime(of object: AnyObject,
                        completion: () -> Void,
                        fileId: String = #fileID,
                        function: String = #function,
                        line: Int = #line) {
    RunOnceForLifetimeWorker.shared.run(for: object, completion: completion, fileId: fileId, function: function, line: line)
}

private struct RunOnceForLifetimeWorker {
    typealias AssociatedObjectIndentifier = UInt

    private var onceTracker: [AssociatedObjectIndentifier: Set<Token>]
    private let recursiveLock = NSRecursiveLock()

    static var shared: RunOnceForLifetimeWorker = {
        return RunOnceForLifetimeWorker(storage: [:])
    }()

    private init(storage: [AssociatedObjectIndentifier: Set<Token>]) {
        onceTracker = storage
    }

    mutating func run(for object: AnyObject,
                      completion: () -> Void,
                      fileId: String,
                      function: String,
                      line: Int) {
        let id = UInt(bitPattern: ObjectIdentifier(object))
        let token = Token(fileId: fileId, function: function, line: line)

        recursiveLock.lock()

        if onceTracker[id] == nil {
            onceTracker[id] = []
        }

        guard onceTracker[id]?.insert(token).inserted == true else {
            recursiveLock.unlock()
            return
        }

        recursiveLock.unlock()
        completion()
    }
}

extension RunOnceForLifetimeWorker {
    struct Token: Hashable {
            let fileId: String
            let function: String
            let line: Int
        }
}
