//
//  SCContactPersonTests.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactPersonTests.h"
#import "SCContactList.h"

@implementation SCContactPersonTests

@synthesize records = _records;

- (NSArray *)fixtureData
{
    NSArray *contactData = [NSArray arrayWithObjects:
        @"Jane",
        @"Doe",
        @"Jenny",
        @"Mrs",
        @"Snr",
        @"Janey",
        @"Jayne",
        @"Doh",
        @"Gen-knee",
        @"Acme",
        @"Iron",
        @"Bell",
        @"This is a note",
        [NSDate date],
        nil];
    
    return contactData;
}

- (NSDictionary *)fixtureHomeAddress
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"4800 N Kenmore Ave", kABPersonAddressStreetKey,
            @"Chicago", kABPersonAddressCityKey,
            @"Illinois", kABPersonAddressStateKey,
            @"60640", kABPersonAddressZIPKey,
            @"United States", kABPersonAddressCountryKey,
            @"us", kABPersonAddressCountryCodeKey, nil];
}

- (NSDictionary *)fixtureWorkAddress
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"15 Kimberely Avenue", kABPersonAddressStreetKey,
            @"London", kABPersonAddressCityKey,
            @"United Kingdom", kABPersonAddressCountryKey,
            @"SE15 4YZ", kABPersonAddressZIPKey,
            @"uk", kABPersonAddressCountryCodeKey, nil];
}

- (NSString *)fixtureHomeEmail
{
    return @"home@test.com";
}

- (NSString *)fixtureWorkEmail
{
    return @"work@test.com";
}

- (NSString *)fixtureMainPhone
{
    return @"+17733556677";
}

- (NSString *)fixtureIPhone
{
    return @"+17733445566";
}

- (NSString *)fixtureWorkPhone
{
    return @"+441206337343";
}

- (ABRecordRef)createTestAddressBookRecord
{
    ABRecordRef subjectRecord = ABPersonCreate();
    
    // Create a couple of addresses
    NSDictionary *addressHome = [self fixtureHomeAddress];
    NSDictionary *addressWork = [self fixtureWorkAddress];
    
    ABMutableMultiValueRef addressValue = ABMultiValueCreateMutable(kABPersonAddressProperty);
    
    ABMultiValueInsertValueAndLabelAtIndex(addressValue, addressHome, kABHomeLabel, 0, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(addressValue, addressWork, kABWorkLabel, 1, NULL);
    
    CFErrorRef addressSetError = NULL;
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonAddressProperty, addressValue, &addressSetError))
    {
        STFail(@"Unable to set Address value with error: %@", addressSetError);
    }
    
    // Create a couple of email addresses
    NSString *emailHome = [self fixtureHomeEmail];
    NSString *emailWork = [self fixtureWorkEmail];
    
    ABMutableMultiValueRef emailValue = ABMultiValueCreateMutable(kABPersonEmailProperty);
    
    ABMultiValueInsertValueAndLabelAtIndex(emailValue, emailHome, kABHomeLabel, 0, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(emailValue, emailWork, kABWorkLabel, 1, NULL);
    
    CFErrorRef emailSetError = NULL;
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonEmailProperty, emailValue, &emailSetError))
    {
        STFail(@"Unable to set email address value with error: %@", emailSetError);
    }
    
    // Create a couple of phone numbers
    NSString *phoneMain = [self fixtureMainPhone];
    NSString *iphone    = [self fixtureIPhone];
    NSString *phoneWork = [self fixtureWorkPhone];
    
    ABMutableMultiValueRef phoneValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    
    ABMultiValueInsertValueAndLabelAtIndex(phoneValue, phoneMain, kABPersonPhoneMainLabel, 0, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(phoneValue, iphone, kABPersonPhoneIPhoneLabel, 1, NULL);
    ABMultiValueInsertValueAndLabelAtIndex(phoneValue, phoneWork, kABWorkLabel, 2, NULL);
    
    CFErrorRef phoneSetError = NULL;
    
    if ( ! ABRecordSetValue(subjectRecord, kABPersonPhoneProperty, phoneValue, &phoneSetError))
    {
        STFail(@"Unable to set phone value with error: %@", phoneSetError);
    }
    
    ABPropertyID personalProperties[] = {
        kABPersonFirstNameProperty,
        kABPersonLastNameProperty,
        kABPersonMiddleNameProperty,
        kABPersonPrefixProperty,
        kABPersonSuffixProperty,
        kABPersonNicknameProperty,
        kABPersonFirstNamePhoneticProperty,
        kABPersonLastNamePhoneticProperty,
        kABPersonMiddleNamePhoneticProperty,
        kABPersonOrganizationProperty,
        kABPersonJobTitleProperty,
        kABPersonDepartmentProperty,
        kABPersonNoteProperty,
        kABPersonBirthdayProperty
    };
    
    NSArray *propertyValues = [self fixtureData];
    
    int counter = (sizeof(personalProperties) / sizeof(ABPropertyID));
    
    for (int i = 0; i < counter; i += 1)
    {
        CFErrorRef setError = NULL;
        
        if ( ! ABRecordSetValue(subjectRecord, personalProperties[i], propertyValues[i], &setError))
        {
            STFail(@"Failed setting value: %@ for property: %i", propertyValues[i], personalProperties[i]);
        }
    }

    CFRelease(phoneValue);
    CFRelease(emailValue);
    CFRelease(addressValue);
    
    return subjectRecord;
}

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
    CFRelease(addressBook);
    
    self.records = nil;
    
    [super tearDown];
}

