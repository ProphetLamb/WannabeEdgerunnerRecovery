module Edgerunning.Logging
// Copyright (c) 2022 ProphetLamb
// Source provided under the MIT licence
//
// # Description
// This file contains logging utilities.
//
// # Usage
// Copy the file to your mod's top-level dir, and replace the module `[your_mod].Logging`.
// Replace `[WER]` with the initials of the specific mod in brackets.
// Import the utilities in your fils, using `import [your_mod].Logging.*`.
//
// Set the CombinedLogLevel value according to the table below.
// | LogLevel | Value | Combined |
// | -------- | ----- | -------- |
// | Error    | 1     | 1        |
// | Warn     | 2     | 3        |
// | Info     | 4     | 7        |
// | Trace    | 8     | 15       |
// | Debug    | 16    | 31       |
// I suggest the value 3 for release, and 31 for testing.

public static func CombinedLogLevel() -> Int32 { return 3; }

/// Logs a debug message useful for validating the state during development, but otherwise not of import.
public static func LDebug(const str: script_ref<String>) -> Void {
  if (CombinedLogLevel() & 16) != 0 {
    LogChannel(n"DEBUG", "[DEBUG][WER] " + str);
  };
}

/// Logs events, requests and similar other method calls.
public static func LTrace(const str: script_ref<String>) -> Void {
  if (CombinedLogLevel() & 8) != 0 {
    LogChannel(n"DEBUG", "[TRACE][WER] " + str);
  };
}

/// Logs a message that could be important for the user.
public static func LInfo(const str: script_ref<String>) -> Void {
  if (CombinedLogLevel() & 4) != 0 {
    LogChannel(n"DEBUG", "[INFO ][WER] " + str);
  };
}

/// Logs a warning, a unexpected state, that can be recovered without sideeffects.
public static func LWarn(const str: script_ref<String>) -> Void {
  if (CombinedLogLevel() & 2) != 0 {
    LogChannel(n"DEBUG", "[WARN ][WER] " + str);
  };
}

/// Logs an error, a unexpected state, that cannot be recovered without sideeffects.
public static func LError(const str: script_ref<String>) -> Void {
  if (CombinedLogLevel() & 1) != 0 {
    LogChannel(n"DEBUG", "[ERROR][WER] " + str);
  };
}

/// Logs an error, if the object is no defined. Returns `true`, if the object is *undefined*; otherwise `false`
public static func LErrorIfUndef(const o: ref<IScriptable>, n: CName) -> Bool {
  if !IsDefined(o) {
    LError(s"\(n) is undefined");
    return true;
  }
  return false;
}
