//
//  EBBookContact.m
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-14.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookContact.h"

@implementation EBBookContact
@synthesize seat, report, reportNew, gender, birthdate, office, department, center, mobile, vpmn, tel,  mail, band, title, uid, name, salaryId, isFavorite;
- (BOOL)searchNameText:(NSString *)searchT{
	NSComparisonResult result = [name compare:searchT options:NSCaseInsensitiveSearch
											   range:NSMakeRange(0, searchT.length)];
	if (result == NSOrderedSame)
		return YES;
	else
		return NO;
}
@end
