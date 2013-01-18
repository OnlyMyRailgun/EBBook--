

#import <UIKit/UIKit.h>


@interface SMSCustomCell : UITableViewCell {
	UILabel    *nameLabel;
	UILabel    *dateLabel;
	UILabel    *contentLabel;
}
@property (nonatomic, retain) IBOutlet UILabel    *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel    *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel    *contentLabel;
@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;
- (void)initializeImageView;
@end
