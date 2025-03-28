//
//  PythonRunner.m
//  PythonIOSDemo
//
//  Created by Uladzimir Kelin on 24.03.25.
//

#import "PythonRunner.h"
// TODO: Import Python.xframework, see README
#import <Python/Python.h>

@implementation PythonRunner {
    /// Global variables should percist between -runString: calls.
    PyObject* global_dict;
}

+ (instancetype)shared
{
    static id sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        PyStatus status;
        PyPreConfig preconfig;
        PyConfig config;
        
        // Generate an isolated Python configuration.
        NSLog(@"Configuring isolated Python...");
        PyPreConfig_InitIsolatedConfig(&preconfig);
        PyConfig_InitIsolatedConfig(&config);
        
        // Configure the Python interpreter:
        // Enforce UTF-8 encoding for stderr, stdout, file-system encoding and locale.
        // See https://docs.python.org/3/library/os.html#python-utf-8-mode.
        preconfig.utf8_mode = 1;
        // Don't buffer stdio. We want output to appears in the log immediately
        config.buffered_stdio = 0;
        // Don't write bytecode; we can't modify the app bundle
        // after it has been signed.
        config.write_bytecode = 0;
        // Ensure that signal handlers are installed
        config.install_signal_handlers = 1;
        
        // For debugging - enable verbose mode.
        // config.verbose = 1;

        NSLog(@"Pre-initializing Python runtime...");
        status = Py_PreInitialize(&preconfig);
        if (PyStatus_Exception(status)) {
            NSLog(@"Unable to pre-initialize Python interpreter: %s", status.err_msg);
            PyConfig_Clear(&config);
            return nil;
        }
        
        // Setup necessary environment variables and initialize python
        // Special environment to prefer .pyo
        int err = 0;
        if ((err = putenv("PYTHONOPTIMIZE=1"))) {
            NSLog(@"WARNING! Failed to set PYTHONOPTIMIZE=1, error code: %d", err);
        }
        // Don't write bytecode because the process
        // will not have write permissions on the device.
        if ((err = putenv("PYTHONDONTWRITEBYTECODE=1"))) {
            NSLog(@"WARNING! Failed to set PYTHONDONTWRITEBYTECODE=1, error code: %d", err);
        }

        // Home
        NSString *pythonHome = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/Python/Resources"];
        NSLog(@"PythonHome is: %@", pythonHome);
        NSString *pythonHomeEnv = [NSString stringWithFormat:@"PYTHONHOME=%@", pythonHome];
        if ((err = putenv((char *)pythonHomeEnv.UTF8String))) {
            NSLog(@"ERROR! Failed to set PYTHONHOME, error code: %d", err);
        }

        // iOS provides a specific directory for temp files.
        NSString *tmpPathEnv = [NSString stringWithFormat:@"TMP=%@", NSTemporaryDirectory(), nil];
        putenv((char *)tmpPathEnv.UTF8String);

        NSLog(@"Initializing Python runtime...");
        status = Py_InitializeFromConfig(&config);
        if (PyStatus_Exception(status)) {
            NSLog(@"Unable to initialize Python interpreter: %s", status.err_msg);
            PyConfig_Clear(&config);
            return nil;
        }
        
        global_dict = PyDict_New();
    }
    return self;
}

- (void)dealloc
{
    Py_DECREF(global_dict);
    Py_Finalize();
}

// MARK: Run script

- (NSString *_Nullable)runString:(NSString *)str
{
    // Create local dictionary for capturing the result
    PyObject* local_dict = PyDict_New();
    
    PyObject* result = PyRun_String(str.UTF8String, Py_eval_input, global_dict, global_dict);
    if (result == NULL) {
        PyErr_Clear();
        result = PyRun_String(str.UTF8String, Py_single_input, global_dict, global_dict);
    }
    
    if (result == NULL) {
        // Handle error
        PyObject* type;
        PyObject* value;
        PyObject* traceback;
        
        // Fetch the current exception information
        PyErr_Fetch(&type, &value, &traceback);
        
        // Normalize the exception
        PyErr_NormalizeException(&type, &value, &traceback);
        
        // Convert exception to string representation
        PyObject* error_string = PyObject_Str(value);
        NSString* errorNSString = [self convertPyObjectToNSString:error_string];
        NSLog(@"%@", errorNSString);
        
        // Clear the error indicator
        PyErr_Clear();
        
        // Cleanup references
        Py_XDECREF(type);
        Py_XDECREF(traceback);
        Py_DECREF(error_string);
        
        return errorNSString;
    }
    
    NSString* resultStr = [self convertPyObjectToNSString:result];
    
    // Clean up
    Py_DECREF(local_dict);
    Py_DECREF(result);
    
    return resultStr;
}


- (void)runSimpleString:(NSString *)str
{
    PyRun_SimpleString(str.UTF8String);
}

- (void)runSimpleFile:(NSString *)path
{
    FILE *cfile = fopen(path.UTF8String, "r");
    if (cfile) {
        PyRun_SimpleFile(cfile, path.UTF8String);
        fclose(cfile);
    }
}

- (void)runSimpleFileWithName:(NSString *)name
{
    NSString *path = [NSBundle.mainBundle pathForResource:name ofType:@"py"];
    [self runSimpleFile:path];
}

// MARK: Demo

- (void)helloWorld
{
    PyRun_SimpleString("print('Hello world!')");
}

- (void)globalVarDemo
{
    PyRun_SimpleString("context = {'x': 15}");
    PyRun_SimpleString("print(context['x'])");
    PyRun_SimpleString("context['x'] = 25");
    PyRun_SimpleString("print(context['x'])");
}

// MARK: Output

- (NSString *_Nullable)convertPyObjectToNSString:(PyObject *)pyObject {
    // Check if the object is NULL
    if (pyObject == NULL) {
        return nil;
    }
    
    // Check if it's a Python string
    if (PyUnicode_Check(pyObject)) {
        // Convert PyObject to a UTF-8 encoded C string
        const char* utf8String = PyUnicode_AsUTF8(pyObject);
        
        if (utf8String) {
            // Convert C string to NSString
            return [NSString stringWithUTF8String:utf8String];
        }
    }
    
    // If not a string, try converting to a string representation
    // This uses Python's repr() function
    PyObject* reprMethod = PyObject_Repr(pyObject);
    if (reprMethod) {
        const char* utf8String = PyUnicode_AsUTF8(reprMethod);
        
        // Create NSString and clean up
        NSString* resultString = utf8String ? [NSString stringWithUTF8String:utf8String] : nil;
        
        // Decrement reference count
        Py_DECREF(reprMethod);
        
        return resultString;
    }
    
    // Fallback if conversion fails
    return nil;
}

@end
