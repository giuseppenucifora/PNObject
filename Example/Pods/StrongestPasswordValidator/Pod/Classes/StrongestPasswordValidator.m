
#import "StrongestPasswordValidator.h"

#define REGEX_PASSWORD_ONE_UPPERCASE @"^(?=.*[A-Z]).*$"  //Should contains one or more uppercase letters
#define REGEX_PASSWORD_ONE_LOWERCASE @"^(?=.*[a-z]).*$"  //Should contains one or more lowercase letters
#define REGEX_PASSWORD_ONE_NUMBER @"^(?=.*[0-9]).*$"  //Should contains one or more number
#define REGEX_PASSWORD_ONE_SYMBOL @"^(?=.*[!@#$%&_]).*$"  //Should contains one or more symbol

@interface StrongestPasswordValidator()

@property (nonatomic, strong) UIColor *weakColor;
@property (nonatomic, strong) UIColor *moderateColor;
@property (nonatomic, strong) UIColor *strongColor;

@end


@implementation StrongestPasswordValidator

static StrongestPasswordValidator *SINGLETON = nil;

static bool isFirstAccess = YES;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

- (void) setColor:(UIColor *)color forPasswordStrenghtType:(PasswordStrengthType)strenghtType {
    switch (strenghtType) {
        case PasswordStrengthTypeWeak: {
            _weakColor = color;
            break;
        }
        case PasswordStrengthTypeModerate: {
            _moderateColor = color;
            break;
        }
        case PasswordStrengthTypeStrong: {
            _strongColor = color;
            break;
        }
    }
}

#pragma mark - Life Cycle

+ (instancetype) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (instancetype)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (instancetype)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (instancetype)copy
{
    return [[StrongestPasswordValidator alloc] init];
}

- (instancetype)mutableCopy
{
    return [[StrongestPasswordValidator alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    if (self) {
        _weakColor = [UIColor redColor];
        _moderateColor = [UIColor yellowColor];
        _strongColor = [UIColor greenColor];
    }
    return self;
}

- (void)checkPasswordStrength:(NSString * _Nonnull )password withBlock:(nullable void (^)(UIColor * _Nonnull color, PasswordStrengthType  strenghtType)) responseBlock; {
    
    if (responseBlock) {
        
        PasswordStrengthType strenght = [self checkPasswordStrength:password];
        
        switch (strenght) {
            case PasswordStrengthTypeWeak: {
                responseBlock(_weakColor,strenght);
                break;
            }
            case PasswordStrengthTypeModerate: {
                responseBlock(_moderateColor,strenght);
                break;
            }
            case PasswordStrengthTypeStrong: {
                responseBlock(_strongColor,strenght);
                break;
            }
            default:
                break;
        }
    }
}

- (PasswordStrengthType)checkPasswordStrength:(NSString *)password {
    NSInteger len = (long)password.length;
    //will contains password strength
    int strength = 0;
    
    if (len == 0) {
        return PasswordStrengthTypeWeak;
    } else if (len <= 5) {
        strength++;
    } else if (len <= 10) {
        strength += 2;
    } else{
        strength += 3;
    }
    
    strength += [self validateString:password withPattern:REGEX_PASSWORD_ONE_UPPERCASE caseSensitive:YES];
    strength += [self validateString:password withPattern:REGEX_PASSWORD_ONE_LOWERCASE caseSensitive:YES];
    strength += [self validateString:password withPattern:REGEX_PASSWORD_ONE_NUMBER caseSensitive:YES];
    strength += [self validateString:password withPattern:REGEX_PASSWORD_ONE_SYMBOL caseSensitive:YES];
    
    if(strength <= 3){
        return PasswordStrengthTypeWeak;
    }else if(3 < strength && strength < 6){
        return PasswordStrengthTypeModerate;
    }else{
        return PasswordStrengthTypeStrong;
    }
}

// Validate the input string with the given pattern and
// return the result as a boolean
- (int)validateString:(NSString *)string withPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:((caseSensitive) ? 0 : NSRegularExpressionCaseInsensitive) error:&error];
    
    NSAssert(regex, @"Unable to create regular expression");
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:textRange];
    
    BOOL didValidate = 0;
    
    // Did we find a matching range
    if (matchRange.location != NSNotFound)
        didValidate = 1;
    
    return didValidate;
}

@end
