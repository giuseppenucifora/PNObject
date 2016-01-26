//
//  CodFis+Helper.h
//  Pods
//
//  Created by Giuseppe Nucifora on 08/07/15.
//
//

#import <Foundation/Foundation.h>
#import "CodFisResponse.h"

@interface CodFis_Helper : NSObject

typedef enum {
    Italy,
    OtherCountries
} State;

typedef enum {
    Gender_Woman,
    Gender_Man
} Gender;

@property (nonatomic, strong)   NSString *surname;
@property (nonatomic, strong)   NSString *name;
@property (nonatomic)	NSInteger birthDay;
@property (nonatomic)	NSInteger birthMonth;
@property (nonatomic)	NSInteger birthYear;
@property (nonatomic, assign)	Gender	gender;
@property (nonatomic, assign)   State	state;
@property (nonatomic, strong)   NSString *place;
@property (nonatomic) BOOL collision;


+ (CodFisResponse*) calculateFromSurname:(NSString*) surname name:(NSString*) name birthDay:(NSInteger) birthDay birthMonth:(NSInteger) birthMonth birthYear:(NSInteger) birthYear gender:(Gender) gender state:(State) state place:(NSString*) place collision:(BOOL) collision;

+ (BOOL) checkCodFisFromSurname:(NSString*) surname name:(NSString*) name birthDay:(NSInteger) birthDay birthMonth:(NSInteger) birthMonth birthYear:(NSInteger) birthYear gender:(Gender) gender state:(State) state place:(NSString*) place collision:(BOOL) collision andCodFis:(NSString*) codFis;

- (instancetype) initFromSurname:(NSString*) surname name:(NSString*) name birthDay:(NSInteger) birthDay birthMonth:(NSInteger) birthMonth birthYear:(NSInteger) birthYear gender:(Gender) gender state:(State) state place:(NSString*) place collision:(BOOL) collision;

- (CodFisResponse*) calculate;

- (BOOL) check:(NSString*) codFis;

@end
