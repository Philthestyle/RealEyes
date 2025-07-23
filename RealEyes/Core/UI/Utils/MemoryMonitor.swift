//
//  MemoryMonitor.swift
//  RealEyes
//
//  Created by Ptitin on 23/07/2025.
//

import Foundation
import Combine

final class MemoryMonitor: ObservableObject {
    private var timer: Timer?
    
    init() {
        startMonitoring()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.logMemoryUsage()
        }
    }
    
    private func logMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            let totalMB = Double(ProcessInfo.processInfo.physicalMemory) / 1024.0 / 1024.0
            let percentage = (usedMB / totalMB) * 100.0
            
            // Emoji selon l'usage
            let emoji = percentage > 10 ? "🔴" : percentage > 5 ? "🟡" : "🟢"
            
            // Log formaté
            print("\(emoji) [Memory] \(String(format: "%.1f", usedMB)) MB (\(String(format: "%.1f", percentage))%)")
            
            // Alert si trop haut
            if percentage > 15 {
                print("⚠️ [Memory WARNING] High memory usage detected!")
            }
        }
    }
}
