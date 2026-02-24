import Foundation

/// Represents a dart player (pro or custom)
struct Player: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var country: String
    var imageURL: String?
    var isCustom: Bool

    init(id: UUID = UUID(), name: String, country: String, imageURL: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.country = country
        self.imageURL = imageURL
        self.isCustom = isCustom
    }
}

/// Pre-defined professional PDC players
struct ProPlayerData {
    static let pdcBaseURL = "https://images.gc.pdcservices.co.uk/fit-in/600x600/"

    static func pdcImg(_ id: String) -> String {
        return "\(pdcBaseURL)\(id).png"
    }

    static let all: [Player] = [
        Player(name: "Luke Humphries",        country: "🇬🇧", imageURL: pdcImg("f62be0d0-f233-11f0-b703-63c53945660f")),
        Player(name: "Luke Littler",           country: "🇬🇧", imageURL: pdcImg("7843dbf0-f21a-11f0-a2b2-337f630ef140")),
        Player(name: "Michael van Gerwen",     country: "🇳🇱", imageURL: pdcImg("f62e2ac0-f233-11f0-b992-c9679735a32e")),
        Player(name: "Gary Anderson",          country: "🏴󠁧󠁢󠁳󠁣󠁴󠁿", imageURL: pdcImg("784bcb30-f21a-11f0-8d55-8b906d2d8ca1")),
        Player(name: "Peter Wright",           country: "🏴󠁧󠁢󠁳󠁣󠁴󠁿", imageURL: pdcImg("f56842b0-f233-11f0-8be2-5d81ca77fe21")),
        Player(name: "Gerwyn Price",           country: "🏴󠁧󠁢󠁷󠁬󠁳󠁿", imageURL: pdcImg("f5a3ec20-f233-11f0-a1f6-49664dee8666")),
        Player(name: "Rob Cross",              country: "🇬🇧", imageURL: pdcImg("f5de3600-f233-11f0-897c-cda35cd4c727")),
        Player(name: "Michael Smith",          country: "🇬🇧", imageURL: pdcImg("f657f9e0-f233-11f0-b80f-217d371c8b79")),
        Player(name: "Nathan Aspinall",        country: "🇬🇧", imageURL: pdcImg("f6372b70-f233-11f0-9303-5182eef97cd9")),
        Player(name: "Jonny Clayton",          country: "🏴󠁧󠁢󠁷󠁬󠁳󠁿", imageURL: pdcImg("f6647d00-f233-11f0-bdca-133e2e51708a")),
        Player(name: "Damon Heta",             country: "🇦🇺", imageURL: pdcImg("f4c3ec60-f233-11f0-8be2-5d81ca77fe21")),
        Player(name: "Dave Chisnall",          country: "🇬🇧", imageURL: pdcImg("f58e8f60-f233-11f0-8f68-e98be9e2ec48")),
        Player(name: "Danny Noppert",          country: "🇳🇱", imageURL: pdcImg("7847d390-f21a-11f0-9fa0-0dd7c602545d")),
        Player(name: "Josh Rock",              country: "🇬🇧", imageURL: pdcImg("f5db4fd0-f233-11f0-a60f-19bb93e6fb80")),
        Player(name: "Dimitri Van den Bergh",  country: "🇧🇪", imageURL: pdcImg("f6344540-f233-11f0-abc7-33a15d036ccb")),
        Player(name: "Dirk van Duijvenbode",   country: "🇳🇱", imageURL: pdcImg("f4f9a260-f233-11f0-a60f-19bb93e6fb80")),
        Player(name: "Joe Cullen",             country: "🇬🇧", imageURL: pdcImg("f517ffd0-f233-11f0-adbf-f569001aa27e")),
        Player(name: "Chris Dobey",            country: "🇬🇧", imageURL: pdcImg("f5267ec0-f233-11f0-8be2-5d81ca77fe21")),
        Player(name: "Stephen Bunting",        country: "🇬🇧", imageURL: pdcImg("782f1b70-f21a-11f0-8e4e-4b7ed58fd19c")),
        Player(name: "Ryan Searle",            country: "🇬🇧", imageURL: pdcImg("f6071ac0-f233-11f0-828f-515099993409")),
        Player(name: "Martin Schindler",       country: "🇩🇪", imageURL: pdcImg("f57d9f70-f233-11f0-9987-f7a824897129")),
        Player(name: "Krzysztof Ratajski",     country: "🇵🇱"),
        Player(name: "Karel Sedláček",         country: "🇨🇿"),
        Player(name: "Adam Gawlas",            country: "🇨🇿"),
        Player(name: "Mensur Suljović",        country: "🇦🇹", imageURL: pdcImg("f538ce40-f233-11f0-adbf-f569001aa27e")),
        Player(name: "Gabriel Clemens",        country: "🇩🇪", imageURL: pdcImg("f4b398b0-f233-11f0-adbf-f569001aa27e")),
        Player(name: "Raymond van Barneveld",  country: "🇳🇱", imageURL: pdcImg("f5c92760-f233-11f0-adbf-f569001aa27e")),
        Player(name: "Kim Huybrechts",         country: "🇧🇪", imageURL: pdcImg("f56b01d0-f233-11f0-a60f-19bb93e6fb80")),
        Player(name: "Jose de Sousa",          country: "🇵🇹"),
        Player(name: "Callan Rydz",            country: "🇬🇧", imageURL: pdcImg("f6424f00-f233-11f0-a501-53f8694d36c4")),
        Player(name: "Andrew Gilding",         country: "🇬🇧", imageURL: pdcImg("f547e970-f233-11f0-8be2-5d81ca77fe21")),
        Player(name: "Ricardo Pietreczko",     country: "🇩🇪", imageURL: pdcImg("f3b2ca80-f233-11f0-adbf-f569001aa27e")),
        Player(name: "Jeffrey de Zwaan",       country: "🇳🇱", imageURL: pdcImg("adbbeae0-f312-11f0-b289-836e88b22e4c")),
        Player(name: "Brendan Dolan",          country: "🇮🇪", imageURL: pdcImg("f64905c0-f233-11f0-b2d6-31a38d16a83c")),
        Player(name: "Adrian Lewis",           country: "🇬🇧"),
        Player(name: "James Wade",             country: "🇬🇧", imageURL: pdcImg("f5e0ce10-f233-11f0-8be2-5d81ca77fe21")),
        Player(name: "Ian White",              country: "🇬🇧", imageURL: pdcImg("f58da500-f233-11f0-916f-9317f3943d29")),
        Player(name: "Devon Petersen",         country: "🇿🇦"),
        Player(name: "Fallon Sherrock",        country: "🇬🇧"),
        Player(name: "Beau Greaves",           country: "🇬🇧"),
    ]
}
