//
//  EBSurfPopAccount.h
//  EBSurf
//
//  Created by Kissshot HeartunderBlade on 12-5-24.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface EBSurfPopAccount : NSObject
{
    struct mailstorage	*myStorage;
	BOOL				connected;
}

/*!
 @abstract	Retrieves a list of only the subscribed folders from the server.
 @result		Returns a NSSet which contains NSStrings of the folders pathnames.
 */
- (void)connectToServer:(NSString *)server port:(int)port connectionType:(int)conType authType:(int)authType 
                  login:(NSString *)login password:(NSString *)password;

/*!
 @abstract	This method returns the current connection status.
 @result		Returns YES or NO as the status of the connection.
 */
- (BOOL)isConnected;

/*!
 @abstract	Terminates the connection. If you terminate this connection it will also affect the
 connectivity of CTCoreFolders and CTMessages that rely on this account.
 */
- (void)disconnect;

/* Intended for advanced use only */
- (mailpop3 *)session;
- (struct mailstorage *)storageStruct;
//- (NSString *)getPassword;
@end
