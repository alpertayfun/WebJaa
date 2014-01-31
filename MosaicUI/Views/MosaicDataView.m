//
//  MosaicModuleView.m
//  MosaicUI
//
//  Created by Ezequiel Becerra on 10/21/12.
//  Copyright (c) 2012 betzerra. All rights reserved.
//

#import "MosaicDataView.h"
#import "MosaicView.h"
#define kMosaicDataViewDidTouchNotification @"kMosaicDataViewDidTouchNotification"
#define kMosaicDataViewFont @"Helvetica-Bold"

@implementation MosaicDataView
@synthesize mosaicView;

#pragma mark - Private

-(UIFont *)fontWithModuleSize:(NSUInteger)aSize{

    UIFont *retVal = nil;
    
    switch (aSize) {
        case 0:
            retVal = [UIFont fontWithName:kMosaicDataViewFont size:36];
            break;
        case 1:
            retVal = [UIFont fontWithName:kMosaicDataViewFont size:18];
            break;
        case 2:
            retVal = [UIFont fontWithName:kMosaicDataViewFont size:18];
            break;
        case 3:
            retVal = [UIFont fontWithName:kMosaicDataViewFont size:15];
            break;
        default:
            retVal = [UIFont fontWithName:kMosaicDataViewFont size:15];
            break;
    }
    
    return retVal;
}

-(void)mosaicViewDidTouch:(NSNotification *)aNotification{
    MosaicDataView *aView = [aNotification.userInfo objectForKey:@"mosaicDataView"];
    if (aView != self){
        //  This gets called when another MosaicDataView gets selected
    }
}

#pragma mark - Properties

-(NSString *)title{
    NSString *retVal = titleLabel.text;
    return retVal;
}

-(void)setTitle:(NSString *)title{
    titleLabel.text = title;
}

-(void)setModule:(MosaicData *)newModule{
    module = newModule;
    

    
    [self downloadingServerImageFromUrl:imageView AndUrl:self.module.imageFilename];
    
  
}

-(MosaicData *)module{
    return module;
}

-(void)displayHighlightAnimation{
    if (self.mosaicView.selectedDataView != self){
        //  Notify to the rest of MosaicDataView which is the selected MosaicDataView
        //  (Usefull is you need to deselect some MosaicDataView)
        NSDictionary *aDict = @{@"mosaicDataView" : self};
        [[NSNotificationCenter defaultCenter] postNotificationName:kMosaicDataViewDidTouchNotification
                                                            object:nil
                                                          userInfo:aDict];
        
        self.alpha = 0.3;
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 1;
                         }
                         completion:^(BOOL completed){
                             // Do nothing. This is only visual feedback.
                             // See simpleExclusiveTapRecognized instead
                         }];
    }
}

-(void)simpleTapReceived:(id)sender{
    if (self.mosaicView.delegate && [self.mosaicView.delegate respondsToSelector:@selector(mosaicViewDidTap:)]){
        [self.mosaicView.delegate mosaicViewDidTap:self];
    }
    self.mosaicView.selectedDataView = self;    
}

-(void)doubleTapReceived:(id)sender{
    if (self.mosaicView.delegate && [self.mosaicView.delegate respondsToSelector:@selector(mosaicViewDidDoubleTap:)]){
        [self.mosaicView.delegate mosaicViewDidDoubleTap:self];        
    }
}

-(void)leftTapReceived:(id)sender{
    if (self.mosaicView.delegate && [self.mosaicView.delegate respondsToSelector:@selector(mosaicViewDidLeftTap:)]){
        [self.mosaicView.delegate mosaicViewDidLeftTap:self];
    }

    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    infoText.hidden = YES;
    nextview.hidden = YES;
    imageView.hidden = NO;
    
    [[imageView layer] addAnimation:animation forKey:@"showSecondViewController"];

}

