import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    type: Feature.repositoryDetails,
    targets: uFeatureTarget.feature,
    internalDependencies: [
        .domain,
        .core,
    ],
    mockDependencies: [
        Foundation.networking,
        Foundation.appSecrets,
        Mock.networking,
    ],
    testsDependencies: [
        .networking
    ],
    resources: [
        .glob(pattern: "**/*.xib"),
        .glob(pattern: "Resources/**/*"),
    ])
