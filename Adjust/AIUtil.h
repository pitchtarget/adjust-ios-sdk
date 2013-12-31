//
//  AIUtil.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adeven. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AIUtil : NSObject

+ (NSString *)baseUrl;
+ (NSString *)baseEndpoint;
+ (NSString *)clientSdk;
+ (NSString *)userAgent;
+ (NSDictionary *)deviceData;

+ (void)excludeFromBackup:(NSString *)filename;

@end