-(void)rightTapReceived:(id)sender{
    if (self.mosaicView.delegate && [self.mosaicView.delegate respondsToSelector:@selector(mosaicViewDidRightTap:)]){
        [self.mosaicView.delegate mosaicViewDidRightTap:self];


        CATransition *animation = [CATransition animation];
        [animation setDuration:0.3];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        nextview.hidden = NO;
        imageView.hidden = YES;
        infoText.hidden = NO;
        
        [[nextview layer] addAnimation:animation forKey:@"showSecondViewController"];
    }
    
    
}

#pragma mark - Public

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        //  UIImageView on background
        CGRect imageViewFrame = CGRectMake(0,0,frame.size.width,frame.size.height);
        imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        
        //  UILabel for title
        CGRect titleLabelFrame = CGRectMake(0,
                                       round(frame.size.height/2),
                                       frame.size.width,
                                       round(frame.size.height/2));
        titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:kMosaicDataViewFont size:15];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        titleLabel.numberOfLines = 1;
        [self addSubview:titleLabel];

        CGRect titleInfoFrame = CGRectMake(0,
                                            round(imageView.frame.size.height),
                                            imageView.frame.size.width,
                                            round(imageView.frame.size.height));
        infoText = [[UITextView alloc] initWithFrame:titleInfoFrame];
        infoText.textAlignment = NSTextAlignmentRight;
        infoText.backgroundColor = [UIColor clearColor];
        infoText.font = [UIFont fontWithName:kMosaicDataViewFont size:15];
        infoText.textColor = [UIColor whiteColor];
        [self addSubview:infoText];
        infoText.hidden = YES;
        
        
        //  Set stroke width
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.clipsToBounds = YES;
        
        //  Subscribe to a Notification so can unhighlight when user taps other MosaicDataViews
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mosaicViewDidTouch:)
                                                     name:kMosaicDataViewDidTouchNotification
                                                   object:nil];
        

        //  Add left swipe recognizer
        UISwipeGestureRecognizer *leftTapRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(leftTapReceived:)];
        [leftTapRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:leftTapRecognizer];
        
        
        //  Add right swipe recognizer
        UISwipeGestureRecognizer *rightTapRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(rightTapReceived:)];
        [rightTapRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:rightTapRecognizer];
        
        //  Add double tap recognizer
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(doubleTapReceived:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        //  Add simple tap recognizer. This will get call ONLY if the double tap fails, so it's got a little delay
        UITapGestureRecognizer *simpleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(simpleTapReceived:)];
        simpleTapRecognizer.numberOfTapsRequired = 1;
        [simpleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        simpleTapRecognizer.delegate = self;
        [self addGestureRecognizer:simpleTapRecognizer];
    }
    return self;
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    //  Display the animation no matter if the gesture fails or not
    BOOL retVal = YES;
    
    /*  From http://developer.apple.com NSObject class reference
     *  You cannot test whether an object inherits a method from its superclass by sending respondsToSelector:
     *  to the object using the super keyword. This method will still be testing the object as a whole, not just 
     *  the superclass’s implementation. Therefore, sending respondsToSelector: to super is equivalent to sending 
     *  it to self. Instead, you must invoke the NSObject class method instancesRespondToSelector: directly on 
     *  the object’s superclass */
    
    SEL aSel = @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:);
    
    /*  You cannot simply use [[self superclass] instancesRespondToSelector:@selector(aMethod)] 
     *  since this may cause the method to fail if it is invoked by a subclass. */
    
    if ([UIView instancesRespondToSelector:aSel]){
        retVal = [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    [self displayHighlightAnimation];
    return retVal;
}


-(void)downloadingServerImageFromUrl:(UIImageView*)imgView AndUrl:(NSString*)strUrl{
    
    NSString* theFileName = [NSString stringWithFormat:@"%@.png",[[strUrl lastPathComponent] stringByDeletingPathExtension]];
    
    
    NSFileManager *fileManager =[NSFileManager defaultManager];
    NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",theFileName]];
    
    imgView.backgroundColor = [UIColor whiteColor];
    UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imgView addSubview:actView];
    [actView startAnimating];
    CGSize boundsSize = imgView.bounds.size;
    CGRect frameToCenter = actView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    actView.frame = frameToCenter;
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSData *dataFromFile = nil;
        NSData *dataFromUrl = nil;
        
        dataFromFile = [fileManager contentsAtPath:fileName];
        if(dataFromFile==nil){
            dataFromUrl = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strUrl]];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if(dataFromFile!=nil){
                imgView.image = [UIImage imageWithData:dataFromFile];
                
                UIImage *anImage = [UIImage imageWithData:dataFromFile];
                imageView.image = anImage;
                
                CGSize imgFinalSize = CGSizeZero;
                
                if (anImage.size.width < anImage.size.height){
                    imgFinalSize.width = self.bounds.size.width;
                    imgFinalSize.height = self.bounds.size.width * anImage.size.height / anImage.size.width;
                    
                    //  This is to avoid black bars on the bottom and top of the image
                    //  Happens when images have its height lesser than its bounds
                    if (imgFinalSize.height < self.bounds.size.height){
                        imgFinalSize.width = self.bounds.size.height * self.bounds.size.width / imgFinalSize.height;
                        imgFinalSize.height = self.bounds.size.height;
                    }
                }else{
                    imgFinalSize.height = self.bounds.size.height;
                    imgFinalSize.width = self.bounds.size.height * anImage.size.width / anImage.size.height;
                    
                    //  This is to avoid black bars on the left and right of the image
                    //  Happens when images have its width lesser than its bounds
                    if (imgFinalSize.width < self.bounds.size.width){
                        imgFinalSize.height = self.bounds.size.height * self.bounds.size.width / imgFinalSize.height;
                        imgFinalSize.width = self.bounds.size.width;
                    }
                }
                
                //    NSLog(@"#DEBUG imageRect %.2f %.2f (%.2f %.2f) %@", imgFinalSize.width, imgFinalSize.height, anImage.size.width, anImage.size.height, newModule);
                
                imageView.frame = CGRectMake(0, 0, imgFinalSize.width, imgFinalSize.height);
                imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                
                //  Set new title
                NSInteger marginLeft = self.frame.size.width / 20;
                NSInteger marginBottom = self.frame.size.height / 20;
                
                titleLabel.text = module.title;
                titleLabel.font = [self fontWithModuleSize:module.size];
                infoText.text = module.information;
                
                CGSize newSize = [module.title sizeWithFont:titleLabel.font constrainedToSize:titleLabel.frame.size];
                CGRect newRect = CGRectMake(marginLeft,
                                            self.frame.size.height - newSize.height - marginBottom,
                                            newSize.width,
                                            newSize.height);
                titleLabel.frame = newRect;
            }else if(dataFromUrl!=nil){
                imgView.image = [UIImage imageWithData:dataFromUrl];
                NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@",theFileName]];
                
                BOOL filecreationSuccess = [fileManager createFileAtPath:fileName contents:dataFromUrl attributes:nil];
                if(filecreationSuccess == NO){
                    NSLog(@"Failed to create the html file");
                }
                
                
                
                UIImage *anImage = [UIImage imageWithData:dataFromUrl];
                imageView.image = anImage;
                
                CGSize imgFinalSize = CGSizeZero;
                
                if (anImage.size.width < anImage.size.height){
                    imgFinalSize.width = self.bounds.size.width;
                    imgFinalSize.height = self.bounds.size.width * anImage.size.height / anImage.size.width;
                    
                    //  This is to avoid black bars on the bottom and top of the image
                    //  Happens when images have its height lesser than its bounds
                    if (imgFinalSize.height < self.bounds.size.height){
                        imgFinalSize.width = self.bounds.size.height * self.bounds.size.width / imgFinalSize.height;
                        imgFinalSize.height = self.bounds.size.height;
                    }
                }else{
                    imgFinalSize.height = self.bounds.size.height;
                    imgFinalSize.width = self.bounds.size.height * anImage.size.width / anImage.size.height;
                    
                    //  This is to avoid black bars on the left and right of the image
                    //  Happens when images have its width lesser than its bounds
                    if (imgFinalSize.width < self.bounds.size.width){
                        imgFinalSize.height = self.bounds.size.height * self.bounds.size.width / imgFinalSize.height;
                        imgFinalSize.width = self.bounds.size.width;
                    }
                }
                
                //    NSLog(@"#DEBUG imageRect %.2f %.2f (%.2f %.2f) %@", imgFinalSize.width, imgFinalSize.height, anImage.size.width, anImage.size.height, newModule);
                
                imageView.frame = CGRectMake(0, 0, imgFinalSize.width, imgFinalSize.height);
                imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                
                //  Set new title
                NSInteger marginLeft = self.frame.size.width / 20;
                NSInteger marginBottom = self.frame.size.height / 20;
                
                titleLabel.text = module.title;
                titleLabel.font = [self fontWithModuleSize:module.size];
                infoText.text = module.information;
                
                CGSize newSize = [module.title sizeWithFont:titleLabel.font constrainedToSize:titleLabel.frame.size];
                CGRect newRect = CGRectMake(marginLeft,
                                            self.frame.size.height - newSize.height - marginBottom,
                                            newSize.width,
                                            newSize.height);
                titleLabel.frame = newRect;
                
            }else{
                imgView.image = [UIImage imageNamed:@"not_found.png"];
                
                
                
                UIImage *anImage = [UIImage imageNamed:@"not_found.png"];
                imageView.image = anImage;
                
                CGSize imgFinalSize = CGSizeZero;
                
                if (anImage.size.width < anImage.size.height){
                    imgFinalSize.width = self.bounds.size.width;
                    imgFinalSize.height = self.bounds.size.width * anImage.size.height / anImage.size.width;
                    
                    //  This is to avoid black bars on the bottom and top of the image
                    //  Happens when images have its height lesser than its bounds
                    if (imgFinalSize.height < self.bounds.size.height){
                        imgFinalSize.width = self.bounds.size.height * self.bounds.size.width / imgFinalSize.height;
                        imgFinalSize.height = self.bounds.size.height;
                    }
                }else{
                    imgFinalSize.height = self.bounds.size.height;
                    imgFinalSize.width = self.bounds.size.height * anImage.size.width / anImage.size.height;
                    
                    //  This is to avoid black bars on the left and right of the image
                    //  Happens when images have its width lesser than its bounds
                    if (imgFinalSize.width < self.bounds.size.width){
                        imgFinalSize.height = self.bounds.size.height * self.bounds.size.width / imgFinalSize.height;
                        imgFinalSize.width = self.bounds.size.width;
                    }
                }
                
                //    NSLog(@"#DEBUG imageRect %.2f %.2f (%.2f %.2f) %@", imgFinalSize.width, imgFinalSize.height, anImage.size.width, anImage.size.height, newModule);
                
                imageView.frame = CGRectMake(0, 0, imgFinalSize.width, imgFinalSize.height);
                imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                
                //  Set new title
                NSInteger marginLeft = self.frame.size.width / 20;
                NSInteger marginBottom = self.frame.size.height / 20;
                
                titleLabel.text = module.title;
                titleLabel.font = [self fontWithModuleSize:module.size];
                infoText.text = module.information;
                
                CGSize newSize = [module.title sizeWithFont:titleLabel.font constrainedToSize:titleLabel.frame.size];
                CGRect newRect = CGRectMake(marginLeft,
                                            self.frame.size.height - newSize.height - marginBottom,
                                            newSize.width,
                                            newSize.height);
                titleLabel.frame = newRect;
            }
            [actView removeFromSuperview];
            [imgView setBackgroundColor:[UIColor clearColor]];
        });
    });

}

@end
