SPEC_BEGIN(UIImageSpec)

describe(@"UIImage", ^{
    context(@"+imageNamed", ^{
        beforeAll(^{
            [NSBundle pushMainBundle:[NSBundle bundleForClass:[UIImageSpec class]]];
        });
        
        afterAll(^{
            [NSBundle popMainBundle];
        });
        
        it(@"should be nil when passed a nil name", ^{
            UIImage* image = [UIImage imageNamed:nil];
            [image shouldBeNil];
        });
        
        it(@"should not automatically replace underscores with hyphens", ^{
            UIImage* image = [UIImage imageNamed:@"image_with_dashes"];
            [image shouldBeNil];
        });

        it(@"should not automatically replace hyphens with underscores", ^{
            UIImage* image = [UIImage imageNamed:@"image-with-underscores"];
            [image shouldBeNil];
        });

        it(@"should find .PNG files, even without their extensions", ^{
            UIImage* image = [UIImage imageNamed:@"white-noalpha-100x100"];
            [image shouldNotBeNil];
        });

        if ([[UIScreen mainScreen] scale] == 2.0) context(@"on a retina device", ^{
            it(@"should load @2x variants", ^{
                UIImage* image = [UIImage imageNamed:@"white-noalpha-100x100"];
                [[theValue([image scale]) should] equal:theValue(2.0)];
            });
        });
    });

    
    context(@"-imageWithContentsOfFile:", ^{
        it(@"should be nil when passed a nil path", ^{
            UIImage* image = [UIImage imageWithContentsOfFile:nil];
            [image shouldBeNil];
        });
        
        if ([[UIScreen mainScreen] scale] == 2.0) context(@"on a retina device", ^{
            it(@"should not load @2x variants", ^{
                NSString* file = [[NSBundle bundleForClass:self] pathForResource:@"white-noalpha-100x100" ofType:@"png"];
                if (file) {
                    UIImage* image = [UIImage imageWithContentsOfFile:file];
                    [image shouldNotBeNil];
                    [[theValue([image scale]) should] equal:theValue(2.0)];
                }
            });
        });
    });

    
    context(@"-initWithContentsOfFile:", ^{
        it(@"should be nil when passed a nil path", ^{
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:nil];
            [image shouldBeNil];
        });
    });
});

SPEC_END