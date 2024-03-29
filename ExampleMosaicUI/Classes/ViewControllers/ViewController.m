//
//  ViewController.m
//  MosaicUI
//
//  Created by Ezequiel Becerra on 10/21/12.
//  Copyright (c) 2012 betzerra. All rights reserved.
//

#import "ViewController.h"
#import "MosaicData.h"
#import "MosaicDataView.h"
#import "CustomMosaicDatasource.h"

@implementation ViewController

#pragma mark - Private

static UIImageView *captureSnapshotOfView(UIView *targetView){
    UIImageView *retVal = nil;
    
    UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, YES, 0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [[targetView layer] renderInContext:currentContext];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    retVal = [[UIImageView alloc] initWithImage:image];
    retVal.frame = [targetView frame];
    
    return retVal;
}

#pragma mark - Public

- (void)viewDidLayoutSubviews{
}

- (void)viewDidLoad{
    [super viewDidLoad];
    mosaicView.datasource = [CustomMosaicDatasource sharedInstance];
    mosaicView.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.topItem.title = @"Webjaas Feed";
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    snapshotBeforeRotation = captureSnapshotOfView(mosaicView);
    [self.view insertSubview:snapshotBeforeRotation aboveSubview:mosaicView];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    snapshotAfterRotation = captureSnapshotOfView(mosaicView);
    
    snapshotBeforeRotation.alpha = 0.0;
    [self.view insertSubview:snapshotAfterRotation belowSubview:snapshotBeforeRotation];
    mosaicView.hidden = YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [snapshotBeforeRotation removeFromSuperview];
    [snapshotAfterRotation removeFromSuperview];
    snapshotBeforeRotation = nil;
    snapshotAfterRotation = nil;
    mosaicView.hidden = NO;
}


#pragma mark - MosaicViewDelegateProtocol

-(void)mosaicViewDidTap:(MosaicDataView *)aModule{
    NSLog(@"Tapped %@", aModule.module.web);
}

-(void)mosaicViewDidDoubleTap:(MosaicDataView *)aModule{
    NSLog(@"Double Tapped %@", aModule.module.web);
}

-(void)mosaicViewDidLeftTap:(MosaicDataView *)aModule{
    NSLog(@"Left Swipe %@", aModule.module.web);
}

-(void)mosaicViewDidRightTap:(MosaicDataView *)aModule{
    NSLog(@"Right Swipe %@", aModule.module.web);
}

@end
