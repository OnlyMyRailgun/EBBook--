//
//  EBSurfPopAccount.m
//  EBSurf
//
//  Created by Kissshot HeartunderBlade on 12-5-24.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBSurfPopAccount.h"
#import "MailCoreTypes.h"
#include <sys/stat.h>

@implementation EBSurfPopAccount

- (id)init {
	self = [super init];
	if (self) {
		connected = NO;
		myStorage = mailstorage_new(NULL);
		assert(myStorage != NULL);
	}
	return self;
}


- (void)dealloc {
	mailstorage_disconnect(myStorage);
	mailstorage_free(myStorage);
	[super dealloc]; 
}


- (BOOL)isConnected {
	return connected;
}

void check_error(int r, char * msg)
{
	if (r == MAILPOP3_NO_ERROR)
		return;
    
	fprintf(stderr, "%s\n", msg);
	exit(EXIT_FAILURE);
}

//TODO, should I use the cache?
- (void)connectToServer:(NSString *)server port:(int)port 
         connectionType:(int)conType authType:(int)authType
                  login:(NSString *)login password:(NSString *)password {
	int err = 0;
	int pop3_cached = 0;
    
	const char* auth_type_to_pass = NULL;
	if(authType == POP3_AUTH_TYPE_SASL_CRAM_MD5) {
		auth_type_to_pass = "CRAM-MD5";
	}
	
	err = pop3_mailstorage_init_sasl(myStorage,
									 (char *)[server cStringUsingEncoding:NSUTF8StringEncoding],
									 (uint16_t)port, NULL,
									 conType,
									 auth_type_to_pass,
									 NULL,
									 NULL, NULL,
									 (char *)[login cStringUsingEncoding:NSUTF8StringEncoding], (char *)[login cStringUsingEncoding:NSUTF8StringEncoding],
									 (char *)[password cStringUsingEncoding:NSUTF8StringEncoding], NULL,
									 pop3_cached, NULL, NULL);
	if (err != MAIL_NO_ERROR) {
		NSException *exception = [NSException
                                  exceptionWithName:CTMemoryError
                                  reason:CTMemoryErrorDesc
                                  userInfo:nil];
		[exception raise];
	}
    
	err = mailstorage_connect(myStorage);
	if (err == MAIL_ERROR_LOGIN) {
		NSException *exception = [NSException
                                  exceptionWithName:CTLoginError
                                  reason:CTLoginErrorDesc
                                  userInfo:nil];
		[exception raise];
	}
	else if (err != MAIL_NO_ERROR) {
		NSException *exception = [NSException
                                  exceptionWithName:CTUnknownError
                                  reason:[NSString stringWithFormat:@"Error number: %d",err]
                                  userInfo:nil];
		[exception raise];
	}
	else	
		connected = YES;
}


- (void)disconnect {
	connected = NO;
	mailstorage_disconnect(myStorage);
}

- (mailpop3 *)session {
	struct pop3_cached_session_state_data * cached_data;
	struct pop3_session_state_data * data;
	mailsession *session;
    
	session = myStorage->sto_session;
	if(session == nil) {
        NSLog(@"storage is nil");
		return nil;
	}
	if (strcasecmp(session->sess_driver->sess_name, "pop3-cached") == 0) {
    	cached_data = session->sess_data;
    	session = cached_data->pop3_ancestor;
  	}
    
	data = session->sess_data;
	return data->pop3_session;
}


- (struct mailstorage *)storageStruct {
	return myStorage;
}

- (NSDate *)NSStringDateToNSDate:(NSString *)string { 
    NSString *onlyDate = [string substringToIndex:[string length] - 9];
    NSLog(@"%@",onlyDate);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    [formatter setDateFormat:@"'Date:' EEE, d MMM yyyy "];
    
    NSDate *date = [formatter dateFromString:onlyDate];
    [formatter release];
    return date;
}

//- (NSString *)getPassword {
//    NSString *vpnPassword = nil;
//	carray *allList = nil;
//    
//	int err;
//    int i;
//    
//	//Now, fill the all folders array
//	//TODO Fix this so it doesn't use *
//	err = mailpop3_list([self session], &allList);
//	if (err != MAIL_NO_ERROR)
//	{
//        NSException *exception = [NSException
//                                  exceptionWithName:CTUnknownError
//                                  reason:[NSString stringWithFormat:@"Error number: %d",err]
//                                  userInfo:nil];
//		[exception raise];
//    }
//	else if (carray_count(allList) == 0)
//	{
//		NSException *exception = [NSException
//                                  exceptionWithName:CTNoFolders
//                                  reason:CTNoFoldersDesc
//                                  userInfo:nil];
//		[exception raise];
//	}
//    else
//    {
//        if(allList == nil)
//            NSLog(@"allList is nil");
//        for(i = carray_count(allList); i > 0 ; i--) {
//            struct mailpop3_msg_info * info;
//            char * msg_header;
//            size_t header_size;
//            char * msg_content;
//            size_t content_size;
//            
//            info = carray_get(allList, i-1);
//            
//            if (info->msg_uidl == NULL) {
//                continue;
//            }
//            
//            if (err == 0) {
//                printf("already fetched %u %s\n", info->msg_index, info->msg_uidl);
//                //continue;
//            }
//            err = mailpop3_header([self session], info->msg_index, &msg_header, &header_size);
//            
//            NSString *header = [[NSString alloc] initWithCString:msg_header encoding:NSASCIIStringEncoding];
//            
//            mailpop3_header_free(msg_header);
//            
//            NSRange rangeOfDateStart = [header rangeOfString:@"Date: "];
//            NSRange rangeOfDateEnd = [header rangeOfString:@"+0800" options:NSCaseInsensitiveSearch range:NSMakeRange(rangeOfDateStart.location,40)];
//            if(rangeOfDateStart.length > 0 && rangeOfDateEnd.length >0)
//            {
//                int dateLocation = rangeOfDateStart.location;
//                int dateEndLocation = rangeOfDateEnd.location;
//                NSString *date = [header substringWithRange:NSMakeRange(dateLocation, dateEndLocation-dateLocation)];
//                int day = [[NSDate date] timeIntervalSinceDate:[self NSStringDateToNSDate:date]]/60/60/24;
//                NSLog(@"has gone by %d days",day);
//                if(day > 21)
//                    break;
//            }
//            
//            if([header rangeOfString:@"VPN"].length>0 && [header rangeOfString:@"PASSWORD"].length>0)
//            {
//                err = mailpop3_retr([self session], info->msg_index, &msg_content, &content_size);
//                
//                NSString *content = [[NSString alloc] initWithCString:msg_content encoding:NSASCIIStringEncoding];
//                
//                //NSLog(@"%@",content);
//                
//                int start = 0;
//                NSString *token = @"PASSWORD for this week: ";
//                
//                if([content rangeOfString:@"Your password: "].length > 0)
//                {
//                    start = [content rangeOfString:@"Your password: "].location + 15;
//                    
//                }
//                else if([content rangeOfString:token].length > 0)
//                {
//                    
//                    start = [content rangeOfString:token].location + token.length;
//                }
//                if(start != 0)
//                    vpnPassword = [content substringWithRange:NSMakeRange(start, 8)];
//                
//                mailpop3_retr_free(msg_content);
//                [content release];
//                break;
//            }
//            
//            [header release];
//        }	
//    }
//    return vpnPassword;
//}
@end
