#import <UIKit/UITableViewHeaderFooterView.h>

@implementation UITableViewHeaderFooterView

#pragma mark Initializing the View

- (instancetype) initWithReuseIdentifier:(NSString*)reuseIdentifier
{
#warning implement -initWithReuseIdentifier:
    UIKIT_STUB_W_RETURN(@"-initWithReuseIdentifier:");
}

- (void) prepareForReuse
{
#warning implement -prepareForReuse
    UIKIT_STUB(@"-prepareForReuse");
}

# pragma mark UIApperance Protocol

+ (id) appearance
{
#warning implement -appearance
    UIKIT_STUB_W_RETURN(@"-appearance");
}

+ (id) appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ... NS_REQUIRES_NIL_TERMINATION
{
#warning implement -appearanceWhenContainedIn:
    UIKIT_STUB_W_RETURN(@"-appearanceWhenContainedIn:");
}

@end
