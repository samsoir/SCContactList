//
//  SCContactPerson.m
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import "SCContactPerson.h"

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
@synthesize url                = _url;
@synthesize relatedName        = _relatedName;

@synthesize note               = _note;

@synthesize creationDate       = _creationDate;
@synthesize modificationDate   = _modificationDate;

#pragma mark - SCContactPerson lifecycle methods

+ (SCContactPerson *)contactPersonWithID:(NSNumber *)personID
{
    return [[[SCContactPerson alloc] initWithContactPersonID:personID] autorelease];
}

- (id)initWithContactPersonID:(NSNumber *)personID
{
    if (personID == nil)
    {
        return nil;
    }
    
    self = [self init];
    
    if (self)
    {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABRecordRef personRecord     = ABAddressBookGetPersonWithRecordID(addressBook, [personID intValue]);
        
        if (personRecord == NULL || ABRecordGetRecordType(personRecord) != kABPersonType)
        {
            CFRelease(addressBook);
            return nil;
        }
        
        [self setABRecord:personRecord];
        _recordExistsInDatabase = YES;
        
        CFRelease(addressBook);
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        ABRecordRef personRecord = ABPersonCreate();
        
        if (personRecord == NULL || ABRecordGetRecordType(personRecord) != kABPersonType)
        {
            if (personRecord != NULL)
            {
                CFRelease(personRecord);
            }
            
            return nil;
        }
        
        _ABRecord               = personRecord;
        _recordExistsInDatabase = NO;
        _recordHasChanges       = NO;
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
    [_url release];
    [_relatedName release];
    
    [_note release];
    
    [_creationDate release];
    [_modificationDate release];
    
    [super dealloc];
}

#pragma mark - SCContactGroup methods

- (BOOL)save:(NSError **)error
{
    return NO;
}

- (BOOL)remove:(NSError **)error
{
    return NO;
}

- (BOOL)isSaved
{
    return (_recordExistsInDatabase && ! _recordHasChanges);
}

- (BOOL)hasChanges
{
    return NO;
}


@end
