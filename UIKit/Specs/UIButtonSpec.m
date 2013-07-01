#import <UIKit/UIKit.h>


SPEC_BEGIN(UIButtonSpec)
describe(@"UIButton", ^{

    context(@"default property", ^{
        UIButton* button = [[UIButton alloc] init];
        
        context(@"titleLabel", ^{
            it(@"should have 1 line", ^{
                [[@([[button titleLabel] numberOfLines]) should] equal:@(1)];
            });
            it(@"should be middle trucated", ^{
                [[@([[button titleLabel] lineBreakMode]) should] equal:@(UILineBreakModeMiddleTruncation)];
            });
        });
        
        context(@"reversesTitleShadowWhenHighlighted", ^{
            it(@"should be No", ^{
                [[@([button reversesTitleShadowWhenHighlighted]) should] beNo];
            });
        });

        context(@"adjustsImageWhenHighlighted", ^{
            it(@"should be Yes", ^{
                [[@([button adjustsImageWhenHighlighted]) should] beYes];
            });
        });
        
        context(@"adjustsImageWhenDisabled", ^{
            it(@"should be Yes", ^{
                [[@([button adjustsImageWhenDisabled]) should] beYes];
            });
        });
        
        context(@"showsTouchWhenHighlighted", ^{
            it(@"should be No", ^{
                [[@([button showsTouchWhenHighlighted]) should] beNo];
            });
        });
        
        context(@"tintColor", ^{
            it(@"should be Nil", ^{
                [[[button tintColor] should] beNil];
            });
        });
        
        context(@"insets", ^{
            context(@"contentEdge", ^{
                it(@"top should be 0", ^{
                    [[@(UIEdgeInsetsEqualToEdgeInsets([button contentEdgeInsets], UIEdgeInsetsZero)) should] beYes];
                });
            });
            context(@"titleEdge", ^{
                it(@"should be 0s", ^{
                    [[@(UIEdgeInsetsEqualToEdgeInsets([button titleEdgeInsets], UIEdgeInsetsZero)) should] beYes];
                });
            });
            context(@"imageEdge", ^{
                it(@"should be 0s", ^{
                    [[@(UIEdgeInsetsEqualToEdgeInsets([button imageEdgeInsets], UIEdgeInsetsZero)) should] beYes];
                });
            });
        });
        
        context(@"frame", ^{
            it(@"should be 0", ^{
                [[@(CGRectEqualToRect([button frame], CGRectZero)) should] beYes];
            });
        });
        
        context(@"buttonType", ^{
            it(@"should be custom", ^{
                [[@([button buttonType]) should] equal:@(UIButtonTypeCustom)];
            });
        });
        
        context(@"currentTitle", ^{
            it(@"should be blank", ^{
                [[[button currentTitle] should] beNil];
            });
        });
        
        context(@"currentAttributedTitle", ^{
            it(@"should be blank", ^{
                [[[button currentAttributedTitle] should] beNil];
            });
        });
        
        context(@"currentTitleColor", ^{
            it(@"should be white", ^{
                [[[button currentTitleColor] should] equal:[UIColor whiteColor]];
            });
        });

        context(@"currentTitleShadowColor", ^{
            it(@"should be white[sic]", ^{//Documentation claims default is white
                [[[button currentTitleShadowColor] should] equal:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
            });
        });

        context(@"currentImage", ^{
            it(@"should be blank", ^{
                [[[button currentImage] should] beNil];
            });
        });
        
        context(@"currentBackgroundImage", ^{
            it(@"should be blank", ^{
                [[[button currentBackgroundImage] should] beNil];
            });
        });
        
        context(@"imageView", ^{
            it(@"should contain no image", ^{
                [[[[button imageView] image] should] beNil];
            });
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