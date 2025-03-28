# PythonIOSDemo

Demo project + learning material. Integrating and running Python on iOS with help of [beeware/Python-Apple-Support](https://github.com/beeware/Python-Apple-support), which is based on [cpython](https://github.com/python/cpython).

This product has two branches: 
`initial` - Educational branch. Contains the iOS app with Python interpreter (implemented in `PythonRunner`). However, the Python.xcframework is missing and needs to be added. The process isn't that simple, since you also have to configure the project and add couple of scripts. This readme contains instructions how to do it. Use it to practice Python integration, before doing it in your project. Compare the result with the main branch.
`main` - Demo project, where you can freely type and run Python code within iOS app. Python.xcframework is installed and the build is configured appropriately.

[iOS project example](./screenshot.png)