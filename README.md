# rome plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-rome)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-rome`, add it to your project by running:

```bash
fastlane add_plugin rome
```

## About rome

A S3 cache tool for Carthage

Please see more on the tool's repo: [Rome](https://github.com/blender/rome)

## Example

```bash
rome(
    frameworks: ["MyFramework1", "MyFramework2"],   # Specify which frameworks to upload or download
    command: "upload",                              # One of: download, upload, list
    verbose: false,                                 # Print rome output inline
    platform: "all",                                # Define which platform to build for (one of ‘all’, ‘Mac’, ‘iOS’, ‘watchOS’, ‘tvOS‘, or comma-separated values of the formers except for ‘all’)
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About `fastlane`

`fastlane` is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
