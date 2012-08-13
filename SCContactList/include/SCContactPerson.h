//
//  SCContactPerson.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCContactRecord.h"

#ifndef kSCContactDefaults
#define kSCContactDefaults

#define kSCContactDefaultDictionarySize 3

#define kSCContactEmailHome kABHomeLabel
#define kSCContactEmailWork kABWorkLabel
#endif


@interface SCContactPerson : SCContactRecord {
    
    NSData                *_image;
    
    NSString              *_firstName;
    NSString              *_lastName;
    NSString              *_middleName;
    NSString              *_prefix;
    NSString              *_suffix;
    NSString              *_nickName;
    
    NSString              *_firstNamePhonetic;
    NSString              *_lastNamePhonetic;
    NSString              *_middleNamePhonetic;
    
    NSString              *_organization;
    NSString              *_jobTitle;
    NSString              *_department;

    NSDate                *_birthday;

    NSMutableDictionary   *_email;
    NSMutableDictionary   *_address;
    NSMutableDictionary   *_phoneNumber;
    NSMutableDictionary   *_instantMessage;
    NSMutableDictionary   *_socialProfile;
    NSMutableDictionary   *_URL;
    NSMutableDictionary   *_relatedNames;
    
    NSString              *_note;
    
    NSDate                *_creationDate;
    NSDate                *_modificationDate;
    
}

@property (nonatomic, retain) NSData              *image;

@property (nonatomic, retain) NSString            *firstName;
@property (nonatomic, retain) NSString            *lastName;
@property (nonatomic, retain) NSString            *middleName;
@property (nonatomic, retain) NSString            *prefix;
@property (nonatomic, retain) NSString            *suffix;
@property (nonatomic, retain) NSString            *nickName;

@property (nonatomic, retain) NSString            *firstNamePhonetic;
@property (nonatomic, retain) NSString            *lastNamePhonetic;
@property (nonatomic, retain) NSString            *middleNamePhonetic;

@property (nonatomic, retain) NSString            *organization;
@property (nonatomic, retain) NSString            *jobTitle;
@property (nonatomic, retain) NSString            *department;

@property (nonatomic, retain) NSDate              *birthday;

@property (nonatomic, retain) NSMutableDictionary *email;
@property (nonatomic, retain) NSMutableDictionary *address;
@property (nonatomic, retain) NSMutableDictionary *phoneNumber;
@property (nonatomic, retain) NSMutableDictionary *instantMessage;
@property (nonatomic, retain) NSMutableDictionary *socialProfile;
@property (nonatomic, retain) NSMutableDictionary *URL;
@property (nonatomic, retain) NSMutableDictionary *relatedNames;

@property (nonatomic, retain) NSString            *note;

@property (nonatomic, readonly) NSDate            *creationDate;
@property (nonatomic, readonly) NSDate            *modificationDate;

#pragma mark - SCContactPerson lifecycle methods

+ (SCContactPerson *)contactPersonWithID:(NSNumber *)personID;

- (id)initWithContactPersonID:(NSNumber *)personID;

#pragma mark - SCContactPerson state methods

- (BOOL)loadPersonFromRecord:(ABRecordRef)record
                       error:(NSError **)error;

- (BOOL)save:(NSError **)error;

- (BOOL)remove:(NSError **)error;

- (BOOL)isSaved;

- (BOOL)hasChanges;

@end
