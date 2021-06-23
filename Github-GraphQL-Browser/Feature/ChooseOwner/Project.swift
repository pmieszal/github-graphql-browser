import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    type: Feature.chooseOwner,
    targets: uFeatureTarget.feature,
    internalDependencies: [
        Foundation.domain,
    ],
    resources: [
        .glob(pattern: "**/*.xib"),
        .glob(pattern: "Resources/**/*"),
    ])
