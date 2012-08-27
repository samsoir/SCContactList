//
//  SCContactPerson.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactList.h"

@implementation SCContactPerson(Private)

- (NSDictionary *)ABAddressBookKeyMap
{
    NSNumber *ABPropertyID[] = {
        [NSNumber numberWithInt:kABPersonFirstNameProperty],
        [NSNumber numberWithInt:kABPersonLastNameProperty],
        [NSNumber numberWithInt:kABPersonMiddleNameProperty],
        [NSNumber numberWithInt:kABPersonPrefixProperty],
        [NSNumber numberWithInt:kABPersonSuffixProperty],
        [NSNumber numberWithInt:kABPersonNicknameProperty],
        [NSNumber numberWithInt:kABPersonFirstNamePhoneticProperty],
        [NSNumber numberWithInt:kABPersonLastNamePhoneticProperty],
        [NSNumber numberWithInt:kABPersonMiddleNamePhoneticProperty],
        [NSNumber numberWithInt:kABPersonOrganizationProperty],
        [NSNumber numberWithInt:kABPersonJobTitleProperty],
        [NSNumber numberWithInt:kABPersonDepartmentProperty],
        [NSNumber numberWithInt:kABPersonNoteProperty],
        [NSNumber numberWithInt:kABPersonBirthdayProperty],
        [NSNumber numberWithInt:kABPersonEmailProperty],
        [NSNumber numberWithInt:kABPersonPhoneProperty],
        [NSNumber numberWithInt:kABPersonInstantMessageProperty],
        [NSNumber numberWithInt:kABPersonSocialProfileProperty],
        [NSNumber numberWithInt:kABPersonURLProperty],
        [NSNumber numberWithInt:kABPersonRelatedNamesProperty],
        [NSNumber numberWithInt:kABPersonAddressProperty]
    };
    
    NSString *contactPersonKeys[] = {
        @"firstName",
        @"lastName",
        @"middleName",
        @"prefix",
        @"suffix",
        @"nickName",
        @"firstNamePhonetic",
        @"lastNamePhonetic",
        @"middleNamePhonetic",
        @"organizatiion",
        @"jobTitle",
        @"department",
        @"note",
        @"birthday",
        @"email",
        @"phoneNumber",
        @"instantMessage",
        @"socialProfile",
        @"URL",
        @"relatedNames",
        @"address"
    };
    
    int keyCount = (sizeof(contactPersonKeys) / sizeof(NSString *));

    NSDictionary *ABAddressBookKeyMap = [NSDictionary dictionaryWithObjects:ABPropertyID
                                                                    forKeys:contactPersonKeys
                                                                      count:keyCount];
    
    return ABAddressBookKeyMap;
}

- (ABPropertyID)ABPersonPropertyForKey:(NSString *)key addressBookKeyMap:(NSDictionary *)ABAddressBookKeyMapOrNil
{
    if (ABAddressBookKeyMapOrNil == nil)
    {
        ABAddressBookKeyMapOrNil = [self ABAddressBookKeyMap];
    }
    
    NSNumber *propertyValue = [ABAddressBookKeyMapOrNil objectForKey:key];
    
    if (propertyValue == nil)
    {
        return kABPropertyInvalidID;
    }

    ABPropertyID ABPersonProperty = (ABPropertyID)[propertyValue intValue];
    
    return ABPersonProperty;
}

