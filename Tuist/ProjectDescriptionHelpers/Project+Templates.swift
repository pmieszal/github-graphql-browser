import ProjectDescription

public let isCI = Environment.isCI?.getBoolean(default: false) ?? false
public let moduleBundleIdPrefix = "pl.patryk.mieszala.githubql"
public let testSuiteDependencies: [TargetDependency] = [
    .xctest,
    .package(product: "Quick"),
    .package(product: "Nimble"),
]
public let testSuitePackages: [Package] = [
    .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "9.1.0"),
]

// More info: https://tuist.io/docs/architectures/microfeatures/

public enum uFeatureTarget: CaseIterable {
    case framework
    case tests
    case uiTests
    case suite
    case example
    case mocks
    
    public static var feature: Set<uFeatureTarget> {
        Set([.framework, .mocks, .tests, .uiTests, .example])
    }
    
    public static var foundation: Set<uFeatureTarget> {
        Set([.framework, .mocks, .tests])
    }
    
    var suffix: String {
        switch self {
        case .framework:
            return ""
        case .tests:
            return "Tests"
        case .uiTests:
            return "UITests"
        case .suite:
            return "Suite"
        case .example:
            return "Example"
        case .mocks:
            return "Mocks"
        }
    }
}

/*
 So this method is messy right now 😅. That's because it evolved through all my different projects.
 Basically it handles modules creation with all kinds of needed configurations.
 
 I'm about to clean it up and publish as Tuist Plugin.
 https://docs.tuist.io/plugins/creating-plugins
 */

