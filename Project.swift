import ProjectDescription

let project = Project(
    name: "CodeRadio",
    targets: [
        .target(
            name: "CodeRadio",
            destinations: .macOS,
            product: .app,
            bundleId: "com.yourname.CodeRadio",
            deploymentTargets: .macOS("13.5"),
            infoPlist: .extendingDefault(with: [
                "NSAppTransportSecurity": [
                    "NSAllowsArbitraryLoads": true
                ],
                "NSUserNotificationAlertStyle": "banner",
                "NSUserNotificationDefaultSoundName": "NSUserNotificationDefaultSoundName",
                "UILaunchStoryboardName": "",
                "UISceneConfigurations": [:],
                "NSMainStoryboardFile": "",
                "NSPrincipalClass": "NSApplication",
                "LSUIElement": true,
                "CFBundleIconFile": "AppIcon",
                "CFBundleIconName": "AppIcon",
                "CFBundleDisplayName": "CodeRadio"
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
