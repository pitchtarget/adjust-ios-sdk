//
//  AIUtil.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIUtil.h"
#import "AILogger.h"
#import "UIDevice+AIAdditions.h"
#import "AIAdjustFactory.h"

#include <sys/xattr.h>

static NSString * const kBaseUrl   = @"https://addictive-inventory.herokuapp.com";
static NSString * const kClientSdk = @"ios3.0.0";
static NSString * const kBaseEndpoint = @"/tracking";


#pragma mark -
@implementation AIUtil

+ (NSString *)baseUrl {
    return kBaseUrl;
}

+ (NSString *)baseEndpoint {
    return kBaseEndpoint;
}

+ (NSString *)clientSdk {
    return kClientSdk;
}

+ (NSString *)userAgent {
    NSDictionary *data = [self.class deviceData];

    NSString *userAgent = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@",
                           [data objectForKey:@"bundle_identifier"],
                           [data objectForKey:@"bundle_version"],
                           [data objectForKey:@"device_type"],
                           [data objectForKey:@"device_name"],
                           [data objectForKey:@"os_name"],
                           [data objectForKey:@"system_version"],
                           [data objectForKey:@"language_code"],
                           [data objectForKey:@"country_code"]];

    return userAgent;
}

+ (NSDictionary *)deviceData {
    UIDevice *device = UIDevice.currentDevice;
    NSLocale *locale = NSLocale.currentLocale;
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;
    
    NSString *bundleIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    NSString *bundleVersion    = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *languageCode     = [locale objectForKey:NSLocaleLanguageCode];
    NSString *countryCode      = [locale objectForKey:NSLocaleCountryCode];
    NSString *osName           = @"ios";

    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [self.class sanitizeU:bundleIdentifier],     @"bundle_identifier",
                          [self.class sanitizeU:bundleVersion],        @"bundle_version",
                          [self.class sanitizeU:device.aiDeviceType],  @"device_type",
                          [self.class sanitizeU:device.aiDeviceName],  @"device_name",
                          [self.class sanitizeU:osName],               @"os_name",
                          [self.class sanitizeU:device.systemVersion], @"system_version",
                          [self.class sanitizeZ:languageCode],         @"language_code",
                          [self.class sanitizeZ:countryCode],          @"country_code",
                          nil];
    return data;
}

#pragma mark - sanitization
+ (NSString *)sanitizeU:(NSString *)string {
    return [self.class sanitize:string defaultString:@"unknown"];
}

+ (NSString *)sanitizeZ:(NSString *)string {
    return [self.class sanitize:string defaultString:@"zz"];
}

+ (NSString *)sanitize:(NSString *)string defaultString:(NSString *)defaultString {
    if (string == nil) {
        return defaultString;
    }

    NSString *result = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (result.length == 0) {
        return defaultString;
    }

    return result;
}

// inspired by https://gist.github.com/kevinbarrett/2002382
+ (void)excludeFromBackup:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    id<AILogger> logger = AIAdjustFactory.logger;

    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS 5.0.1 and lower
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result != 0) {
            [logger debug:@"Failed to exclude '%@' from backup", url.lastPathComponent];
        }
    } else { // iOS 5.0 and higher
        // First try and remove the extended attribute if it is present
        int result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                [logger debug:@"Removed extended attribute on file '%@'", url];
            }
        }

        // Set the new key
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES]
                                      forKey:NSURLIsExcludedFromBackupKey
                                       error:&error];
        if (!success) {
            [logger debug:@"Failed to exclude '%@' from backup (%@)", url.lastPathComponent, error.localizedDescription];
        }
    }
}

@end
