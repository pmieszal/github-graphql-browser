import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    type: Foundation.networking,
    targets: uFeatureTarget.foundation,
    actions: [
        .pre(path: "Scripts/generate_graphql_api.sh", name: "Generate Apollo GraphQL API"),
    ],
    packages: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", .exact("0.43.0")),
    ],
    externalDependencies: [
        .package(product: "Apollo"),
        .package(product: "ApolloSQLite"),
    ],
    internalDependencies: [
        .domain,
    ],
    resources: [
        "Queries/**/*",
        "Schema/**/*",
        "Scripts/**/*"
    ])
