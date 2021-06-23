import ProjectDescription
import ProjectDescriptionHelpers

var actions: [ProjectDescription.Up] {
    var actions: [ProjectDescription.Up] = [
        .custom(
            name: "Generating files",
            meet: ["sh", "Scripts/generate_files.sh"],
            isMet: ["exit", "-1"]),
    ]
    
    if isCI == false {
        actions.append(contentsOf: [
            .homebrew(packages: ["mint"]),
            .mint(),
        ])
    }
    
    return actions
}

let setup = Setup(actions)
