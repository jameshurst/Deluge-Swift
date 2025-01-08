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

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        name = try container.decode(String.self)
    }

    public init(_ name: String) {
        self.name = name
    }
}

/// Default Deluge plugins.
public extension Plugin {
    /// The "AutoAdd" plugin.
    static var autoAdd: Plugin {
        .init("AutoAdd")
    }

    /// The "Blocklist" plugin.
    static var blocklist: Plugin {
        .init("Blocklist")
    }

    /// The "Execute" plugin.
    static var execute: Plugin {
        .init("Execute")
    }

    /// The "Extractor" plugin.
    static var extractor: Plugin {
        .init("Extractor")
    }

    /// The "Label" plugin.
    static var label: Plugin {
        .init("Label")
    }

    /// The "Notifications" plugin.
    static var notifications: Plugin {
        .init("Notifications")
    }

    /// The "Scheduler" plugin.
    static var scheduler: Plugin {
        .init("Scheduler")
    }

    /// The "Stats" plugin.
    static var stats: Plugin {
        .init("Stats")
    }

    /// The "Toggle" plugin.
    static var toggle: Plugin {
        .init("Toggle")
    }

    /// The "WebUi" plugin.
    static var WebU: Plugin {
        .init("WebUi")
    }
}
