#import "UITableViewCellUnhighlightedState.h"
#import "UIColor.h"

@implementation UITableViewCellUnhighlightedState
@synthesize backgroundColor = _backgroundColor;
@synthesize highlighted = _highlighted;
@synthesize opaque = _opaque;

- (void) dealloc
{
    [_backgroundColor release];
    [super dealloc];
}

@end
