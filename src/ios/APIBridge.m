#import "APIBridge.h"

@interface APIBridge ()

@property (nonatomic, strong) NSMutableArray *accounts;

@end

@implementation APIBridge

- (instancetype)init
{
    if (self = [super init])
    {
        self.accounts = [NSMutableArray new];

        [self setupAccounts];
    }

    return self;
}

- (void)CCC_getAccounts:(void (^)(NSArray<CCCAccount *> *, NSError *))completion
{
    completion(self.accounts,nil);
}

- (void)CCC_saveAccountToCustomer:(CCCAccount *)account completion:(void (^)(CCCAccount *, NSError *))completion
{
    account.accountID = [NSString stringWithFormat:@"%lu",(unsigned long)self.accounts.count];
    [self.accounts addObject:account];
    completion(account,nil);
}

- (void)CCC_updateAccount:(CCCAccount *)account completion:(void (^)(CCCAccount *, NSError *))completion
{
    [self.accounts replaceObjectAtIndex:account.accountID.integerValue withObject:account];
    completion(account,nil);
}

- (void)CCC_deleteCustomerAccount:(NSString *)accountID completion:(void (^)(BOOL, NSError *))completion
{
    [self.accounts removeObjectAtIndex:accountID.integerValue];
    completion(YES,nil);
}

- (void)CCC_authApplePayTransactionWithToken:(NSString *)token completion:(void (^)(BOOL, NSError *))completion
{
    completion(true,nil);
}

#pragma Testing Data

- (void)setupAccounts
{
    CCCAccount *account = [CCCAccount new];
    account.accountID = @"0";
    account.accountType = CCC_AccountTypeForIssuer(CCCCardIssuerMasterCard);
    account.defaultAccount = YES;
    account.expirationDate = [NSDate date];
    account.name = @"Cardholders Name";
    account.token = @"4658216846214761";

    [self.accounts addObject:account];

    CCCAccount *account2 = [CCCAccount new];
    account2.accountID = @"1";
    account2.accountType = CCC_AccountTypeForIssuer(CCCCardIssuerVISA);
    account2.defaultAccount = NO;
    account2.expirationDate = [NSDate date];
    account2.name = @"Cardholders Name";
    account2.token = @"4658216846211259";

    [self.accounts addObject:account2];

    CCCAccount *account3 = [CCCAccount new];
    account3.accountID = @"2";
    account3.accountType = CCC_AccountTypeForIssuer(CCCCardIssuerAMEX);
    account3.defaultAccount = NO;
    account3.expirationDate = [NSDate date];
    account3.name = @"Cardholders Name";
    account3.token = @"4658216846219876";

    [self.accounts addObject:account3];

    CCCAccount *account4 = [CCCAccount new];
    account4.accountID = @"3";
    account4.accountType = CCC_AccountTypeForIssuer(CCCCardIssuerVISA);
    account4.defaultAccount = NO;
    account4.expirationDate = [NSDate date];
    account4.name = @"Cardholders Name";
    account4.token = @"4658216846218273";

    [self.accounts addObject:account4];
}

@end
