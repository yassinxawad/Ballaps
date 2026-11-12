import AVFoundation
import Foundation
let input = URL(fileURLWithPath: CommandLine.arguments[1])
let output = URL(fileURLWithPath: CommandLine.arguments[2])
let done = DispatchSemaphore(value: 0)
Task {
    do {
        let asset = AVURLAsset(url: input)
        let tracks = try await asset.loadTracks(withMediaType: .audio)
        guard !tracks.isEmpty else { throw NSError(domain: "BallapsAudio", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio track found"]) }
        let duration = try await asset.load(.duration)
        guard let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { throw NSError(domain: "BallapsAudio", code: 2) }
        try await export.export(to: output, as: .m4a)
        let result = AVURLAsset(url: output)
        let resultDuration = try await result.load(.duration)
        print("Extracted soundtrack. Source: \(duration.seconds)s; audio: \(resultDuration.seconds)s")
        done.signal()
    } catch {
        fputs("Audio extraction failed: \(error)\n", stderr)
        exit(1)
    }
}
done.wait()