- (void)testInitContactPersonID
{
    STAssertNotNil([[SCContactPerson alloc] initWithABRecordID:kABRecordInvalidID], @"Should not be nil");

    NSNumber *contactID = [self.records objectAtIndex:0];
        
    SCContactPerson *person = [[[SCContactPerson alloc] initWithABRecordID:[contactID intValue]] autorelease];
    
    STAssertTrue([person isKindOfClass:[SCContactPerson class]], @"Person should be an instance of SCContactPerson");
    STAssertTrue([contactID intValue] == [person ABRecordID], @"Person record ID: %i should be equal to: %@", [person ABRecordID], contactID);
}

- (void)testIsSaved
{
    SCContactPerson *newPerson = [[[SCContactPerson alloc] init] autorelease];
    STAssertFalse([newPerson isSaved], @"New person should not be saved");
    
    NSNumber *contactID = [self.records objectAtIndex:0];
    
    SCContactPerson *existingPerson = [[[SCContactPerson alloc] initWithABRecordID:[contactID intValue]] autorelease];
    STAssertTrue([existingPerson isSaved], @"Existing person should be saved");
}

- (void)testLoadRecordError
{
    ABRecordRef subjectRecord = [self createTestAddressBookRecord];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    ABAddressBookAddRecord(addressBook, subjectRecord, NULL);

    if ( ! ABAddressBookSave(addressBook, NULL))
    {
        STFail(@"Failed saving AddressBook");
    }
    
    CFRelease(addressBook);
    
    if (subjectRecord == NULL)
    {
        STFail(@"subjectRecord failed to initialize");
    }
    
    SCContactPerson *subject = [[SCContactPerson alloc] init];
    NSError *subjectError    = nil;
    
    BOOL result = [subject readRecord:ABRecordGetRecordID(subjectRecord)
                                error:&subjectError];
    
    STAssertTrue(result, @"Load person from record should be YES");
    STAssertFalse([subject hasChanges], @"The subject should have changes");
    
    SEL accessorMethods[] = {
        @selector(firstName),
        @selector(lastName),
        @selector(middleName),
        @selector(prefix),
        @selector(suffix),
        @selector(nickName),
        @selector(firstNamePhonetic),
        @selector(lastNamePhonetic),
        @selector(middleNamePhonetic),
        @selector(organization),
        @selector(jobTitle),
        @selector(department),
        @selector(note),
        @selector(birthday)
    };

    NSArray *propertyValues = [self fixtureData];
    
    int counter = (sizeof(accessorMethods) / sizeof(SEL));
    
    for (int i = 0; i < counter; i += 1)
    {
        id returnValue = [subject performSelector:accessorMethods[i]];
        
        if ([returnValue isKindOfClass:[NSString class]])
        {
            NSString *stringValue = (NSString *)returnValue;
            STAssertTrue([stringValue isEqualToString:propertyValues[i]], @"returnValue: %@ should equal propertyValue[%i]: %@", returnValue, i, propertyValues[i]);
        }
    }
    
    // Test email
    STAssertTrue([[subject.email objectForKey:(NSString *)kABHomeLabel] isEqualToString:[self fixtureHomeEmail]], @"Home email :%@ should match returned email: %@", [self fixtureHomeEmail], [subject.email objectForKey:(NSString *)kABHomeLabel]);
    
    // Test iPhone
    STAssertTrue([[subject.phoneNumber objectForKey:(NSString *)kABPersonPhoneIPhoneLabel] isEqualToString:[self fixtureIPhone]], @"Phone (iPhone) :%@ should match returned iPhone: %@", [self fixtureIPhone], [subject.phoneNumber objectForKey:(NSString *)kABPersonPhoneIPhoneLabel]);
    STAssertNil([subject.phoneNumber objectForKey:@"Home Fax"], @"Home fax should be nil");
    
    // Test home address
    NSDictionary *homeAddress = [subject.address objectForKey:(NSString *)kABHomeLabel];
    STAssertTrue([[homeAddress objectForKey:@"Street"] isEqualToString:[[self fixtureHomeAddress] objectForKey:@"Street"]], @"Home address street: %@ should match: %@", [homeAddress objectForKey:@"Street"], [[self fixtureHomeAddress] objectForKey:@"Street"]);
    
    CFRelease(subject);
}

