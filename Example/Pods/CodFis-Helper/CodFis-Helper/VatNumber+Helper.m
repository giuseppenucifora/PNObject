//
//  VatNumber+Helper.m
//  Pods
//
//  Created by Giuseppe Nucifora on 13/07/15.
//
//

#import "VatNumber+Helper.h"

@implementation VatNumber_Helper

+ (NSString *) evaluate:(NSString*) vatNum {
    
    vatNum = [vatNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    const char * vatNumC = [vatNum UTF8String];
    
    int i, c, s;
    if( vatNumC[0] == 0 )  return @"";
    if( strlen(vatNumC) != 11 )
        return @"La lunghezza della partita IVA non &egrave;\n"
        "corretta: la partita IVA dovrebbe essere lunga\n"
        "esattamente 11 caratteri.\n";
    for( i=0; i<11; i++ ){
        if( ! isdigit(vatNumC[i]) )
            return @"La partita IVA contiene dei caratteri non ammessi:\n"
            "la partita IVA dovrebbe contenere solo cifre.\n";
    }
    s = 0;
    for( i=0; i<=9; i+=2 )
        s += vatNumC[i] - '0';
    for( i=1; i<=9; i+=2 ){
        c = 2*( vatNumC[i] - '0' );
        if( c > 9 )  c = c - 9;
        s += c;
    }
    if( ( 10 - s%10 )%10 != vatNumC[10] - '0' )
        return @"La partita IVA non &egrave; valida:\n"
        "il codice di controllo non corrisponde.";
    return @"";
}

@end
