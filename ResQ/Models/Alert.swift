import Foundation

struct Alert: Codable, Identifiable {
    let id: String
    let title: String?
    let description: String?
    let severity: String?
    let category: String?
    let location: String?
    let language: String?
    let createdAt: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case severity
        case category
        case location
        case language
        case createdAt = "created_at"
        case isActive = "is_active"
    }

    // ✅ Safe decoding (key မပါလာလည်း crash မဖြစ်)
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = (try? c.decode(String.self, forKey: .id)) ?? UUID().uuidString

        title = try? c.decodeIfPresent(String.self, forKey: .title)
        description = try? c.decodeIfPresent(String.self, forKey: .description)
        severity = try? c.decodeIfPresent(String.self, forKey: .severity)
        category = try? c.decodeIfPresent(String.self, forKey: .category)
        location = try? c.decodeIfPresent(String.self, forKey: .location)
        language = try? c.decodeIfPresent(String.self, forKey: .language)

        // created_at sometimes missing -> decodeIfPresent
        createdAt = try? c.decodeIfPresent(String.self, forKey: .createdAt)

        isActive = try? c.decodeIfPresent(Bool.self, forKey: .isActive)
    }

    // ✅ encode default
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeIfPresent(title, forKey: .title)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encodeIfPresent(severity, forKey: .severity)
        try c.encodeIfPresent(category, forKey: .category)
        try c.encodeIfPresent(location, forKey: .location)
        try c.encodeIfPresent(language, forKey: .language)
        try c.encodeIfPresent(createdAt, forKey: .createdAt)
        try c.encodeIfPresent(isActive, forKey: .isActive)
    }

    // ✅ severity string -> enum
    var severityEnum: AlertSeverity {
        AlertSeverity(rawValue: (severity ?? "").lowercased()) ?? .low
    }
}

enum AlertSeverity: String, Codable {
    case low, medium, high, critical

    var icon: String {
        switch self {
        case .low: return "info.circle"
        case .medium: return "exclamationmark.triangle"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}
