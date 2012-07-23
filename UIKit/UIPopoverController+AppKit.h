#import "UIPopoverController.h"

typedef enum {
    UIPopoverThemeDefault,
    UIPopoverThemeLion
} UIPopoverTheme;

@interface UIPopoverController (AppKitIntegration)

@property (assign, nonatomic) UIPopoverTheme theme;

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated makeKey:(BOOL)shouldMakeKey;

@end