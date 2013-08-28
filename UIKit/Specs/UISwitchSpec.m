SPEC_BEGIN(UISwitchSpec)
describe(@"UISwitch", ^{
    context(@"default", ^{
        UISwitch* aSwitch = [[UISwitch alloc] init];
        it(@"should exist", ^{
            [[aSwitch should] beNonNil];
        });
        it(@"should be member of right class", ^{
            [[aSwitch should] beKindOfClass:[UISwitch class]];
        });

        context(@"property", ^{
            context(@"isOn", ^{
                it(@"should be no", ^{
                    [[@([aSwitch isOn]) should] beNo];
                });
            });
            context(@"isOn", ^{
                it(@"should be no", ^{
                    [[@([aSwitch isOn]) should] beNo];
                });
            });
            context(@"onTintColor", ^{
                it(@"should be", ^{
                    [[[aSwitch onTintColor] should] beNonNil];
                });
            });
            context(@"tintColor", ^{
                it(@"should not be", ^{
                    [[[aSwitch tintColor] should] beNil];
                });
            });
            context(@"thumbTintColor", ^{
                it(@"should not be", ^{
                    [[[aSwitch thumbTintColor] should] beNil];
                });
            });
            context(@"onImage", ^{
                it(@"should not be", ^{
                    [[[aSwitch onImage] should] beNil];
                });
            });
            context(@"offImage", ^{
                it(@"should not be", ^{
                    [[[aSwitch offImage] should] beNil];
                });
            });
        });
    });
});
SPEC_END