//
//  KRSPhotoGalleryVC.h

//
//

#import <UIKit/UIKit.h>

@interface KRSPhotoGalleryVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblAlbum;
- (IBAction)SelectBackController:(id)sender;
@property NSInteger photoCount;
@property(nonatomic,retain)NSArray* selectedImageArr;
@end
