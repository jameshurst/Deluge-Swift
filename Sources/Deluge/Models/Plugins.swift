public struct Plugins: Decodable, Equatable, Sendable {
    public let enabled: [Plugin]
    public let available: [Plugin]

    enum CodingKeys: String, CodingKey {
        case enabled = "enabled_plugins"
        case available = "available_plugins"
    }
}

public struct Plugin: Decodable, Equatable, Sendable {
    public let name: String
    // TODO: add a info() request

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        name = try container.decode(String.self)
    }

    public init(_ name: String) {
        self.name = name
    }
}

public extension Plugin {
    static var autoAdd: Plugin {
        .init("AutoAdd")
    }

    static var blocklist: Plugin {
        .init("Blocklist")
    }

    static var execute: Plugin {
        .init("Execute")
    }

    static var extractor: Plugin {
        .init("Extractor")
    }

    static var label: Plugin {
        .init("Label")
    }

    static var notifications: Plugin {
        .init("Notifications")
    }

    static var scheduler: Plugin {
        .init("Scheduler")
    }

    static var stats: Plugin {
        .init("Stats")
    }

    static var Toggle: Plugin {
        .init("Toggle")
    }

    static var WebU: Plugin {
        .init("WebUi")
    }
}
