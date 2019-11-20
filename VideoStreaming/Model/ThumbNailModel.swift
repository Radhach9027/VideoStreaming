struct ThumbNailModel: Codable, Identifiable {
    let id: Int
    var title: String
    var url: String
    var thumbnail: String
    var description: String

    init(id: Int, title: String, url: String, thumbnail: String, description: String) {
        self.id = id
        self.title = title
        self.url = url
        self.thumbnail = thumbnail
        self.description = description
    }
}

extension ThumbNailModel {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case thumbnail
        case description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let title: String = try container.decode(String.self, forKey: .title)
        let url: String = try container.decode(String.self, forKey: .url)
        let backgroundImage: String = try container.decode(String.self, forKey: .thumbnail)
        let description: String = try container.decode(String.self, forKey: .description)
        self.init(id: id, title: title, url: url, thumbnail: backgroundImage, description: description)
    }
}
