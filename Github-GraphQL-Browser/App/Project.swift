import ProjectDescription
import ProjectDescriptionHelpers

let appSettings: SettingsDictionary = ["CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES"]

let iosConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: SettingsDictionary()
            .codeSignIdentityAppleDevelopment()
            .merging(appSettings),
        xcconfig: .relativeToCurrentFile("SupportingFiles/Configuration/Debug.xcconfig")),
    .release(
        name: "Release",
        settings: SettingsDictionary()
            .manualCodeSigning()
            .merging(appSettings),
        xcconfig: .relativeToCurrentFile("SupportingFiles/Configuration/Release.xcconfig")),
]

let iosSettings = Settings.settings(configurations: iosConfigurations)

let rootPath = "Github-GraphQL-Browser"

let iosTarget = Target(
    name: "GithubQL-iOS",
    platform: .iOS,
    product: .app,
    bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
    deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
    infoPlist: .file(path: "SupportingFiles/Info.plist"),
    sources: SourceFilesList(globs: [SourceFileGlob("Sources/**")]),
    resources: [
        .glob(pattern: "Resources/**"),
    ],
    scripts: isCI ? [] : [
        .post(
            path: .relativeToRoot("Scripts/swiftlint.sh"),
            arguments: ["../../.swiftlint.yml"],
            name: "Swiftlint"),
    ],
    dependencies:
        Feature.allCases.map {
            TargetDependency.project(
                target: $0.name,
                path: .relativeToRoot($0.path))
        }
        +
        Foundation.allCasesForApp.map {
            TargetDependency.project(
                target: $0.name,
                path: .relativeToRoot($0.path))
        }
        + [
        .project(target: Mock.networking.name, path: .relativeToRoot(Mock.networking.path)),
        ],
    settings: iosSettings)

let uiTestsTarget = Target(
    name: "GithubQL-iOS-UITests",
    platform: .iOS,
    product: .uiTests,
    bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)UITests",
    infoPlist: .default,
    sources: "UITests/**",
    dependencies: [
        .target(name: "GithubQL-iOS"),
    ])

let project = Project(
    name: "GithubQL",
    settings: iosSettings,
    targets: [
        iosTarget,
        uiTestsTarget,
    ],
    additionalFiles: [])
