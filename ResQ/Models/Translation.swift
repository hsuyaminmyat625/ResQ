import Foundation

struct TranslationRequest: Codable {
    let text: String
    let sourceLanguage: String
    let targetLanguage: String
    let context: String?
    
    enum CodingKeys: String, CodingKey {
        case text
        case sourceLanguage = "source_language"
        case targetLanguage = "target_language"
        case context
    }
    
    init(text: String, sourceLanguage: String = "auto", targetLanguage: String, context: String? = nil) {
        self.text = text
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.context = context
    }
}

struct TranslationResponse: Codable {
    let originalText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let confidence: Double
    let context: String?
    
    enum CodingKeys: String, CodingKey {
        case originalText = "original_text"
        case translatedText = "translated_text"
        case sourceLanguage = "source_language"
        case targetLanguage = "target_language"
        case confidence
        case context
    }
}

struct LanguageInfo: Codable, Identifiable {
    let code: String
    let name: String
    let nativeName: String
    let supported: Bool
    let region: String
    
    var id: String { code }
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case nativeName = "native_name"
        case supported
        case region
    }
}

