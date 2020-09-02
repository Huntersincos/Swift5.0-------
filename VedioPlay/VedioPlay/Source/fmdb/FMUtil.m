//
//  FMUtil.m
//  fmdb
//
//  Created by Phil on 14-8-25.
//
//

#import "FMUtil.h"
#import "sqlite3.h"

NSDictionary * FMUtilGetCountryCodeDic()
{
    static NSDictionary *countryCodeDictionary = nil;
    if (countryCodeDictionary == nil) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CountryList" ofType:@"plist"];
        countryCodeDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return countryCodeDictionary;
}

BOOL FMUtilStringEmpty(NSString *string)
{
    if (string == nil) return YES;
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [@"" isEqualToString:string];
}

BOOL FMUtilContactsIsDialable(unichar c)
{
    return c == ';' || c == '=' || c == ',' || c == '!' ||c == '\'' ||  c == '&' || c == ':' || c == '@' || c == '.' || c == '+' || c == '*' || c == '#' || (c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

NSString * FMUtilContactsGetDialablePhone(NSString *phone)
{
    NSMutableString *string = [NSMutableString stringWithCapacity:phone.length + 5];
    int i = 0;
    
    for (; i < phone.length; ++i) {
        unichar c = [phone characterAtIndex:i];
        if (FMUtilContactsIsDialable(c)) {
            [string appendFormat:@"%c",c];
        }
    }
    return string;
}

NSString * FMUtilContactsGetPhoneCountryCode(NSString *phone)
{
    NSString *tempPhone = FMUtilContactsGetDialablePhone(phone);
    if ([tempPhone hasPrefix:@"00"]) {
        tempPhone = [tempPhone substringWithRange:NSMakeRange(2, tempPhone.length - 2)];
    } else if ([tempPhone hasPrefix:@"+"]) {
        tempPhone = [tempPhone substringWithRange:NSMakeRange(1, tempPhone.length - 1)];
    } else {
        return @"";
    }
    
    NSDictionary *countryCodeDic = FMUtilGetCountryCodeDic();
    NSArray *keys = [countryCodeDic allKeys];
    NSString *codeResult = @"";
    for (int i=0; i<keys.count; i++) {
        NSString *code = [countryCodeDic objectForKey:[keys objectAtIndex:i]];
        if ([tempPhone compare:code options:NSAnchoredSearch range:NSMakeRange(0,[code length])] == NSOrderedSame) {
            if (code.length > codeResult.length)
                codeResult = code;
        }
    }
    return codeResult;
}

NSString * FMUtilContactsGetPhoneWithCountryCode(NSString *phone)
{
    NSString *formatPhone;
    NSString *tempPhone = FMUtilContactsGetDialablePhone(phone);
    if (!FMUtilStringEmpty(FMUtilContactsGetPhoneCountryCode(phone))) {
        formatPhone = tempPhone;
    } else if (tempPhone.length == 11 && [tempPhone hasPrefix:@"1"]){
        formatPhone = [@"+86" stringByAppendingString:tempPhone];
    } else {
        formatPhone = tempPhone;
    }
    return formatPhone;
}

void compare_number(sqlite3_context *ctx, int argc, sqlite3_value **argv)
{
    char* argv0 = (char*)sqlite3_value_text(argv[0]);
    char* argv1 = (char*)sqlite3_value_text(argv[1]);
    
    if ((argv0 == NULL && argv1 != NULL) || (argv0 != NULL && argv1 == NULL))
    {
        sqlite3_result_int(ctx, 0);
        return;
    }
    if (argv0 == NULL && argv1 == NULL)
    {
        sqlite3_result_int(ctx, 1);
        return;
    }
    
    NSString *pcNumber1 = [NSString stringWithUTF8String:argv0];
    NSString *pcNumber2 = [NSString stringWithUTF8String:argv1];
    
    NSString *pcFmtNumber1 = FMUtilContactsGetPhoneWithCountryCode(pcNumber1);
    NSString *pcFmtNumber2 = FMUtilContactsGetPhoneWithCountryCode(pcNumber2);
    
    if ([pcFmtNumber1 isEqualToString:pcFmtNumber2])
        sqlite3_result_int(ctx, 1);
    else
        sqlite3_result_int(ctx, 0);
}

void compare_name(sqlite3_context *ctx, int argc, sqlite3_value **argv)
{
    char* argv0 = (char*)sqlite3_value_text(argv[0]);
    char* argv1 = (char*)sqlite3_value_text(argv[1]);
    
    if ((argv0 == NULL && argv1 != NULL) || (argv0 != NULL && argv1 == NULL))
    {
        sqlite3_result_int(ctx, 0);
        return;
    }
    if (argv0 == NULL && argv1 == NULL)
    {
        sqlite3_result_int(ctx, 1);
        return;
    }
    NSString *pcName1 = [NSString stringWithUTF8String:argv0];
    NSString *pcName2 = [NSString stringWithUTF8String:argv1];
    
    if ([pcName1 isEqualToString:pcName2])
        sqlite3_result_int(ctx, 1);
    else
        sqlite3_result_int(ctx, 0);
}

void compare_number_list(sqlite3_context *ctx, int argc, sqlite3_value **argv)
{
    char* argv0 = (char*)sqlite3_value_text(argv[0]);
    char* argv1 = (char*)sqlite3_value_text(argv[1]);
    
    if ((argv0 == NULL && argv1 != NULL) || (argv0 != NULL && argv1 == NULL))
    {
        sqlite3_result_int(ctx, 0);
        return;
    }
    if (argv0 == NULL && argv1 == NULL)
    {
        sqlite3_result_int(ctx, 1);
        return;
    }
    
    NSString *numbersX = [NSString stringWithUTF8String:argv0];
    NSString *numbersY = [NSString stringWithUTF8String:argv1];
    
    NSArray* numberArrayX = [numbersX componentsSeparatedByString:@","];
    NSArray* numberArrayY = [numbersY componentsSeparatedByString:@","];
    
    if (numberArrayX.count != numberArrayY.count)
    {
        sqlite3_result_int(ctx, 0);
        return;
    }
    
    
    int result = 1;
    for (NSString* numberX in numberArrayX)
    {
        NSString *fmtNumberX = FMUtilContactsGetPhoneWithCountryCode(numberX);
        for (NSString* numberY in numberArrayY)
        {
            NSString *fmtNumberY = FMUtilContactsGetPhoneWithCountryCode(numberY);
            if ([fmtNumberY isEqualToString:fmtNumberX])
            {
                result = 1;
                break;
            } else {
                result = 0;
            }
        }
        if (result == 0) {
            break;
        }
    }
    
    sqlite3_result_int(ctx, result);
    return;
}
