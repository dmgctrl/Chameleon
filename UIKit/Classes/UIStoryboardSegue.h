@class UIViewController;

@interface UIStoryboardSegue : NSObject

#pragma mark Initializing a Storyboard Segue

- (instancetype) initWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination;


#pragma mark Accessing the Segue Attributes

@property (readonly, assign, nonatomic) id sourceViewController;
@property (readonly, assign, nonatomic) id destinationViewController;
@property (readonly, assign, nonatomic) NSString* identifier;


#pragma mark Performing the Segue

- (void) perform;


#pragma mark Creating a Custom Segue

+ (instancetype) segueWithIdentifier:(NSString*)identifier source:(UIViewController*)source destination:(UIViewController*)destination performHandler:(void (^)(void))performHandler;


@end