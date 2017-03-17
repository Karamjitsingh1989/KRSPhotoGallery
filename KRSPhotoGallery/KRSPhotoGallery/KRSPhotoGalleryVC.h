//
//  KRSPhotoGalleryVC.h

//
//

#import <UIKit/UIKit.h>

@interface KRSPhotoGalleryVC : UIViewController
@property NSInteger photoCount;
@property(nonatomic,retain)NSArray* selectedImageArr;
@property (weak, nonatomic) IBOutlet UITableView *tblAlbum;
- (IBAction)SelectBackController:(id)sender;

@end
