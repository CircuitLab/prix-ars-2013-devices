#ifdef NNWEBSOCKET_DEBUG_TRACE
#define TRACE(fmt, ...) NSLog(@"%s" fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define TRACE(fmt, ...)
#endif

#ifdef NNWEBSOCKET_DEBUG_LOG
#define LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#define LOG(fmt, ...)
#endif