- (BOOL)persistRecord:(ABRecordRef)record addressBook:(ABAddressBookRef)addressBook error:(NSError **)error
{
    BOOL result                  = NO;
    
    NSDictionary *changesToModel = [self changesRequiringPersistence];
    NSError *decorateError       = nil;
    
    // Decorate record
    [self decorateABRecord:&record
          fieldsToDecorate:changesToModel
                     error:&decorateError];
    
    CFErrorRef addError = NULL;
    
    if ( ! ABAddressBookAddRecord(addressBook, record, &addError))
    {
        if (addError && error != NULL)
        {
            *error = (NSError *)addError;
        }
    }
    
    CFErrorRef saveError = NULL;
    
    if ( ! ABAddressBookSave(addressBook, &saveError))
    {
        if (error != NULL)
        {
            *error = (NSError *)saveError;
        }
    }
    else
    {
        result = YES;
        [self updateRecordModificationDates:record];
        [self _resetState];
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (void)updateRecordModificationDates:(ABRecordRef)record
{
    if (_creationDate != nil)
    {
        [_creationDate release];
    }
    
    if (_modificationDate != nil)
    {
        [_modificationDate release];
    }
    
    _creationDate     = (NSDate *)ABRecordCopyValue(record, kABPersonCreationDateProperty);
    _modificationDate = (NSDate *)ABRecordCopyValue(record, kABPersonModificationDateProperty);
}

@end

@implementation SCContactPerson

@synthesize image              = _image;

@synthesize firstName          = _firstName;
@synthesize lastName           = _lastName;
@synthesize middleName         = _middleName;
@synthesize prefix             = _prefix;
@synthesize suffix             = _suffix;
@synthesize nickName           = _nickName;

@synthesize firstNamePhonetic  = _firstNamePhonetic;
@synthesize lastNamePhonetic   = _lastNamePhonetic;
@synthesize middleNamePhonetic = _middleNamePhonetic;

@synthesize organization       = _organization;
@synthesize jobTitle           = _jobTitle;
@synthesize department         = _department;

@synthesize birthday           = _birthday;

@synthesize email              = _email;
@synthesize address            = _address;
@synthesize phoneNumber        = _phoneNumber;
@synthesize instantMessage     = _instantMessage;
@synthesize socialProfile      = _socialProfile;
@synthesize URL                = _URL;
@synthesize relatedNames       = _relatedNames;

@synthesize note               = _note;

@synthesize creationDate       = _creationDate;
@synthesize modificationDate   = _modificationDate;

#pragma mark - SCContactPerson lifecycle methods

+ (SCContactPerson *)contactPersonWithID:(ABRecordID)personID
{
    return [[[SCContactPerson alloc] initWithABRecordID:personID] autorelease];
}

- (ABRecordRef)addressBook:(ABAddressBookRef)addressBook getABRecordWithID:(ABRecordID)recordID
{
    return ABAddressBookGetPersonWithRecordID(addressBook, recordID);
}

- (void)initializeMutableDictionaryPropertiesWithSize:(NSUInteger)size
{
    self.email          = [NSMutableDictionary dictionaryWithCapacity:size];
    self.address        = [NSMutableDictionary dictionaryWithCapacity:size];
    self.phoneNumber    = [NSMutableDictionary dictionaryWithCapacity:size];
    self.instantMessage = [NSMutableDictionary dictionaryWithCapacity:size];
    self.socialProfile  = [NSMutableDictionary dictionaryWithCapacity:size];
    self.URL            = [NSMutableDictionary dictionaryWithCapacity:size];
    self.relatedNames   = [NSMutableDictionary dictionaryWithCapacity:size];
}

- (id)initWithABRecordID:(ABRecordID)recordID
{
    self = [super initWithABRecordID:recordID];
    
    if (self)
    {
        [self initializeMutableDictionaryPropertiesWithSize:kSCContactDefaultDictionarySize];
     
        if (self.ABRecordID > kABRecordInvalidID)
        {
            if ( ! [self readRecord:self.ABRecordID error:nil])
            {
                [self release];
                return nil;
            }
        }
    }
    
    return self;
}

- (void)dealloc
{    
    [_image release];
    
    [_firstName release];
    [_lastName release];
    [_middleName release];
    [_prefix release];
    [_suffix release];
    [_nickName release];
    
    [_firstNamePhonetic release];
    [_lastNamePhonetic release];
    [_middleNamePhonetic release];
    
    [_organization release];
    [_jobTitle release];
    [_department release];
    
    [_birthday release];
    
    [_email release];
    [_address release];
    [_phoneNumber release];
    [_instantMessage release];
    [_socialProfile release];
    [_URL release];
    [_relatedNames release];
    
    [_note release];
    
    [_creationDate release];
    [_modificationDate release];
    
    [super dealloc];
}

#pragma mark - Key/Value Observing Methods

- (NSArray *)objectKeysToObserve
{
    NSArray *keysToObserve = [NSArray arrayWithObjects:
                              @"firstName",
                              @"lastName",
                              @"middleName",
                              @"prefix",
                              @"suffix",
                              @"nickName",
                              @"firstNamePhonetic",
                              @"lastNamePhonetic",
                              @"middleNamePhonetic",
                              @"organization",
                              @"jobTitle",
                              @"department",
                              @"note",
                              @"birthday",
                              @"email",
                              @"address",
                              @"phoneNumber",
                              @"instantMessage",
                              @"socialProfile",
                              @"url",
                              @"relatedName",
                              nil];

    NSMutableArray *parentKeysToObserve = [[[super objectKeysToObserve] mutableCopy] autorelease];
    
    [parentKeysToObserve addObjectsFromArray:keysToObserve];
    
    return parentKeysToObserve;
}

#pragma mark - SCContactPerson Decorator Methods

- (void)setImageDataFromRecord:(ABRecordRef)record
{
    if ( ! ABPersonHasImageData(record))
    {
        return;
    }
    
    self.image = [(NSData *)ABPersonCopyImageData(record) autorelease];
}

- (ABMutableMultiValueRef)createMultiValueForProperty:(ABPropertyType)propertyType withDictionary:(NSDictionary *)dictionary
{
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(propertyType);
    
    int multiValueSize = [dictionary count];
    
    id objects[multiValueSize];
    NSString *objectKeys[multiValueSize];
    
    [dictionary getObjects:objects
                   andKeys:objectKeys];
    
    for (int i = 0; i < multiValueSize; i += 1)
    {
        ABMultiValueInsertValueAndLabelAtIndex(multiValue, objects[i], (CFStringRef)objectKeys[i], i, NULL);
    }
    
    return multiValue;
}

- (BOOL)decorateABRecord:(ABRecordRef *)record fieldsToDecorate:(NSDictionary *)fieldsToDecorate error:(NSError **)error
{
    BOOL result = NO;
    
    NSDictionary *ABPropertyKeys = [self ABAddressBookKeyMap];
    
    for (NSString *fieldToDecorate in fieldsToDecorate)
    {
        ABPropertyID propertyID = [self ABPersonPropertyForKey:fieldToDecorate
                                             addressBookKeyMap:ABPropertyKeys];
        
        NSDictionary *change    = [fieldsToDecorate valueForKey:fieldToDecorate];
        id value                = [change valueForKey:NSKeyValueChangeNewKey];
        ABPropertyType type     = ABPersonGetTypeOfProperty(propertyID);
        
        if (value == nil)
        {
            CFErrorRef removeValueError = NULL;
            
            if ( ! ABRecordRemoveValue(record, propertyID, &removeValueError))
            {
                if (error != NULL)
                {
                    *error = (NSError *)removeValueError;
                }
                
                return result;
            }
        }
        else
        {
            CFErrorRef setValueError = NULL;
            
            if (type & kABMultiValueMask)
            {
                ABMutableMultiValueRef multiValue = [self createMultiValueForProperty:type withDictionary:value];
                
                if ( ! ABRecordSetValue(record, propertyID, multiValue, &setValueError))
                {
                    if (error != NULL)
                    {
                        *error = (NSError *)setValueError;
                    }
                    
                    return result;
                }
            }
            else
            {
                if ( ! ABRecordSetValue(record, propertyID, value, &setValueError))
                {
                    if (error != NULL)
                    {
                        *error = (NSError *)setValueError;
                    }
                    
                    return result;
                }
            }
        }
    }
    
    result = YES;
    
    return result;
}

- (BOOL)readFromRecordRef:(ABRecordRef *)recordRef error:(NSError **)error
{
    BOOL result = NO;

    if (recordRef == NULL)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:kSCContactRecord
                                         code:kSCContactRecordReadError
                                     userInfo:nil];
        }
        
        return result;
    }
    
    // Load personal properties
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
        kABPersonBirthdayProperty,
        kABPersonEmailProperty,
        kABPersonPhoneProperty,
        kABPersonInstantMessageProperty,
        kABPersonSocialProfileProperty,
        kABPersonURLProperty,
        kABPersonRelatedNamesProperty,
        kABPersonAddressProperty
    };
    
    SEL personalPropertiesAccessorMethods[] = {
        @selector(setFirstName:),
        @selector(setLastName:),
        @selector(setMiddleName:),
        @selector(setPrefix:),
        @selector(setSuffix:),
        @selector(setNickName:),
        @selector(setFirstNamePhonetic:),
        @selector(setLastNamePhonetic:),
        @selector(setMiddleNamePhonetic:),
        @selector(setOrganization:),
        @selector(setJobTitle:),
        @selector(setDepartment:),
        @selector(setNote:),
        @selector(setBirthday:),
        @selector(setEmail:),
        @selector(setPhoneNumber:),
        @selector(setInstantMessage:),
        @selector(setSocialProfile:),
        @selector(setURL:),
        @selector(setRelatedNames:),
        @selector(setAddress:)
    };
    
    int personalPropertiesCount = (sizeof(personalProperties) / sizeof(ABPropertyID));
    
    [self setProperties:personalProperties
    withAccessorMethods:personalPropertiesAccessorMethods
             fromRecord:recordRef
     numberOfProperties:personalPropertiesCount];
    
    self.ABRecordID = ABRecordGetRecordID(recordRef);
    
    // Load image data
    [self setImageDataFromRecord:recordRef];
    
    // Load creation / modification dates
    [self updateRecordModificationDates:recordRef];
    
    [self _resetState];
    
    result = YES;
    
    return result;
}

