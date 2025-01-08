import Deluge
import Foundation

enum TestConfig {
    static let serverURL = URL(string: "http://localhost:8112")!
    static let serverPassword = "deluge"

    static let torrent1 = "debian.torrent"
    static let torrent1Hash = "5a8062c076fa85e8056451c0d9aa04349ae27909"
    static let torrent1Trackers = [Tracker(url: "http://bttracker.debian.org:6969/announce")]
    static let torrent1FileName = "debian-10.3.0-amd64-netinst.iso"

    static let torrent2 = "mint.torrent"
    static let torrent2Hash = "2a78414b7af89fe08644ece339ee454867d29cb7"

    static let torrent3 = "ubuntu.torrent"
    static let torrent3Hash = "e2467cbf021192c241367b892230dc1e05c0580e"

    static let torrent4 = "fedora.torrent"
    static let torrent4Hash = "bd2d1a1e1fba6377c0b58aa473b3c86db264a2cd"

    // swiftformat:disable indent
    static let magnetURL = """
            magnet:?xt=urn:btih:54da0b79719064aa10fe2cc4e13630a1222d1939&dn=archlinux-2020.03.01-x86_64.iso\
            &tr=udp://tracker.archlinux.org:6969&tr=http://tracker.archlinux.org:6969/announce
            """
    // swiftformat:enable indent
    static let magnetHash = "54da0b79719064aa10fe2cc4e13630a1222d1939"

    static let webURL = "https://downloads.raspberrypi.org/raspbian_latest.torrent"
    static let webURLHash = "154091a4c610d1fad2d93648fc0003df95ae6948"
}
