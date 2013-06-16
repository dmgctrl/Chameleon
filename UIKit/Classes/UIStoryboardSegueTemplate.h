@class UIViewController;

@interface UIStoryboardSegueTemplate : NSObject <NSCoding> 

@property (readonly, assign, nonatomic) NSString* identifier;
@property (assign, nonatomic) BOOL performOnViewLoad;
@property (assign, nonatomic) UIViewController* viewController;

- (id) defaultSegueClassName;
- (Class) effectiveSegueClass;
- (void) perform:(id)perform;
- (id) segueWithDestinationViewController:(UIViewController*)destinationViewController;

@end