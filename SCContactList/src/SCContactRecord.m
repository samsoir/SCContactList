//
//  SCContactRecord.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactRecord.h"

@implementation SCContactRecord

@synthesize ABRecord = _ABRecord;

- (void)setABRecord:(ABRecordRef)record
{
    if (_ABRecord != record)
    {
        if (_ABRecord != NULL)
        {
            CFRelease(_ABRecord);
        }
        
        CFRetain(record);
        _ABRecord = record;
    }
}

- (NSNumber *)recordID
{
    NSNumber *recordID = nil;
    
    if (_ABRecord != NULL)
    {
        recordID = [NSNumber numberWithInt:ABRecordGetRecordID(_ABRecord)];
    }
    
    return recordID;
}


#pragma mark - SCContactRecord lifecycle methods

- (void)dealloc
{
    if (_ABRecord != NULL)
    {
        CFRelease(_ABRecord);
    }
    
    [super dealloc];
}

@end
