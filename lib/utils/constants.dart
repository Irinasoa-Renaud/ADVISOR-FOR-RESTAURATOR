/// debug tools
String get logTrace =>
    '[LOG_TRACE] ' +
    StackTrace.current.toString().split("\n").toList()[1].split("      ").last;
