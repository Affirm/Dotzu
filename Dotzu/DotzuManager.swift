//
//  Manager.swift
//  exampleWindow
//
//  Created by Remi Robert on 02/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

public class Dotzu: NSObject {
    public static let sharedManager = Dotzu()
    private var window: ManagerWindow
    fileprivate let controller = ManagerViewController()
    private let cache = NSCache<AnyObject, AnyObject>()
    private let userDefault = UserDefaults.standard
    var displayedList = false

    func initLogsManager() {
        if LogsSettings.shared.resetLogsStart {
            let _ = StoreManager<Log>(store: .log).reset()
            let _ = StoreManager<LogRequest>(store: .network).reset()
        }
    }

    public func enable() {
        initLogsManager()
        self.window.rootViewController = self.controller
        self.window.makeKeyAndVisible()
        self.window.delegate = self
        LoggerNetwork.shared.enable = LogsSettings.shared.network
        Logger.shared.enable = true
        LoggerCrash.shared.enable = true
    }

    public func disable() {
        self.window.rootViewController = nil
        self.window.resignKey()
        self.window.removeFromSuperview()
        Logger.shared.enable = false
        LoggerCrash.shared.enable = false
        LoggerNetwork.shared.enable = false
    }

    public func addLogger(session: URLSessionConfiguration) {
        session.protocolClasses?.insert(LoggerNetwork.self, at: 0)
    }
    
    public func setButtonVisible(visible: Bool) {
        self.controller.button.isHidden = !visible
    }
    
    public func addToggleWithGestureRecognizer(recognizer: UIGestureRecognizer) {
        self.controller.view.addGestureRecognizer(recognizer)
        class Invoker {
                var action:() -> ()
                init(action:@escaping () -> ()) {
                    self.action = action
                }
                @objc func invokeTarget(nizer: UIGestureRecognizer) {
                    self.action()
                    print("Hi from invoker")
                }
            }
        recognizer.addTarget(Invoker(action: {
                self.setButtonVisible(visible: !self.controller.button.isHidden)
        }), action: #selector(Invoker.invokeTarget(nizer:)))

    }

    override init() {
        self.window = ManagerWindow(frame: UIScreen.main.bounds)
        super.init()
    }
}

extension Dotzu: ManagerWindowDelegate {
    func isPointEvent(point: CGPoint) -> Bool {
        return self.controller.shouldReceive(point: point)
    }
}
