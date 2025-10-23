#!/usr/bin/env swift

import Foundation

struct BurnInResult {
    let success: Bool
    let totalIterations: Int
    let avgOpDuration: Double
    let maxOpDuration: Double
    let memoryIncreaseMB: Double
    let durationSec: Double
}

final class MemoryTracker {
    private func current() -> UInt64 {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<natural_t>.size)
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        guard kerr == KERN_SUCCESS else { return 0 }
        return info.phys_footprint
    }
    func currentMB() -> Double { Double(current()) / (1024.0 * 1024.0) }
}

func burnInTest(durationSeconds: Double = 60.0) -> BurnInResult {
    let mem = MemoryTracker()
    let startMem = mem.currentMB()
    let start = CFAbsoluteTimeGetCurrent()
    var iterations = 0
    var durations: [Double] = []

    // Simulate mixed operations: allocations, cache ops, JSON encode/decode
    var cache: [String: Data] = [:]
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    while CFAbsoluteTimeGetCurrent() - start < durationSeconds {
        let opStart = CFAbsoluteTimeGetCurrent()

        // 1) Allocate and mutate
        var arr = (0..<1000).map { $0 }
        arr.shuffle()
        arr.sort()
        // 2) JSON encode/decode
        struct Dummy: Codable { let id: Int; let name: String }
        let dummy = Dummy(id: iterations, name: "item_\(iterations)")
        let data = try! encoder.encode(dummy)
        let _ = try! decoder.decode(Dummy.self, from: data)
        // 3) Cache some bytes
        cache["k_\(iterations % 100)"] = data
        if iterations % 200 == 0 { cache.removeAll(keepingCapacity: true) }

        let opDur = CFAbsoluteTimeGetCurrent() - opStart
        durations.append(opDur)
        iterations += 1
    }

    let end = CFAbsoluteTimeGetCurrent()
    let endMem = mem.currentMB()
    let duration = end - start

    let avg = durations.reduce(0, +) / Double(durations.count)
    let maxOp = durations.max() ?? 0
    let memInc = Swift.max(0, endMem - startMem)

    return BurnInResult(success: memInc < 5.0, totalIterations: iterations, avgOpDuration: avg, maxOpDuration: maxOp, memoryIncreaseMB: memInc, durationSec: duration)
}

let result = burnInTest(durationSeconds: 30.0)
print("🚀 Stability Burn-In Test")
print("Iterations: \(result.totalIterations)")
print(String(format: "Avg op: %.4fs", result.avgOpDuration))
print(String(format: "Max op: %.4fs", result.maxOpDuration))
print(String(format: "Memory increase: %.2f MB", result.memoryIncreaseMB))
print(String(format: "Duration: %.1fs", result.durationSec))
print(result.success ? "✅ PASSED" : "❌ FAILED")