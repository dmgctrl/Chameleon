#import "UIStoryboardSegueTemplate.h"
#import "UIViewController.h"

@interface UIStoryboardModalSegueTemplate : UIStoryboardSegueTemplate

@property (nonatomic, assign) BOOL animates;
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;
@property (nonatomic, assign) UIModalTransitionStyle modalTransitionStyle;
@property (nonatomic, assign) BOOL useDefaultModalPresentationStyle;
@property (nonatomic, assign) BOOL useDefaultModalTransitionStyle;

@end
