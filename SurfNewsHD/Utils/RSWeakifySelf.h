/*
 https://gist.github.com/rabovik/4707815
 */

/**
 * Several macros simplifying use of weak references to self inside blocks
 * which goal is to reduce risk of retain cycles.
 *
 * Example:
 * @code
 
 @interface Example : NSObject{
 int _i;
 }
 @property (nonatomic,copy) void(^block)(void);
 @end
 
 @implementation Example
 -(void)someMethod{
 self.block = weakifySelf(^{
 // Self may be nil here
 [self doSomeWork];
 strongifyAndReturnIfNil(self);
 // Self is strong and not nil.
 // We can do ivars dereferencing
 // and other stuff safely
 self->_i = 42;
 });
 }
 @end
 
 * @endcode
 */

/**
 * Takes a block of any signature as an argument
 * and makes all references to self in it weak.
 */
#define weakifySelf(BLOCK...) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
rs_blockWithWeakifiedSelf(self, ^id(__typeof(self) __weak self) { \
return (BLOCK); \
}) \
_Pragma("clang diagnostic pop")

/**
 * Creates a strong reference to a variable
 * that will shadow the original
 */
#define strongify(VAR) \
id _strong_##VAR = VAR; \
__typeof(VAR) __strong VAR = _strong_##VAR;

/**
 * Creates a strong reference to a variable and returns if it is nil
 */
#define strongifyAndReturnIfNil(VAR) \
strongify(VAR) \
if (!(VAR)){ return;}



id rs_blockWithWeakifiedSelf(id self, id(^intermediateBlock)(id __weak self));