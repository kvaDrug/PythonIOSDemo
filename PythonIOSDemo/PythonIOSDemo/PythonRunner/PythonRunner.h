//
//  PythonRunner.h
//  PythonIOSDemo
//
//  Created by Uladzimir Kelin on 24.03.25.
//

#import <Foundation/Foundation.h>

/// The class that managers Python C API, provided by Python.xcframework.
/// Provides serveral methods to run python code.
/// - Important: Install Python.xcframework following the instructions in README.
/// - Note: We could use cpython API directly in Swift, however it involves many "unsafe pointers"
/// management, so it's naturally easier for me to work with C in Objective-C. It's my preference.
@interface PythonRunner: NSObject

+ (nonnull instancetype)shared;

/// Do not call this method directly, use  `shared` instead.
- (nonnull instancetype) __unavailable init;

// MARK: Run script

/// Run the python string preserving the global variables and return the result.
/// Runs both expressions and assignments.
/// Relies on `PyRun_String` which provides more control.
/// - returns: The result of expression, if the expression is passed, or None if there's an
/// assignment or function call. If an error occures, will return error description.
- (NSString *_Nullable)runString:(NSString *_Nonnull)str;

/// Runs a string. Will also preserve global variables, unable to return any result.
- (void)runSimpleString:(NSString *_Nonnull)str;

- (void)runSimpleFile:(NSString *_Nonnull)path;

- (void)runSimpleFileWithName:(NSString *_Nonnull)name;

// MARK: Demo

- (void)helloWorld;

- (void)globalVarDemo;

@end
