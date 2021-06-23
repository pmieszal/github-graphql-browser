import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    type: Foundation.testsUtils,
    targets: [.framework],
    externalDependencies: testSuiteDependencies)
