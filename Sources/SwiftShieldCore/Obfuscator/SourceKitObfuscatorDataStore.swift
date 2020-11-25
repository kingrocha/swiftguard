import Foundation

final class SourceKitObfuscatorDataStore {
    var processedUsrs = Set<String>()
    var obfuscationDictionary = [String: String]()
    var obfuscatedNames = Set<String>()
    var usrRelationDictionary = [String: SKResponseDictionary]()
    var indexedFiles = [IndexedFile]()
    var codableEnumUSRs = Set<String>() // CodingKeysFix, mariusms75, 20 nov 2020
    var plists = Set<File>()
}
