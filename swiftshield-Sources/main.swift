import Foundation

if CommandLine.arguments.contains("-help") {
    Logger.log(.helpText)
    exit()
}

Logger.verbose = CommandLine.arguments.contains("-verbose")
SKAPI.verbose = CommandLine.arguments.contains("-show-sourcekit-queries")

Logger.log(.version)
Logger.log(.verbose)

if let filePathToDeobfuscate = UserDefaults.standard.string(forKey: "deobfuscate") {
    if let mapFilePath = UserDefaults.standard.string(forKey: "deobfuscate-map") {
        let file = File(filePath: filePathToDeobfuscate)
        let mapFile = File(filePath: mapFilePath)
        Logger.log(.deobfuscatorStarted)
        Deobfuscator.deobfuscate(file: file, mapFile: mapFile)
        exit()
    } else {
        Logger.log(.helpText)
        exit(error: true)
    }
}

let automatic = CommandLine.arguments.contains("-automatic")

Logger.log(.mode)

let basePath = UserDefaults.standard.string(forKey: "project-root") ?? ""
let obfuscationCharacterCount = abs(UserDefaults.standard.integer(forKey: "obfuscation-character-count"))
let protectedClassNameSize = obfuscationCharacterCount == 0 ? 32 : obfuscationCharacterCount

let protector: Protector
if automatic {
    let schemeToBuild = UserDefaults.standard.string(forKey: "automatic-project-scheme") ?? ""
    let projectToBuild = UserDefaults.standard.string(forKey: "automatic-project-file") ?? ""
    let modulesToIgnore = UserDefaults.standard.string(forKey: "ignore-modules")?.components(separatedBy: ",") ?? []
    let excludePublic = CommandLine.arguments.contains("-exclude-public")
    protector = AutomaticSwiftShield(basePath: basePath, projectToBuild: projectToBuild, schemeToBuild: schemeToBuild, modulesToIgnore: Set(modulesToIgnore), protectedClassNameSize: protectedClassNameSize, excludePublic: excludePublic)
} else {
    let tag = UserDefaults.standard.string(forKey: "tag") ?? "__s"
    protector = ManualSwiftShield(basePath: basePath, tag: tag, protectedClassNameSize: protectedClassNameSize)
}

let obfuscationData = protector.protect()
if obfuscationData.obfuscationDict.isEmpty {
    Logger.log(.foundNothingError)
    exit(error: true)
}

protector.protectStoryboards(data: obfuscationData)
protector.writeToFile(data: obfuscationData)
protector.markProjectsAsProtected()
Logger.log(.finished)
exit()
