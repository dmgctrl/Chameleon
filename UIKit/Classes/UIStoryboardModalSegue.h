#import "UIStoryboardSegue.h"
#import "UIViewController.h"

UIKIT_HIDDEN
@interface UIStoryboardModalSegue : UIStoryboardSegue

@property (nonatomic, assign) BOOL animates;
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;
@property (nonatomic, assign) UIModalTransitionStyle modalTransitionStyle;
@property (nonatomic, assign) BOOL useDefaultModalPresentationStyle;
@property (nonatomic, assign) BOOL useDefaultModalTransitionStyle;

- (void) perform;

@end