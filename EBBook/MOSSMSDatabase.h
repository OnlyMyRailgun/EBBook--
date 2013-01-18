//
//  MOSSMSDatabase.h
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-27.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MOSSMSObject.h"

@interface MOSSMSDatabase : NSObject
@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) FMDatabase *db;

- (NSArray *)queryLastSMSFromTable;
- (NSArray *)querySMSFromTableForKey:(NSString *)phoneNumber;
- (BOOL)insertMessageIntoTable:(MOSSMSObject *)message;
- (BOOL)insertMsgsFromArray:(NSArray *)msgArray;

- (void)openDB;
- (void)closeDB;
- (BOOL)createSMSTable;
@end
