//
//  FMUtil.h
//  fmdb
//
//  Created by Phil on 14-8-25.
//
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

NSDictionary * FMUtilGetCountryCodeDic();

BOOL FMUtilStringEmpty(NSString *string);

BOOL FMUtilContactsIsDialable(unichar c);

NSString * FMUtilContactsGetDialablePhone(NSString *phone);

NSString * FMUtilContactsGetPhoneCountryCode(NSString *phone);

NSString * FMUtilContactsGetPhoneWithCountryCode(NSString *phone);

void compare_number(sqlite3_context *ctx, int argc, sqlite3_value **argv);

void compare_number_list(sqlite3_context *ctx, int argc, sqlite3_value **argv);

void compare_name(sqlite3_context *ctx, int argc, sqlite3_value **argv);