public extension Project {
    static func framework(type: Module,
                          product: Product = .framework,
                          deploymentTarget: DeploymentTarget = .iOS(
                              targetVersion: "13.0",
                              devices: [.iphone, .ipad]),
                          targets: Set<uFeatureTarget>,
                          actions: [ProjectDescription.TargetAction] = [],
                          packages: [Package] = [],
                          externalDependencies: [TargetDependency] = [],
                          internalDependencies: [Foundation] = [],
                          mockDependencies: [Module] = [],
                          testsDependencies: [Mock] = [],
                          sdks: [String] = [],
                          sources: [SourceFileGlob] = [],
                          resources: ResourceFileElements? = nil,
                          headers: Headers? = nil,
                          settings: SettingsDictionary = [:],
                          testsSettings: SettingsDictionary = [:],
                          additionalPlistRows: [String: ProjectDescription.InfoPlist.Value] = [:])
        -> Project {
        let settings = settings
            .merging(["CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES"])
        
        let configurations: [CustomConfiguration] = [
            .debug(
                name: "Debug",
                settings: SettingsDictionary()
                    .otherSwiftFlags(isCI ? "-DIS_CI" : "")
                    .merging(settings)),
            .release(
                name: "Release",
                settings: SettingsDictionary()
                    .manualCodeSigning()
                    .merging(settings)),
        ]
        
        let testsSettings = testsSettings
            .merging(["CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES"])
        
        let testsConfigurations: [CustomConfiguration] = [
            .debug(
                name: "Debug",
                settings: SettingsDictionary()
                    .otherSwiftFlags(isCI ? "-DIS_CI" : "")
                    .merging(testsSettings)),
            .release(
                name: "Release",
                settings: SettingsDictionary()
                    .manualCodeSigning()
                    .merging(testsSettings)),
        ]
        
        var testsDependencies = testsDependencies.map { mock -> TargetDependency in
            .project(target: mock.name, path: .relativeToRoot(mock.path))
        }
        testsDependencies.append(contentsOf: testSuiteDependencies)
        testsDependencies.append(contentsOf: [
            .target(name: "\(type.name)\(uFeatureTarget.mocks.suffix)"),
            .project(target: Foundation.testsUtils.name, path: .relativeToRoot(Foundation.testsUtils.path)),
        ])
        
        if targets.contains(.example), targets.contains(.tests) {
            testsDependencies.append(.target(name: "\(type.name)\(uFeatureTarget.example.suffix)"))
        }
        
        // Target dependencies
        var targetDependencies: [TargetDependency] = internalDependencies.map {
            .project(target: $0.name, path: .relativeToRoot($0.path))
        }
        targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0) })
        
        var commonRows: [String: ProjectDescription.InfoPlist.Value] = [
            "CFBundleLocalizations": ["en"],
        ]
        commonRows = commonRows.merging(additionalPlistRows) { $1 }
        
        let mockDependencies = targetDependencies + mockDependencies.map {
            .project(target: $0.name, path: .relativeToRoot($0.path))
        }
        
        var actions = actions
        
        if isCI == false {
            actions.append(
                .post(
                    path: .relativeToRoot("Scripts/swiftlint.sh"),
                    arguments: ["../../../.swiftlint.yml"],
                    name: "Swiftlint"))
        }
        
        // Project targets
        var projectTargets: [Target] = []
        let frameworkSources = SourceFilesList(globs: sources + ["Sources/**/*.swift"])
        
        for target in targets {
            switch target {
            case .framework:
                projectTargets.append(
                    Target(
                        name: type.name,
                        platform: .iOS,
                        product: product,
                        bundleId: "\(moduleBundleIdPrefix).\(type.name)",
                        deploymentTarget: deploymentTarget,
                        infoPlist: InfoPlist.extendingDefault(with: commonRows),
                        sources: frameworkSources,
                        resources: resources,
                        headers: headers,
                        actions: actions,
                        dependencies: targetDependencies + externalDependencies,
                        settings: Settings(
                            base: [
                                "CODE_SIGN_IDENTITY": "",
                                "CODE_SIGNING_REQUIRED": "NO",
                                "CODE_SIGN_ENTITLEMENTS": "",
                                "CODE_SIGNING_ALLOWED": "NO",
                            ],
                            configurations: configurations)))
            case .tests,
                 .suite:
                projectTargets.append(
                    Target(
                        name: "\(type.name)\(target.suffix)",
                        platform: .iOS,
                        product: .unitTests,
                        bundleId: "\(moduleBundleIdPrefix).\(type.name)\(target.suffix)",
                        infoPlist: .default,
                        sources: SourceFilesList(
                            globs: [
                                "\(target.suffix)/**/*.swift",
                                "\(target.suffix)/**/*.m",
                            ]),
                        headers: Headers(
                            public: nil,
                            private: nil,
                            project: "\(target.suffix)/**/*.h"),
                        dependencies: targetDependencies + testsDependencies,
                        settings: Settings(
                            base: [
                                "TEST_HOST": "",
                            ],
                            configurations: testsConfigurations)))
            case .uiTests:
                guard isCI == false else {
                    break
                }
                
                projectTargets.append(
                    Target(
                        name: "\(type.name)\(target.suffix)",
                        platform: .iOS,
                        product: .uiTests,
                        bundleId: "\(moduleBundleIdPrefix).\(type.name)\(target.suffix)",
                        infoPlist: .default,
                        sources: SourceFilesList(
                            globs: [
                                "\(target.suffix)/**/*.swift",
                                "\(target.suffix)/**/*.m",
                            ]),
                        headers: Headers(
                            public: nil,
                            private: nil,
                            project: "\(target.suffix)/**/*.h"),
                        dependencies: targetDependencies + testsDependencies,
                        settings: Settings(configurations: testsConfigurations)))
            case .example:
                projectTargets.append(
                    Target(
                        name: "\(type.name)\(target.suffix)",
                        platform: .iOS,
                        product: .app,
                        bundleId: "\(moduleBundleIdPrefix).\(type.name)\(target.suffix)",
                        deploymentTarget: deploymentTarget,
                        infoPlist: .extendingDefault(with: [
                            "UILaunchStoryboardName": .string("LaunchScreen"),
                            "NSBluetoothAlwaysUsageDescription": .string("Bluetooth permission"),
                        ]),
                        sources: SourceFilesList(globs: ["\(target.suffix)/**/*.swift"]),
                        resources: resources,
                        dependencies: targetDependencies + [.target(name: "\(type.name)\(uFeatureTarget.mocks.suffix)")],
                        settings: Settings(
                            base: [
                                "ASSETCATALOG_COMPILER_APPICON_NAME": "",
                                "DEVELOPMENT_TEAM": "", // TODO: this?
                            ],
                            configurations: configurations)))
            case .mocks:
                projectTargets.append(
                    Target(
                        name: "\(type.name)\(target.suffix)",
                        platform: .iOS,
                        product: .framework,
                        bundleId: "\(moduleBundleIdPrefix).\(type.name)\(target.suffix)",
                        deploymentTarget: deploymentTarget,
                        infoPlist: .default,
                        sources: SourceFilesList(globs: ["\(target.suffix)/**/*.swift"]),
                        resources: "\(target.suffix)/**/*.json",
                        dependencies: mockDependencies + [.target(name: "\(type.name)")],
                        settings: Settings(configurations: configurations)))
            }
        }
        
        var packages = packages
        packages.append(contentsOf: testSuitePackages)
        
        // Project
        return Project(
            name: type.name,
            packages: packages,
            settings: Settings(configurations: configurations),
            targets: projectTargets)
    }
}
