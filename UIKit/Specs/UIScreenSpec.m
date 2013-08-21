SPEC_BEGIN(UIScreenSpec)
describe(@"UIScreen", ^{
    context(@"default", ^{
        UIScreen* screen = [[UIScreen alloc] init];
        it(@"should exist", ^{
            [[screen should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[screen should] beKindOfClass:[UIScreen class]];
        });
        context(@"property", ^{

            context(@"mirroredScreen", ^{
                it(@"should not be", ^{
                    [[[screen mirroredScreen] should] beNil];
                });
            });
            context(@"bounds", ^{
                it(@"should be 0", ^{
                    [[@(CGRectEqualToRect([screen bounds], CGRectZero)) should] beYes];
                });
            });
            context(@"applicationFrame", ^{
                it(@"should be 0", ^{
                    [[@(CGRectEqualToRect([screen applicationFrame], CGRectZero)) should] beYes];
                });
            });
            context(@"scale", ^{
                it(@"should be 0", ^{
                    [[@([screen scale]) should] equal:@(0)];
                });
            });
            context(@"preferredMode", ^{
                it(@"should not be", ^{
                    [[[screen preferredMode] should] beNil];
                });
            });
            context(@"availableModes", ^{
                it(@"should be empty", ^{
                    [[@([[screen availableModes] count])should] equal:@(0)];
                });
            });
            context(@"currentMode", ^{
                it(@"should not be", ^{
                    [[[screen currentMode] should] beNil];
                });
            });
            context(@"brightness", ^{
                it(@"should be -1", ^{
                    [[@([screen brightness]) should] equal:@(-1)];
                });
            });
            context(@"wantsSoftwareDimming", ^{
                it(@"should be no", ^{
                    [[@([screen wantsSoftwareDimming]) should] beNo];
                });
            });
            context(@"overscanCompensation", ^{
                it(@"should be scale", ^{
                    [[@([screen overscanCompensation]) should] equal:@(UIScreenOverscanCompensationScale)];
                });
            });
        });
    });
});
SPEC_END