- (void)testSave
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef subjectRecord = [self createTestAddressBookRecord];

    CFErrorRef error = NULL;
    
    if ( ! ABAddressBookAddRecord(addressBook, subjectRecord, &error))
    {
        STFail(@"Address Book add record failed with error: %@", error);
        return;
    }

    if ( ! ABAddressBookSave(addressBook, &error))
    {
        STFail(@"Address Book save failed with error:%@", error);
    }
    
    CFRelease(addressBook);

    SCContactPerson *subject = [[SCContactPerson alloc] initWithABRecordID:ABRecordGetRecordID(subjectRecord)];

    NSError *subjectError    = nil;
    
    [subject readFromRecordRef:subjectRecord error:&subjectError];

    STAssertTrue([subject updateRecord:subject.ABRecordID error:nil], @"Save Record should be TRUE on save with no changes.");
    
    NSString *newFirstName  = @"Robert";
    NSString *newLastName   = @"Clark";
    NSString *newMiddleName = @"John";
    NSString *newNickName   = @"Bob";

    NSMutableDictionary *newEmail       = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"bob@test.com", kABHomeLabel, nil];
    NSMutableDictionary *newPhone       = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"+442074503900", kABPersonPhoneIPhoneLabel, nil];
    NSMutableDictionary *newHomeAddress = [[[self fixtureHomeAddress] mutableCopy] autorelease];
    [newHomeAddress setObject:@"1 Kiln Cottages" forKey:@"Street"];
    
    NSMutableDictionary *newAddress = [NSMutableDictionary dictionaryWithObject:newHomeAddress forKey:(NSString *)kABHomeLabel];
    
    subject.firstName   = newFirstName;
    subject.lastName    = newLastName;
    subject.middleName  = newMiddleName;
    subject.nickName    = newNickName;
    subject.email       = newEmail;
    subject.phoneNumber = newPhone;
    subject.address     = newAddress;
    
    STAssertTrue([subject updateRecord:subject.ABRecordID error:nil], @"Save record should be TRUE");
    
    NSLog(@"Subject record saved: %i with ID: %i", [subject isSaved], subject.ABRecordID);
    
    ABAddressBookRef secondAddressBook = ABAddressBookCreate();
    
    ABRecordRef testSubjectRecord = ABAddressBookGetPersonWithRecordID(secondAddressBook, subject.ABRecordID);
    
    NSLog(@"testSubjectID: %i", ABRecordGetRecordID(testSubjectRecord));
    NSLog(@"testSubject First Name: %@", [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonFirstNameProperty) autorelease]);
    
    NSString *savedFirstName  = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonFirstNameProperty) autorelease];
    NSString *savedLastName   = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonLastNameProperty) autorelease];
    NSString *savedMiddleName = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonMiddleNameProperty) autorelease];
    NSString *savedNickName   = [(NSString *)ABRecordCopyValue(testSubjectRecord, kABPersonNicknameProperty) autorelease];;
    
    ABMultiValueRef addressValue = ABRecordCopyValue(testSubjectRecord, kABPersonAddressProperty);
    NSArray *addresses = [(NSArray *)ABMultiValueCopyArrayOfAllValues(addressValue) autorelease];
    
    STAssertTrue([subject.firstName isEqualToString:savedFirstName], @"Subject firstname: %@ should match saved firstname: %@", subject.firstName, savedFirstName);
    STAssertTrue([subject.lastName isEqualToString:savedLastName], @"Subject lastname: %@ should match saved lastname: %@", subject.lastName, savedLastName);
    STAssertTrue([subject.middleName isEqualToString:savedMiddleName], @"Subject middlename: %@ should match saved middlename: %@", subject.middleName, savedMiddleName);
    STAssertTrue([subject.nickName isEqualToString:savedNickName], @"Subject nickname: %@ should match saved nickname: %@", subject.nickName, savedNickName);
    
    NSDictionary *savedAddress = [addresses objectAtIndex:0];
    
    STAssertTrue([[[subject.address objectForKey:(NSString *)kABHomeLabel] objectForKey:(NSString *)kABPersonAddressStreetKey] isEqualToString:[savedAddress objectForKey:(NSString *)kABPersonAddressStreetKey]], @"Subject Street Address: %@ should match saved Street Address: %@",[[subject.address objectForKey:(NSString *)kABHomeLabel] objectForKey:(NSString *)kABPersonAddressStreetKey], [savedAddress objectForKey:(NSString *)kABPersonAddressStreetKey]);
    
    CFRelease(secondAddressBook);
    CFRelease(addressValue);
    CFRelease(subjectRecord);
}

