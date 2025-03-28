# PythonIOSDemo

Demo project + learning material. Integrating and running Python on iOS with help of [beeware/Python-Apple-Support](https://github.com/beeware/Python-Apple-support), which is based on [cpython](https://github.com/python/cpython).

This product has two branches: 
`initial` - Educational branch. Contains the iOS app with Python interpreter (implemented in `PythonRunner`). However, the Python.xcframework is missing and needs to be added. The process isn't that simple, since you also have to configure the project and add couple of scripts. This readme contains instructions how to do it. Use it to practice Python integration, before doing it in your project. Compare the result with the main branch.
`main` - Demo project, where you can freely type and run Python code within iOS app. Python.xcframework is installed and the build is configured appropriately.

# Integrating Python

You are on the `initial` branch.

To integrate the Python we take a shortcut and use [beeware/Python-Apple-Support](https://github.com/beeware/Python-Apple-support) project, which contains huge -sh script to generate .xcframework from cpython lib, configured for the specified Apple platform.

1. Clone it: `git@github.com:beeware/Python-Apple-support.git`

2. Determine the version of Python that you need. If you debug your Python code before adding to the iOS project, it makes sense to match the version of the python on your mac:
`python3 --version`
In my case it was 3.13.2, so I switched to the appropriate branch:
`git switch 3.13`

3. Now run `make iOS` and wait several minutes to the framework to be built. The resulting archive would be placed in `dist/`. It will contain the Python.xcframework and a test iOS project, in `testbed/`. The test project is useful in several ways:
- You can use it as an example of correct configuration.
- You can run tests for your Python modules there, as well as verify the framework itself.
- Source of `dylib-Info-template.plist`.

4. Now we need that framework to be drugged and dropped to Xcode, in the root of PythonIOSDemo project. You can place it in a Frameworks folder, however for that you need to edit path in `Install Target Specific Python Standard Library` script, that we will cover later. Select `Embed and Sign` in General tab under Frameworks, Libraries and Embedded Content.

5. Add `dylib-Info-template.plist` from `testbed/iOSTestbed/` and include it to the target. It's required for the `Prepare Python Binary Modules` script, which we will cover later.

6. Now you are ready to follow the step-by step guide [Adding Python to an iOS project](https://docs.python.org/3/using/ios.html#adding-python-to-an-ios-project). 
- Follow steps starting from 4. You'll be asked to apply several build settings and two run scripts, mentioned above. Note, that both scripts should be in right place.
- Skip step 10, since we already have the interpreter.
