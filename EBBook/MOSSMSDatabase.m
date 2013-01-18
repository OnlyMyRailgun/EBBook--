//
//  MOSSMSDatabase.m
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-27.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "MOSSMSDatabase.h"
#import "MOSTools.h"

@implementation MOSSMSDatabase
@synthesize databasePath,db;

- (id)init
{
    if(self = [super init])
    {
        //        if(![MOSTools isFileExistInDocument:@"MOSEnterpriseDB.db"])
        //            [self removeOldDB];
        databasePath = [MOSTools getFilePathInDocument:@"Smsdb.db"];
    }
    return self;
}

- (void)openDB
{
    db = [FMDatabase databaseWithPath:databasePath];
    if (![db open]) {
        NSLog(@"Could not open db. %@",[databasePath lastPathComponent]);
        [db release];
        return ;
    }
    else {
        NSLog(@"Open db Success %@",[databasePath lastPathComponent]);
    }
}

- (void)closeDB
{
    NSLog(@"close db");
    [db close];
}

- (BOOL)createSMSTable
{
    return [db executeUpdate:@"CREATE TABLE sms(phoneNumber text,content text,date text,sendFlag int,isFromMe int,contactName text)"];
}

- (NSArray *)querySMSFromTableForKey:(NSString *)phoneNumber{
    //[self setupOrganizationStructure];
    NSMutableArray *arrayFromTable = [NSMutableArray array];
    FMResultSet *rs;

    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM sms WHERE phoneNumber = ? ORDER BY date"];
    rs=[db executeQuery:sql, phoneNumber];
    while ([rs next]){
        MOSSMSObject *sms = [[MOSSMSObject alloc] init];
        sms.phoneNumber = [rs stringForColumn:@"phoneNumber"];
        sms.content = [rs stringForColumn:@"content"];
        sms.date = [rs doubleForColumn:@"date"];
        sms.sendSuccess = [[rs stringForColumn:@"sendFlag"] intValue];
        sms.isFromMe = [[rs stringForColumn:@"isFromMe"] boolValue];
        sms.contactName = [rs stringForColumn:@"contactName"];
        [arrayFromTable addObject:sms];
        [sms release];
    }
    [rs close];
    
    return  arrayFromTable;

}

- (NSArray *)queryLastSMSFromTable{
    NSMutableArray *arrayFromTable = [NSMutableArray array];
    FMResultSet *rs;

    rs=[db executeQuery:@"SELECT * FROM sms GROUP BY phoneNumber  order by max(date) desc"];
    while ([rs next]){
        MOSSMSObject *sms = [[MOSSMSObject alloc] init];
        sms.phoneNumber = [rs stringForColumn:@"phoneNumber"];
        sms.content = [rs stringForColumn:@"content"];
        sms.date = [[rs stringForColumn:@"date"] doubleValue];
        sms.sendSuccess = [[rs stringForColumn:@"sendFlag"] intValue];
        sms.isFromMe = [[rs stringForColumn:@"isFromMe"] boolValue];
        sms.contactName = [rs stringForColumn:@"contactName"];
        [arrayFromTable addObject:sms];
        
        [sms release];
    }
    [rs close];
    
    return  arrayFromTable;
}

- (BOOL)insertMessageIntoTable:(MOSSMSObject *)message
{
    BOOL result = NO;
    MOSSMSObject *locateSMS = message;
    result = [db executeUpdate:@"INSERT INTO sms(phoneNumber, content, date, sendFlag, isFromMe, contactName) VALUES (?,?,?,?,?,?)", locateSMS.phoneNumber,locateSMS.content, [NSString stringWithFormat:@"%f",locateSMS.date], [NSString stringWithFormat:@"%d",locateSMS.sendSuccess], [NSString stringWithFormat:@"%d",locateSMS.isFromMe], locateSMS.contactName];

    return result;
}

- (BOOL)insertMsgsFromArray:(NSArray *)msgArray
{
    [self openDB];
    [db beginTransaction];
    @try {
        for (MOSSMSObject *msgObject in msgArray) {
            [self insertMessageIntoTable:msgObject];
        }
    }
    @catch (NSException *exception) {
        [db rollback];
    }
    @finally {
        [db commit];
    }
    [self closeDB];
}
/*
- (BOOL)insertMoserIntoTable:(MOSSMSObject *)message
{
    BOOL result = NO;
    MOSSMSObject *locateSMS = message;
    
    result = [db executeUpdate:@"INSERT INTO sms(phoneNumber, content, date, sendFlag) VALUES (?,?,?,?)", [locateSMS phoneNumber],[locateSMS content], [locateSMS date],[locateSMS sendSuccess]];
    
    return result;
}
*/
@end
