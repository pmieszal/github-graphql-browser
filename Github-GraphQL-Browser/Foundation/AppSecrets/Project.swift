import ProjectDescription
import ProjectDescriptionHelpers

let settings: SettingsDictionary = ["CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES"]

let configuration: [Configuration] = [
    .debug(
        name: "Debug",
        settings: SettingsDictionary()
            .merging(settings),
        xcconfig: .relativeToCurrentFile("SupportingFiles/Configuration/Debug.xcconfig")),
    .release(
        name: "Release",
        settings: SettingsDictionary()
            .manualCodeSigning()
            .merging(settings),
        xcconfig: .relativeToCurrentFile("SupportingFiles/Configuration/Release.xcconfig")),
]

let type = Foundation.appSecrets

let target = Target(
    name: type.name,
    platform: .iOS,
    product: .framework,
    bundleId: "\(moduleBundleIdPrefix).\(type.name)",
    deploymentTarget: .iOS(
        targetVersion: "13.0",
        devices: [.iphone, .ipad]),
    infoPlist: InfoPlist.default,
    sources: [
        "SupportingFiles/**/*.swift",
    ],
    resources: [
        "Scripts/**/*",
        "Sourcery/**/*",
    ],
    scripts: [
        .pre(
            path: .relativeToManifest("Scripts/generate_secrets.sh"),
            arguments: [],
            name: "Generate secrets"),
    ],
    settings: Settings.settings(
        base: [
            "CODE_SIGN_IDENTITY": "",
            "CODE_SIGNING_REQUIRED": "NO",
            "CODE_SIGN_ENTITLEMENTS": "",
            "CODE_SIGNING_ALLOWED": "NO",
        ],
        configurations: configuration))

let project = Project(
    name: type.name,
    settings: Settings.settings(configurations: configuration),
    targets: [target])
