import ProjectDescription

let project = Project(
    name: "CodeRadio",
    targets: [
        .target(
            name: "CodeRadio",
            destinations: .macOS,
            product: .app,
            bundleId: "io.tuist.CodeRadio",
            deploymentTargets: .macOS("13.5"),
            infoPlist: .extendingDefault(with: [
                "NSAppTransportSecurity": [
                    "NSAllowsArbitraryLoads": true
                ],
                "NSUserNotificationAlertStyle": "alert",
                "UILaunchStoryboardName": "",
                "UISceneConfigurations": [:],
                "NSMainStoryboardFile": "",
                "NSPrincipalClass": "NSApplication",
                "LSUIElement": true
            ]),
            sources: ["CodeRadio/Sources/**"],
            resources: ["CodeRadio/Resources/**"],
            dependencies: [
                .sdk(name: "AVFoundation", type: .framework),
                .sdk(name: "UserNotifications", type: .framework)
            ]
        ),
        .target(
            name: "CodeRadioTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.CodeRadioTests",
            deploymentTargets: .macOS("13.5"),
            infoPlist: .default,
            sources: ["CodeRadio/Tests/**"],
            resources: [],
            dependencies: [.target(name: "CodeRadio")]
        ),
    ]
)
