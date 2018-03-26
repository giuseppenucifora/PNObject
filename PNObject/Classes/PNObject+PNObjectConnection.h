//
//  PNObjectConnection.h
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject.h"
#import "PNObject+PNObjectGETConnection.h"
#import "PNObject+PNObjectPOSTConnection.h"
#import "PNObject+PNObjectDELETEConnection.h"

#define MAX_RETRIES 3

@interface PNObject (PNObjectConnection)

+ (id _Nonnull) parseObjectFromResponse:(id _Nullable) response;

@end