#pragma mark - SCContactRecordPersistence protocol methods

- (BOOL)createRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result                  = NO;
    NSError *createError         = nil;
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil
                                                                            error:&createError];

    if (createError && error != NULL)
    {
        *error = createError;
    }
    
    if ( ! addressBook || createError != nil)
    {
        return result;
    }
    else
    {
        ABRecordRef newPersonRecord  = ABPersonCreate();
        CFErrorRef addError = NULL;

        if ( ! ABAddressBookAddRecord(addressBook, newPersonRecord, &addError))
        {
            if (addError && error != NULL)
            {
                *error = (NSError *)addError;
            }
        }
        else
        {
            result = [self persistRecord:newPersonRecord
                             addressBook:addressBook
                                   error:error];
            
            if (result)
            {
                self.ABRecordID = ABRecordGetRecordID(newPersonRecord);
            }
        }

        CFRelease(newPersonRecord);
    }
    
    CFRelease(addressBook);
    
    return result;
}

- (BOOL)readRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result                  = NO;
    NSError *readError           = nil;
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil
                                                                            error:&readError];
    
    if (readError && error != NULL)
    {
        *error = readError;
    }
    
    if ( ! addressBook || readError != nil)
    {
        return result;
    }
    
    ABRecordRef record = [self addressBook:addressBook getABRecordWithID:self.ABRecordID];

    if (record == NULL)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomain:kSCContactRecord
                                         code:kSCContactRecordReadError
                                     userInfo:nil];
        }
        
        return result;
    }
    
    return [self readFromRecordRef:&record error:error];
}

- (BOOL)updateRecord:(ABRecordID)recordID error:(NSError **)error
{
    BOOL result                  = NO;
    NSError *updateError         = nil;
    ABAddressBookRef addressBook = [SCContactAddressBook createAddressBookOptions:nil
                                                                            error:&updateError];
    
    if (updateError && error != NULL)
    {
        *error = updateError;
    }
    
    if ( ! addressBook || updateError != nil)
    {
        return result;
    }
    else
    {
        ABRecordRef record = [self addressBook:addressBook getABRecordWithID:self.ABRecordID];

        result = [self persistRecord:record
                         addressBook:addressBook
                               error:error];
    }

    CFRelease(addressBook);
    
    return result;
}

@end
