## {Project Name} (init from readme/docs)

> {Project Description}

> {Project Purpose}

> {Project Status}

> {Project Team}

> {Framework/language/other(you think it is important to know)}



## Dependencies (init from programming language specification like package.json, requirements.txt, etc.)

* package1 (version): simple description
* package2 (version): simple description


## Development Environment

> include all the tools and environments needed to run the project
> makefile introduction (if exists)


## Structrue (init from project tree)

> It is essential to consistently refine the analysis down to the file level — this level of granularity is of utmost importance.

> If the number of files is too large, you should at least list all the directories, and provide comments for the parts you consider particularly important.

> In the code block below, add comments to the directories/files to explain their functionality and usage scenarios.

> if you think the directory/file is not important, you can not skip it, just add a simple comment to it.

> but if you think the directory/file is important, you should read the files and add more detail comments on it (e.g. add comments on the functions, classes, and variables. explain the functionality and usage scenarios. write the importance of the directory/file).
```
root
- .gitignore
- .metadata
- analysis_options.yaml
- android
    - .gitignore
    - app
        - build.gradle.kts
        - src
            - debug
                - AndroidManifest.xml
            - main
- assets    # 存放应用截图等资源文件，如 README.md 中引用的 create.jpg、detail.jpg
                - AndroidManifest.xml
                - kotlin
                    - com
                        - example
                            - igree
                                - MainActivity.kt
                - res
                    - drawable
                        - launch_background.xml
                    - drawable-v21
                        - launch_background.xml
                    - mipmap-hdpi
                        - ic_launcher.png
                    - mipmap-mdpi
                        - ic_launcher.png
                    - mipmap-xhdpi
                        - ic_launcher.png
                    - mipmap-xxhdpi
                        - ic_launcher.png
                    - mipmap-xxxhdpi
                        - ic_launcher.png
                    - values
                        - styles.xml
                    - values-night
                        - styles.xml
            - profile
                - AndroidManifest.xml
    - build.gradle.kts
    - gradle
        - wrapper
            - gradle-wrapper.properties
    - gradle.properties
    - settings.gradle.kts
- assets
    - create.jpg
    - detail.jpg
- ios
    - .gitignore
    - Flutter
        - AppFrameworkInfo.plist
        - Debug.xcconfig
        - Release.xcconfig
    - Runner
        - AppDelegate.swift
        - Assets.xcassets
            - AppIcon.appiconset
                - Contents.json
                - Icon-App-1024x1024@1x.png
                - Icon-App-20x20@1x.png
                - Icon-App-20x20@2x.png
                - Icon-App-20x20@3x.png
                - Icon-App-29x29@1x.png
                - Icon-App-29x29@2x.png
                - Icon-App-29x29@3x.png
                - Icon-App-40x40@1x.png
                - Icon-App-40x40@2x.png
                - Icon-App-40x40@3x.png
                - Icon-App-60x60@2x.png
                - Icon-App-60x60@3x.png
                - Icon-App-76x76@1x.png
                - Icon-App-76x76@2x.png
                - Icon-App-83.5x83.5@2x.png
            - LaunchImage.imageset
                - Contents.json
                - LaunchImage.png
                - LaunchImage@2x.png
                - LaunchImage@3x.png
                - README.md
        - Base.lproj
            - LaunchScreen.storyboard
            - Main.storyboard
        - Info.plist
        - Runner-Bridging-Header.h
    - Runner.xcodeproj
        - project.pbxproj
        - project.xcworkspace
            - contents.xcworkspacedata
            - xcshareddata
                - IDEWorkspaceChecks.plist
                - WorkspaceSettings.xcsettings
        - xcshareddata
            - xcschemes
                - Runner.xcscheme
    - Runner.xcworkspace
        - contents.xcworkspacedata
        - xcshareddata
            - IDEWorkspaceChecks.plist
            - WorkspaceSettings.xcsettings
    - RunnerTests
        - RunnerTests.swift
- lib
    - main.dart
    - models
        - .gitkeep
    - screens
        - history_screen.dart
        - home_screen.dart
        - record_detail_screen.dart
        - record_screen.dart
    - services
        - .gitkeep
    - widgets
        - .gitkeep
- linux
    - .gitignore
    - CMakeLists.txt
    - flutter
        - CMakeLists.txt
        - generated_plugins.cmake
        - generated_plugin_registrant.cc
        - generated_plugin_registrant.h
    - runner
        - CMakeLists.txt
        - main.cc
        - my_application.cc
        - my_application.h
- macos
    - .gitignore
    - Flutter
        - Flutter-Debug.xcconfig
        - Flutter-Release.xcconfig
        - GeneratedPluginRegistrant.swift
    - Runner
        - AppDelegate.swift
        - Assets.xcassets
            - AppIcon.appiconset
                - app_icon_1024.png
                - app_icon_128.png
                - app_icon_16.png
                - app_icon_256.png
                - app_icon_32.png
                - app_icon_512.png
                - app_icon_64.png
                - Contents.json
        - Base.lproj
            - MainMenu.xib
        - Configs
            - AppInfo.xcconfig
            - Debug.xcconfig
            - Release.xcconfig
            - Warnings.xcconfig
        - DebugProfile.entitlements
        - Info.plist
        - MainFlutterWindow.swift
        - Release.entitlements
    - Runner.xcodeproj
        - project.pbxproj
        - project.xcworkspace
            - xcshareddata
                - IDEWorkspaceChecks.plist
        - xcshareddata
            - xcschemes
                - Runner.xcscheme
    - Runner.xcworkspace
        - contents.xcworkspacedata
        - xcshareddata
            - IDEWorkspaceChecks.plist
    - RunnerTests
        - RunnerTests.swift
- pubspec.lock
- pubspec.yaml
- README.md
- test
    - widget_test.dart
- web
    - favicon.png
    - icons
        - Icon-192.png
        - Icon-512.png
        - Icon-maskable-192.png
        - Icon-maskable-512.png
    - index.html
    - manifest.json
- windows
    - .gitignore
    - CMakeLists.txt
    - flutter
        - CMakeLists.txt
        - generated_plugins.cmake
        - generated_plugin_registrant.cc
        - generated_plugin_registrant.h
    - runner
        - CMakeLists.txt
        - flutter_window.cpp
        - flutter_window.h
        - main.cpp
        - resource.h
        - resources
            - app_icon.ico
        - runner.exe.manifest
        - Runner.rc
        - utils.cpp
        - utils.h
        - win32_window.cpp
        - win32_window.h
```
