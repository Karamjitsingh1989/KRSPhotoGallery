//
//  ViewController.h
//  KRSPhotoGallery
//
//  Created by Deepak Bhagat on 3/8/17.
//  Copyright © 2017 Karam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoGalleryVC.h"
@import Photos;
@interface ViewController : UIViewController<PhotoGalleryDelegate>
@property (strong) PHCachingImageManager *imageManager;
@property(nonatomic,retain)NSArray *selectedPhotosArr;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionView;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@end

