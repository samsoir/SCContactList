//
//  SCContactList.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/18/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactList.h"

@implementation SCContactList

@synthesize contactRecords = _contactRecords;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        if ( ! [self initializeContactsDatabase])
        {
            return nil;
        }
    }
    
    return self;
}

- (BOOL)initializeContactsDatabase
{
    BOOL result = NO;
    
    // Initialize the contacts database
    NSMutableArray *contactRecords     = [NSMutableArray arrayWithCapacity:50];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (addressBook != NULL)
    {
        CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
        int recordCount    = CFArrayGetCount(records);
        int i              = 0;
        
        for (i = 0; i < recordCount; i += 1)
        {
            NSMutableSet *recordSet = [NSMutableSet setWithCapacity:10];
            ABRecordRef record      = CFArrayGetValueAtIndex(records, i);
            
            [recordSet addObject:(id)record];
            
            NSArray *linkedRecords  = (NSArray *)ABPersonCopyArrayOfAllLinkedPeople(record);
            [recordSet addObjectsFromArray:linkedRecords];
            
            [linkedRecords release];
            
            [contactRecords addObject:recordSet];
        }
        
        CFRelease(records);
        CFRelease(addressBook);
        
        self.contactRecords = contactRecords;
        
        result = YES;
    }
    
    return result;
}

- (void)dealloc
{
    [_contactRecords release];
    
    [super dealloc];
}

@end
