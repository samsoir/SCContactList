//
//  SCContactPersonTests.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactPersonTests.h"
#import "SCContactRecord.h"
#import "SCContactPerson.h"

@implementation SCContactPersonTests

@synthesize records = _records;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    [self tearDown];
    
    int recordNumber                    = 5;
    NSMutableArray *addressBookRecords  = [NSMutableArray arrayWithCapacity:5];
    self.records                        = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i < recordNumber; i += 1)
    {
        NSString *firstName = [NSString stringWithFormat:@"Jane%i", i];
        NSString *lastName  = [NSString stringWithFormat:@"Smith%i", i];
        NSString *email     = [NSString stringWithFormat:@"jane.smith%i@test.com", i];
        NSString *phone     = [NSString stringWithFormat:@"+1773344724%i", i];
        
        id values[] = {
            firstName,
            lastName,
            email,
            phone
        };
        
        id keys[] = {
            @"firstName",
            @"lastName",
            @"email",
            @"phone"
        };
        
        int size = (sizeof(values) / sizeof(id));
        
        NSDictionary *contactDict = [NSDictionary dictionaryWithObjects:values
                                                                forKeys:keys
                                                                  count:size];
        
        [addressBookRecords addObject:contactDict];
    }
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    for (NSDictionary *contactDict in addressBookRecords)
    {
        NSLog(@"Creating contact: %@", contactDict);
        
        ABRecordRef record  = ABPersonCreate();
        
        CFErrorRef setABRecordValueError = NULL;
        ABRecordSetValue(record, kABPersonFirstNameProperty, [contactDict valueForKey:@"firstName"], &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        ABRecordSetValue(record, kABPersonLastNameProperty, [contactDict valueForKey:@"lastName"], &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        ABMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMultiValue, [contactDict valueForKey:@"email"], kABHomeLabel, NULL);
        ABRecordSetValue(record, kABPersonEmailProperty, emailMultiValue, &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        ABMultiValueRef phoneMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneMultiValue, [contactDict valueForKey:@"phone"], kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(record, kABPersonPhoneProperty, phoneMultiValue, &setABRecordValueError);
        
        if (setABRecordValueError != NULL)
        {
            STFail(@"There was a problem setting an address book value: %@", setABRecordValueError);
        }
        
        CFErrorRef recordError = NULL;
        ABAddressBookAddRecord(addressBook, record, &recordError);
        
        if (recordError != NULL)
        {
            STFail(@"There was a problem creating an address book record: %@", recordError);
        }

        if (ABAddressBookHasUnsavedChanges(addressBook))
        {
            CFErrorRef saveError = NULL;
            ABAddressBookSave(addressBook, &saveError);
            
            if (saveError != NULL)
            {
                STFail(@"There was a problem saving the address book record: %@", saveError);
            }
        }
        
        [self.records addObject:[NSNumber numberWithInt:ABRecordGetRecordID(record)]];
        
        CFRelease(record);
    }
        
    CFRelease(addressBook);
    
}

- (void)tearDown
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    // Tear-down code here.
    CFArrayRef recordsInserted = ABAddressBookCopyArrayOfAllPeople(addressBook);
    long recordsCount          = CFArrayGetCount(recordsInserted);
    int i                      = 0;
    
    for (i = 0; i < recordsCount; i += 1)
    {
        ABRecordRef eRecord = CFArrayGetValueAtIndex(recordsInserted, i);
        ABAddressBookRemoveRecord(addressBook, eRecord, NULL);
        
    }
    
    if (ABAddressBookSave(addressBook, NULL))
    {
        NSLog(@"Successfully removed %i contacts", i);
    }
    
    CFRelease(recordsInserted);
    self.records = nil;
    
    [super tearDown];
}

- (void)testInitContactPersonID
{
    STAssertNil([[SCContactPerson alloc] initWithContactPersonID:nil], @"Should be nil");

    NSNumber *contactID = [self.records objectAtIndex:0];
        
    SCContactPerson *person = [[[SCContactPerson alloc] initWithContactPersonID:contactID] autorelease];
    
    STAssertTrue([person isKindOfClass:[SCContactPerson class]], @"Person should be an instance of SCContactPerson");
    STAssertTrue([contactID isEqualToNumber:[person recordID]], @"Person record ID: %@ should be equal to: %@", [person recordID], contactID);
}

- (void)testIsSaved
{
    SCContactPerson *newPerson = [[[SCContactPerson alloc] init] autorelease];
    STAssertFalse([newPerson isSaved], @"New person should not be saved");
    
    NSNumber *contactID = [self.records objectAtIndex:0];
    
    SCContactPerson *existingPerson = [[[SCContactPerson alloc] initWithContactPersonID:contactID] autorelease];
    STAssertTrue([existingPerson isSaved], @"Existing person should be saved");
}



@end
