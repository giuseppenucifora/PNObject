//
//  ResponseConstants.h
//  cinecitta
//
//  Created by Giuseppe Nucifora on 30/06/14.
//  Copyright (c) 2014 meedori. All rights reserved.
//

typedef enum {
    // Informational
    ResponseStatusContinue                        = 100,
    ResponseStatusSwitchingProtocols              = 101,
    
    // Successful
    ResponseStatusOK                              = 200,
    ResponseStatusCreated                         = 201,
    ResponseStatusAccepted                        = 202,
    ResponseStatusNonAuthoritativeInformation     = 203,
    ResponseStatusNoContent                       = 204,
    ResponseStatusResetContent                    = 205,
    ResponseStatusPartialContent                  = 206,
    
    // Redirection
    ResponseStatusMutltipleChoices                = 300,
    ResponseStatusMovedPermanently                = 301,
    ResponseStatusFound                           = 302,
    ResponseStatusSeeOther                        = 303,
    ResponseStatusNotModified                     = 304,
    ResponseStatusUseProxy                        = 305,
    ResponseStatusSwitchProxy                     = 306,
    ResponseStatusTemporaryRedirect               = 307,
    
    // Client Errors
    ResponseStatusBadRequest                      = 400,
    ResponseStatusUnauthorized                    = 401,
    ResponseStatusPaymentRequired                 = 402,
    ResponseStatusForbidden                       = 403,
    ResponseStatusNotFound                        = 404,
    ResponseStatusMethodNotAllowed                = 405,
    ResponseStatusNotAcceptable                   = 406,
    ResponseStatusProxyAuthenticationRequired     = 407,
    ResponseStatusRequestTimeout                  = 408,
    ResponseStatusConflict                        = 409,
    ResponseStatusGone                            = 410,
    ResponseStatusLengthRequired                  = 411,
    ResponseStatusPreconditionFailed              = 412,
    ResponseStatusRequestEntityTooLarge           = 413,
    ResponseStatusRequestURITooLong               = 414,
    ResponseStatusUnsupportedMediaType            = 415,
    ResponseStatusRequestedRangeNotSatisfiable    = 416,
    ResponseStatusExpectationFailed               = 417,
    
    // Server Errors
    ResponseStatusInternalServerError             = 500,
    ResponseStatusNotImpemented                   = 501,
    ResponseStatusBadGateway                      = 502,
    ResponseStatusServiceUnavailable              = 503,
    ResponseStatusGatewayTimeout                  = 504,
    ResponseStatusVersionNotSupported         = 505
    
} ResponseStatus;



