#import <Foundation/Foundation.h>

extern int UIApplicationMain(int argc, char *argv[], NSString *principalClassName, NSString *delegateClassName);

int main(int argc, char *argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, nil);
    }
}
