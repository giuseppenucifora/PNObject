//
//  PNObjViewController.m
//  PNObject
//
//  Created by Giuseppe Nucifora on 12/28/2016.
//  Copyright (c) 2016 Giuseppe Nucifora. All rights reserved.
//

#import "PNObjViewController.h"
#import <PNObject/PNObject.h>
#import <PNObject/PNUser.h>
#import <PNObject/PNAddress.h>
#import <PNObject/PNObject+PNObjectConnection.h>
#import <PureLayout/PureLayout.h>

@interface PNObjViewController ()

@property (nonatomic) BOOL didSetupConstraints;

@property (nonatomic, strong) UIButton *refreshToken;

@property (nonatomic, strong) UIButton *apiCall;

@property (nonatomic, strong) UIButton *cancelToken;

@end

@implementation PNObjViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _refreshToken = [UIButton newAutoLayoutView];
    [_refreshToken addTarget:self action:@selector(refreshTokenAction) forControlEvents:UIControlEventTouchUpInside];
    [_refreshToken setTitle:@"Refresh Token" forState:UIControlStateNormal];
    [_refreshToken setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_refreshToken.layer setBorderColor:[UIColor blackColor].CGColor];
    [_refreshToken.layer setCornerRadius:4];
    [_refreshToken.layer setBorderWidth:2];
    
    [self.view addSubview:_refreshToken];
    
    _apiCall = [UIButton newAutoLayoutView];
    [_apiCall addTarget:self action:@selector(apiCallAction) forControlEvents:UIControlEventTouchUpInside];
    [_apiCall setTitle:@"API Call" forState:UIControlStateNormal];
    [_apiCall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_apiCall.layer setBorderColor:[UIColor blackColor].CGColor];
    [_apiCall.layer setCornerRadius:4];
    [_apiCall.layer setBorderWidth:2];
    
    [self.view addSubview:_apiCall];
    
    _cancelToken = [UIButton newAutoLayoutView];
    [_cancelToken addTarget:self action:@selector(cancelTokenAction) forControlEvents:UIControlEventTouchUpInside];
    [_cancelToken setTitle:@"Reset Token" forState:UIControlStateNormal];
    [_cancelToken setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cancelToken.layer setBorderColor:[UIColor blackColor].CGColor];
    [_cancelToken.layer setCornerRadius:4];
    [_cancelToken.layer setBorderWidth:2];
    
    [self.view addSubview:_cancelToken];
    
    //User * user = [User currentUser];
    
    [self.view setNeedsUpdateConstraints];
}

- (void) updateViewConstraints {
    if (!_didSetupConstraints) {
        
        _didSetupConstraints = YES;
        
        [self.view autoPinEdgesToSuperviewEdges];
        
        [_refreshToken autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_refreshToken autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_refreshToken autoSetDimension:ALDimensionWidth toSize:140];
        [_refreshToken autoSetDimension:ALDimensionHeight toSize:44];
        
        [_apiCall autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_refreshToken withOffset:-35];
        [_apiCall autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_apiCall autoSetDimension:ALDimensionWidth toSize:140];
        [_apiCall autoSetDimension:ALDimensionHeight toSize:44];
        
        [_cancelToken autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [_cancelToken autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_refreshToken withOffset:35];
        [_cancelToken autoSetDimension:ALDimensionWidth toSize:140];
        [_cancelToken autoSetDimension:ALDimensionHeight toSize:44];
    }
    [super updateViewConstraints];
}

- (void) refreshTokenAction {
    [[PNObjectConfig sharedInstance] refreshTokenForClientCredential];
}

- (void) cancelTokenAction {
    [[PNObjectConfig sharedInstance] resetToken];
}

- (void) apiCallAction {
    
    PNObjcPassword *password = [PNObjcPassword new];
    [password setPassword:@"asdasdasd"];
    [password setConfirmPassword:@"asdasdasd"];
    
    PNUser *user = [PNUser new];
    [user setFirstName:@"Test"];
    [user setLastName:@"Test"];
    [user setEmail:@"pnobject@pnobject.com"];
    [user setPassword:password];
    [user setHasAcceptedNewsletter:YES];
    [user setHasAcceptedPrivacy:YES];
    
    [user saveLocally];
    
    NSLogDebug(@"%@",[[PNUser currentUser] JSONFormObject]);
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
