import Foundation

/// A glob pattern configuration representing source files and its compiler flags, if any.
public struct SourceFileGlob: Codable, Equatable, Sendable {
    /// Type of the source file.
    public enum FileType: String, Codable, Sendable {
        /// File is already present on disk before generating the project.
        case alwaysPresent

        /// File was generated during the generation of the project, e.g. by a pre-build phase
        /// script.
        case generated
    }

    /// Glob pattern to the source files.
    public var glob: Path

    /// Glob patterns for source files that will be excluded.
    public var excluding: [Path]

    /// The compiler flags to be set to the source files in the sources build phase.
    public var compilerFlags: String?

    /// The source file attribute to be set in the build phase.
    public var codeGen: FileCodeGen?

    /// Source file condition for compilation
    public var compilationCondition: PlatformCondition?

    /// Type of the file.
    public var type: FileType

    /// Returns a source glob pattern configuration.
    /// Used for file there were already present during the generation.
    ///
    /// - Parameters:
    ///   - glob: Glob pattern to the source files.
    ///   - excluding: Glob patterns for source files that will be excluded.
    ///   - compilerFlags: The compiler flags to be set to the source files in the sources build phase.
    ///   - codeGen: The source file attribute to be set in the build phase.
    ///   - compilationCondition: Condition for file compilation.
    public static func glob(
        _ glob: Path,
        excluding: [Path] = [],
        compilerFlags: String? = nil,
        codeGen: FileCodeGen? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> Self {
        .init(
            glob: glob,
            excluding: excluding,
            compilerFlags: compilerFlags,
            codeGen: codeGen,
            compilationCondition: compilationCondition,
            type: .alwaysPresent
        )
    }

    public static func glob(
        _ glob: Path,
        excluding: Path?,
        compilerFlags: String? = nil,
        codeGen: FileCodeGen? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> Self {
        let paths: [Path] = excluding.flatMap { [$0] } ?? []
        return .init(
            glob: glob,
            excluding: paths,
            compilerFlags: compilerFlags,
            codeGen: codeGen,
            compilationCondition: compilationCondition,
            type: .alwaysPresent
        )
    }

    /// Returns a source generated source file configuration, for a single generated file.
    ///
    /// - Parameters:
    ///   - path: Path to the generated file. Assumed to be a specific path (as oppose to a glob pattern).
    ///   - compilerFlags: The compiler flags to be set to the source files in the sources build phase.
    ///   - codeGen: The source file attribute to be set in the build phase.
    ///   - compilationCondition: Condition for file compilation.

    public static func generated(
        _ path: Path,
        compilerFlags: String? = nil,
        codeGen: FileCodeGen? = nil,
        compilationCondition: PlatformCondition? = nil
    ) -> Self {
        .init(
            glob: path,
            excluding: [],
            compilerFlags: compilerFlags,
            codeGen: codeGen,
            compilationCondition: compilationCondition,
            type: .generated
        )
    }
}

extension SourceFileGlob: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.init(
            glob: .path(value),
            excluding: [],
            compilerFlags: nil,
            codeGen: nil,
            compilationCondition: nil,
            type: .alwaysPresent
        )
    }
}

/// A collection of source file globs.
public struct SourceFilesList: Codable, Equatable, Sendable {
    /// List glob patterns.
    public var globs: [SourceFileGlob]

    /// Creates the source files list with the glob patterns.
    ///
    /// - Parameter globs: Glob patterns.
    public static func sourceFilesList(globs: [SourceFileGlob]) -> Self {
        self.init(globs: globs)
    }

    /// Creates the source files list with the glob patterns as strings.
    ///
    /// - Parameter globs: Glob patterns.
    public static func sourceFilesList(globs: [String]) -> Self {
        sourceFilesList(globs: globs.map(SourceFileGlob.init))
    }

    /// Returns a sources list from a list of paths.
    /// - Parameter paths: Source paths.
    public static func paths(_ paths: [Path]) -> SourceFilesList {
        SourceFilesList(globs: paths.map { .glob($0) })
    }
}

/// Support file as single string
extension SourceFilesList: ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self = .sourceFilesList(globs: [value])
    }
}

extension SourceFilesList: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: SourceFileGlob...) {
        self.init(globs: elements)
    }
}