- (void)testDeleteRecordError
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    // Tear-down code here.
    NSArray *recordsInserted = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
    
    ABRecordRef randomRecord = [recordsInserted objectAtIndex:0];
    ABRecordID recordID      = ABRecordGetRecordID(randomRecord);
        
    SCContactPerson *subject = [[[SCContactPerson alloc] initWithABRecordID:recordID] autorelease];
    
    NSError *deleteError = nil;
    
    STAssertTrue([subject deleteRecord:subject.ABRecordID error:&deleteError], @"Deleting a valid model should return true");
    
    NSArray *recordsRemaining = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
    int count = [recordsRemaining count];
    
    for (int i = 0; i < count; i += 1)
    {
        ABRecordRef record = recordsRemaining[i];
        
        if (ABRecordGetRecordID(record) == recordID)
        {
            STFail(@"Found record ID :%i that should be deleted", recordID);
        }
    }
    
    CFRelease(addressBook);
}


- (void)testDeleteRecordNotSaved
{
    SCContactPerson *subject = [[[SCContactPerson alloc] init] autorelease];

    
    NSError *deleteError = nil;
    
    STAssertTrue([subject deleteRecord:subject.ABRecordID error:&deleteError], @"Deleting a valid model should return YES");
    STAssertNil(deleteError, @"Delete error should be nil");
}

@end
