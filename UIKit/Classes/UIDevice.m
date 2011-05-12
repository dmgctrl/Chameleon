/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIDevice.h"
#import <IOKit/IOKitLib.h>
#import <SystemConfiguration/SystemConfiguration.h>

NSString *const UIDeviceOrientationDidChangeNotification = @"UIDeviceOrientationDidChangeNotification";

static UIDevice *theDevice;

@implementation UIDevice

+ (void)initialize
{
    if (self == [UIDevice class]) {
        theDevice = [[UIDevice alloc] init];
    }
}

+ (UIDevice *)currentDevice
{
    return theDevice;
}

- (UIUserInterfaceIdiom)userInterfaceIdiom
{
    return UIUserInterfaceIdiomDesktop;
}

- (NSString *)name
{
    return [NSMakeCollectable(SCDynamicStoreCopyComputerName(NULL,NULL)) autorelease];
}

- (UIDeviceOrientation)orientation
{
    return UIDeviceOrientationPortrait;
}

- (BOOL)isMultitaskingSupported
{
    return YES;
}

- (NSString *)systemName
{
    return [[NSProcessInfo processInfo] operatingSystemName];
}

- (NSString *)systemVersion
{
    return [[NSProcessInfo processInfo] operatingSystemVersionString];
}

- (NSString *)model
{
    return @"Mac";
}

- (NSString *)uniqueIdentifier
{
    NSString *aUniqueIdentifier = nil;

    io_service_t platformExpertDevice =
        IOServiceGetMatchingService(kIOMasterPortDefault,
                                    IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpertDevice)
    {
        CFTypeRef platformUUIDTypeRef =
            IORegistryEntryCreateCFProperty(platformExpertDevice,
                                            CFSTR(kIOPlatformUUIDKey),
                                            kCFAllocatorDefault,
                                            0);
        if (platformUUIDTypeRef)
        {
            CFTypeID typeID = CFGetTypeID(platformUUIDTypeRef);
            if (typeID == CFStringGetTypeID())
            {
                aUniqueIdentifier = [NSString stringWithString:(NSString *)platformUUIDTypeRef];
            }
            CFRelease(platformUUIDTypeRef);
        }

        IOObjectRelease(platformExpertDevice);
    }

    return aUniqueIdentifier;
}

- (BOOL)isGeneratingDeviceOrientationNotifications
{
    return NO;
}

- (void)beginGeneratingDeviceOrientationNotifications
{
}

- (void)endGeneratingDeviceOrientationNotifications
{
}

@end
