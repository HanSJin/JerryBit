//
//  GlobalTimer.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

protocol GlobalRunLoop: class {
    var fps: Double { get }
    func runLoop()
    
    var secondaryFps: Double { get }
    func secondaryRunLoop()
}

extension GlobalRunLoop {
    var fps: Double { 1 }
    
    var secondaryFps: Double { 0 }
    func secondaryRunLoop() { }
}

class GlobalTimer {
    
    // MARK: Lifecycle
    private let frequencyPerSeconds = Double(60)
    private var tick = 0

    init() {
        fire()
    }

    // MARK: Internal

    // MARK: Private

    private var timer: Timer!

    private func fire() {
        timer?.invalidate()
        timer = Timer(timeInterval: 1.0 / frequencyPerSeconds, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    @objc private func timerTick() {
        tick += 1
        guard tick < 1000 else { return }
        guard let topVC = UIApplication.topViewController(), let runLooper = topVC as? GlobalRunLoop else { return }
        guard runLooper.fps > 0 else { return }
        if tick % Int(60 / runLooper.fps) == 0 {
            runLooper.runLoop()
        }
    }
}
