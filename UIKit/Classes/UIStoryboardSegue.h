@class UIViewController;

@interface UIStoryboardSegue : NSObject

@property (readonly, assign, nonatomic) id destinationViewController;
@property (readonly, assign, nonatomic) NSString* identifier;
@property (readonly, assign, nonatomic) id sourceViewController;

- (instancetype) initWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination;

- (void) perform;

@end