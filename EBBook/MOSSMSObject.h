//
//  MOSSMSObject.h
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-27.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOSSMSObject : NSObject

@property (strong, nonatomic) NSString* phoneNumber;
@property (strong, nonatomic) NSString* content;
@property (nonatomic)NSTimeInterval date;
@property (nonatomic) int sendSuccess;
@property BOOL isFromMe;
@property (nonatomic, retain) NSString *contactName;
@end
