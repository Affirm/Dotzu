//
//  LogPrint.swift
//  exampleWindow
//
//  Created by Remi Robert on 17/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import Foundation

public func print(_ items: Any...) {
    if LogsSettings.shared.overridePrint && Logger.shared.enable {
        Logger.handleLog(items, level: .verbose, file: nil, function: nil, line: nil)
    } else {
        Swift.print(items.first ?? "")
    }
}

public class Logger: LogGenerator {

    static let shared = Logger()
    private let store = StoreManager<Log>(store: .log)
    private let queue = DispatchQueue(label: "logprint.log.queue")

    var enable: Bool = true

    public static func verbose(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        handleLog(items, level: .verbose, file: file, function: function, line: line)
    }

    public static func info(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        handleLog(items, level: .info, file: file, function: function, line: line)
    }

    public static func warning(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        handleLog(items, level: .warning, file: file, function: function, line: line)
    }

    public static func error(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        handleLog(items, level: .error, file: file, function: function, line: line)
    }

    fileprivate static func parseFileInfo(file: String?, function: String?, line: Int?) -> String? {
        guard let file = file, let function = function, let line = line else {return nil}
        guard let fileName = file.components(separatedBy: "/").last else { return nil }
        return "\(fileName).\(function)[\(line)]"
    }

    #if false

    // Edward: June 10, 2020
    // There is a multi-threaded memory problem in here somewhere that need to be fixed.
    // An object is being passed by reference to the async block that needs to be copied instead.
    // Rather than spend time figuring it out, I made the thread `sync(flags: .barrier)`. See below:

    fileprivate static func handleLog(_ items: Any..., level: LogLevel, file: String?, function: String?, line: Int?) {
        if !Logger.shared.enable {
            return
        }
        let fileInfo = parseFileInfo(file: file, function: function, line: line)
        let stringContent = (items.first as? [Any] ?? []).reduce("") { result, next -> String in
            return "\(result)\(result.count > 0 ? " " : "")\(next)"
        }
        Logger.shared.queue.async(flags: .barrier) {
            let newLog = Log(content: stringContent, fileInfo: fileInfo, level: level)
            let format = LoggerFormat.format(log: newLog)
            Swift.print(format.str)
            Logger.shared.store.add(log: newLog)
        }
        LogNotificationApp.newLog.post(level)
        LogNotificationApp.refreshLogs.post(Void())
    }

    #else
    
    fileprivate static func handleLog(_ items: Any..., level: LogLevel, file: String?, function: String?, line: Int?) {
        Logger.shared.queue.sync(flags: .barrier) {
            if !Logger.shared.enable {
                return
            }
            let fileInfo = parseFileInfo(file: file, function: function, line: line)
            let stringContent = (items.first as? [Any] ?? []).reduce("") { result, next -> String in
                return "\(result)\(result.count > 0 ? " " : "")\(next)"
            }
            let newLog = Log(content: stringContent, fileInfo: fileInfo, level: level)
            let format = LoggerFormat.format(log: newLog)
            Swift.print(format.str)
            Logger.shared.store.add(log: newLog)
            LogNotificationApp.newLog.post(level)
            LogNotificationApp.refreshLogs.post(Void())
        }
    }
    #endif
}
