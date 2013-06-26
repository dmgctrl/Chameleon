#import <UIKit/UIKit.h>


SPEC_BEGIN(UIButtonSpec)
describe(@"UIButton", ^{

    context(@"with the default constructor", ^{
        UIButton* button = [[UIButton alloc] init];
        it(@"should have one line", ^{
            [[@([[button titleLabel] numberOfLines]) should] equal:@(1)];
        });
        it(@"should have middle trucation as linebreak mode", ^{
            [[@([[button titleLabel] lineBreakMode]) should] equal:@(UILineBreakModeMiddleTruncation)];
        });
        it(@"has the proper frame", ^{
            [[NSStringFromCGRect([button frame]) should] equal:NSStringFromCGRect(CGRectMake(0, 0, 0, 0))];
        });
    });

    context(@"with a plain text title", ^{
        NSString* text = @"The quick brown fox\n jumped over the lazy \ndog.";
        __block UIButton* button;

        beforeEach(^{
            button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitle:text forState:UIControlStateNormal];
        });
        
        context(@"with default dimensions", ^{
            it(@"has the proper size", ^{
                [[NSStringFromCGSize([button bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(0, 0))];
            });
            context(@"the titleLabel", ^{
                it(@"is correct", ^{
                    [[NSStringFromCGSize([[button titleLabel] bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(0, 19))];
                });
            });
        });

        context(@"with a tiny height", ^{
            beforeEach(^{
                [button setFrame:(CGRect){0,0,40,3}];
            });
            context(@"the titleLabel", ^{
                it(@"shouldn't be vertically clipped", ^{
                    [[NSStringFromCGSize([[button titleLabel] bounds].size) should] equal:NSStringFromCGSize(CGSizeMake(38, 19))];
                });
            });
        });
    });
});

SPEC_END