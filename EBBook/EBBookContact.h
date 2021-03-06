//
//  EBBookContact.h
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-14.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EBBookContact : NSObject
@property (strong, nonatomic) NSString* seat;
@property (strong, nonatomic) NSString* report;
@property (strong, nonatomic) NSString* reportNew;
@property (strong, nonatomic) NSString* gender;
@property (strong, nonatomic) NSString* birthdate;
@property (strong, nonatomic) NSString* office;
@property (strong, nonatomic) NSString* department;
@property (strong, nonatomic) NSString* center;
@property (strong, nonatomic) NSString* mobile;
@property (strong, nonatomic) NSString* vpmn;
@property (strong, nonatomic) NSString* tel;
@property (strong, nonatomic) NSString* mail;
@property (strong, nonatomic) NSString* band;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* uid;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* salaryId;
@property (strong, nonatomic) NSString* isFavorite;
@property BOOL hasRegisteredForChat;

- (BOOL)searchNameText:(NSString *)searchT;
@end
