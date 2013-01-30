#ifdef DEBUG                                                                                                                                                             
#define TRACE(fmt, ...) NSLog(@"%s" fmt, __PRETTY_FUNCTION__, ##__VA_ARGS__)                                                                                         
#define LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)                                                                                                                      

#else                                                                                                                                                                    
#define TRACE(fmt, ...)                                                                                                                                
#define LOG(fmt, ...)                                                                                                                                    

#endif 
