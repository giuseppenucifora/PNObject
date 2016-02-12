//
//  PNObjectViewController.m
//  PNObject
//
//  Created by Giuseppe Nucifora on 12/28/2015.
//  Copyright (c) 2015 Giuseppe Nucifora. All rights reserved.
//

#import "PNObjectViewController.h"
#import <PureLayout/PureLayout.h>
#import "PNObject.h"
#import "User.h"
#import "PNAddress.h"
#import "PNObject+PNObjectConnection.h"

@interface PNObjectViewController ()

@property (nonatomic) BOOL didSetupConstraints;

@property (nonatomic, strong) UIButton *refreshToken;

@property (nonatomic, strong) UIButton *apiCall;

@property (nonatomic, strong) UIButton *cancelToken;


@end

@implementation PNObjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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

    User * user = [User currentUser];

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


    /*User *user = [User currentUser];
     [user setFirstName:@"Giuseppe"];
     [user setLastName:@"Nuficora"];
     [user setEmail:@"packman@giuseppenucifora.com"];
     [user setPassword:@"asdasdasd"];
     [user setConfirmPassword:@"asdasdasd"];
     [user setHasAcceptedNewsletter:NO];
     [user setHasAcceptedPrivacy:YES];

     [user saveLocally];

     [user reloadFormServer];*/

    /*[[User currentUser] socialLoginWithBlockSuccessFromViewController:self
     blockSuccess:^(PNUser * _Nullable responseObject) {

     } failure:^(NSError * _Nonnull error) {

     }];*/

    User * user = [User currentUser];

    if ([user isAuthenticated]) {

        [user loginCurrentUserWithEmail:@"packman@giuseppenucifora.com" password:@"asdasdasd" withBlockSuccess:^(PNUser * _Nullable responseObject) {

            NSLog(@"response : %@",responseObject);
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"response : %@",error);
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
