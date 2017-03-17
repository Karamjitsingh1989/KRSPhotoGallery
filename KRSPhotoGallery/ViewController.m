//
//  ViewController.m
//  KRSPhotoGallery
//
//  Created by Deepak Bhagat on 3/8/17.
//  Copyright © 2017 Karam. All rights reserved.
//

#import "ViewController.h"
#import "KRSPhotoGalleryVC.h"
@interface ViewController ()
{

    CGFloat SCREEN_WIDTH;

}
@end

@implementation ViewController

- (void)viewDidLoad {
    
    
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self.imageManager stopCachingImagesForAllAssets];
    SCREEN_WIDTH = self.view.frame.size.width;
    self.navigationController.navigationBarHidden=YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- collection view delegate and data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.selectedPhotosArr count];;
    
    // return photosArr.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell*cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ShowPhotoCell" forIndexPath:indexPath];
    UIImageView *imageView=(UIImageView *)[cell viewWithTag:1];
    PHAsset *asset = self.selectedPhotosArr[indexPath.item];
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(SCREEN_WIDTH-20, SCREEN_WIDTH-20)
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                  [imageView setImage:result];
                              }
     ];
    
    UILabel *createdDate=(UILabel *)[cell viewWithTag:2];
    createdDate.text=[self DateStringForDisplay:asset.creationDate];
    
    return cell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH-20, SCREEN_WIDTH-20);
}
-(void)func_selectedPhotos:(NSArray *)photos{

    _lblDescription.hidden=YES;
    self.selectedPhotosArr=photos;
    [_CollectionView reloadData];
}
-(NSString *)DateStringForDisplay:(NSDate*)date{

    NSDateFormatter*dateFormatter1 = [[NSDateFormatter alloc] init];
    dateFormatter1.dateFormat = @"EEEE, d MMM - HH:mm";
    
    NSString *strDate= [dateFormatter1 stringFromDate:date];
    return [strDate stringByReplacingOccurrencesOfString:@"-" withString:@"at"];
    
}


#pragma mark-check camera permissions
-(BOOL)checkCameraPermissionsForCamera :(BOOL)camera{
    if (camera) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusNotDetermined) {
            
            return YES;
        } else if (status == AVAuthorizationStatusAuthorized) {
            // User code
            return YES;
            
        } else if (status == AVAuthorizationStatusRestricted) {
            // User code
            [self showNoAccessAlert];
            return NO;
        } else if (status == AVAuthorizationStatusDenied) {
            // User code
            [self showNoAccessAlert];
            return NO;
        }
        else
            return NO;
    }
    
    else{
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        if(status == PHAuthorizationStatusNotDetermined) {
            // Request photo authorization
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                // User code (show imagepicker)
            }];
            return NO;
        } else if (status == PHAuthorizationStatusAuthorized) {
            // User code
            return YES;
            
        } else if (status == PHAuthorizationStatusRestricted) {
            // User code
            [self showNoAccessAlert];
            return NO;
        } else if (status == PHAuthorizationStatusDenied) {
            // User code
            [self showNoAccessAlert];
            return NO;
        }
        else
            return NO;
    }
}
-(void)showNoAccessAlert{
    UIAlertController*ac=[UIAlertController alertControllerWithTitle:@"Error" message:@"The app does'nt have access to your photos or videos. Please enable from settings." preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}
- (IBAction)AddPhotoAction:(id)sender {
    
    
    if ([self checkCameraPermissionsForCamera:NO]) {
    KRSPhotoGalleryVC *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"KRSPhotoGalleryVC"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    
}


@end
