import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "Github-GraphQL-Browser",
    projects: ["Github-GraphQL-Browser/App"] +
        Feature.allCases.map { Path($0.path) } +
        Foundation.allCases.map { Path($0.path) })
