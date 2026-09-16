//
//  Created by Alex.M on 21.06.2022.
//

import Foundation
import Combine
import AVKit

@MainActor
final class VideoViewModel: ObservableObject {

    @Published var attachment: Attachment
    @Published var player: AVPlayer?

    @Published var isPlaying = false
    @Published var isMuted = false

    private var subscriptions = Set<AnyCancellable>()
    @Published var status: AVPlayer.Status = .unknown
    /// Fetching the file to play, while it is (see `ChatMediaFiles`).
    private var loading: Task<Void, Never>?

    init(attachment: Attachment) {
        self.attachment = attachment
    }

    func onStart() {
        guard player == nil, loading == nil else { return }
        let url = attachment.full
        loading = Task { [weak self] in
            let playable = await ChatMediaFiles.playable(url)
            guard let self else { return }
            self.loading = nil
            guard let playable else {
                self.status = .failed
                return
            }
            self.startPlayer(url: playable)
        }
    }

    private func startPlayer(url: URL) {
        if player == nil {
            self.player = AVPlayer(url: url)
            self.player?.publisher(for: \.status)
                .receive(on: DispatchQueue.main)
                .assign(to: &$status)

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.finishVideo() }
            }
        }
    }

    func onStop() {
        pauseVideo()
    }

    func togglePlay() {
        if player?.isPlaying == true {
            pauseVideo()
        } else {
            playVideo()
        }
    }

    func toggleMute() {
        player?.isMuted.toggle()
        isMuted = player?.isMuted ?? false
    }

    func playVideo() {
        player?.play()
        isPlaying = player?.isPlaying ?? false
    }

    func pauseVideo() {
        player?.pause()
        isPlaying = player?.isPlaying ?? false
    }

    func finishVideo() {
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 10))
        isPlaying = false
    }
}
