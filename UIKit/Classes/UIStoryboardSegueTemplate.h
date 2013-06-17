@class UIViewController;
@class UIStoryboardSegue;

@interface UIStoryboardSegueTemplate : NSObject <NSCoding> 

@property (readonly, strong, nonatomic) NSString* identifier;
@property (readonly, strong, nonatomic) NSString* destinationViewControllerIdentifier;
@property (assign, nonatomic) BOOL performOnViewLoad;
@property (assign, nonatomic) UIViewController* viewController;

- (Class) effectiveSegueClass;
- (UIStoryboardSegue*) segueWithDestinationViewController:(UIViewController*)destinationViewController;

@end