#import <Foundation/Foundation.h>

@class UIColor, UIImage;

@interface UIButtonContent : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) UIColor* shadowColor;
@property (strong, nonatomic) UIColor* titleColor;
@property (strong, nonatomic) UIImage* backgroundImage;
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSString* title;

@end
