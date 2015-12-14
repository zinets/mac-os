//
//  ViewController.m
//  OfflineVideo
//
//  Created by Victor Zinetz on 10.10.12.
//  Copyright (c) 2012 Victor Zinetz. All rights reserved.
//

#import "ViewController.h"
#import "ImgDecoder.h"

typedef enum {
    stateStopped,
    statePaused,
    statePlaying,
    stateStepped,
} PlayerState;

@interface ViewController () {
    UIPopoverController * popover;
    NSString * _movieFile;
    PlayerState _playerState;
    ImageDecoder * imgDecoder;
    int _position;
}

@property (retain) NSString * movieFile;
@property (assign) NSInteger position;
@property (assign) PlayerState playerState;

// interface
-(void)setPanelVisibility:(BOOL)visible;
-(void)setTiltVisibility:(BOOL)visible;
-(void)setControlsEnable:(BOOL)enable;

// docs
- (NSMutableArray *)docList;

@end


#pragma mark - ViewController implementation

@implementation ViewController

@synthesize idFrame;
@synthesize idTiltView;
@synthesize idPrevButton;
@synthesize idNextButton;
@synthesize idPlayButton;
@synthesize idFolderButton;
@synthesize idPosition;

#pragma mark - ViewController setters/getters

-(NSInteger)position {
    return _position;
}

-(void)setPosition:(NSInteger)position {
    if (_position == position)
        return;
    if (position < 0)
        return;
    if (position >= [imgDecoder count])
        return;
    
    _position = position;
    idPosition.value = position;
    idFrame.image = [imgDecoder imageForIndex:position];
}

-(void)setMovieFile:(NSString *)movieFile {
    if ([movieFile isEqualToString:_movieFile])
        return;
    
    NSString * tmp = [movieFile retain];
    [_movieFile release];
    _movieFile = tmp;
    [imgDecoder release];
    
    if (tmp && [[NSFileManager defaultManager] fileExistsAtPath:tmp]) {
        imgDecoder = [[ImageDecoder alloc] initWithFilename:_movieFile];
        idPosition.maximumValue = [imgDecoder count] - 1;
        
        idFrame.image = [imgDecoder imageForIndex:0];
        self.playerState = statePaused;
    } else {
        idFrame.image = [UIImage imageNamed:@"placeholder"];
        idPosition.maximumValue = 0;
        
        self.playerState = stateStopped;
    }
}

-(NSString *)movieFile {
    return _movieFile;
}

-(PlayerState)playerState {
    return _playerState;
}

-(void)setPlayerState:(PlayerState)playerState {
    if (_playerState == playerState && playerState != stateStopped)
        return;
    
    _playerState = playerState;
    
    switch (_playerState) {
        case stateStopped:
            [self setControlsEnable:NO];
            [self setPanelVisibility:YES];
            [self setTiltVisibility:YES];
            break;
        case statePaused:
            [self setTiltVisibility:YES];
            [self setPanelVisibility:YES];
            [self setControlsEnable:YES];
            break;
        case stateStepped:
            [self setTiltVisibility:NO];
            [self setPanelVisibility:YES];
            [self setControlsEnable:YES];
            break;
        case statePlaying:
            [self setTiltVisibility:NO];
            [self setPanelVisibility:NO];
            [self setControlsEnable:YES];
            break;
        default:
            break;
    }
}

#pragma mark - ViewController overrides etc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // gestures setup
    UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onPlayerTapped:)];
    [idFrame addGestureRecognizer:gr];
    [gr release];
    
    self.playerState = stateStopped;
    
    // prefs setup
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * lastMovie = [prefs stringForKey:@"lastMovie"];
    NSInteger lastPos = [prefs integerForKey:@"lastPos"];
    self.movieFile = lastMovie;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)dealloc {
    [imgDecoder release];
    
    [idFrame release];
    [idTiltView release];
    [idPrevButton release];
    [idNextButton release];
    [idPlayButton release];
    [idFolderButton release];
    [idPosition release];
    [super dealloc];
}

#ifdef DEBUG
- (IBAction)onTestClick1:(id)sender {
    [self setPanelVisibility:NO];
}

- (IBAction)onTestClick2:(id)sender {
    [self setPanelVisibility:YES];
}
#endif

#pragma mark -


-(void)setTiltVisibility:(BOOL)visible {
    float a = visible ? 0.4 : 0.0;
    if (idTiltView.alpha == a)
        return;
    
    [UIView beginAnimations:nil context:nil];
    idTiltView.alpha = a;
    [UIView commitAnimations];
}

-(void)setPanelVisibility:(BOOL)visible {
    float a = visible ? 1.0 : 0.0;
    if (idPlayButton.alpha == a) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    idPrevButton.alpha = a;
    idPlayButton.alpha = a;
    idNextButton.alpha = a;
    idFolderButton.alpha = a;
    idPosition.alpha = a;
    
    [UIView commitAnimations];
}

-(void)setControlsEnable:(BOOL)enable {
    idPrevButton.enabled = enable;
    idNextButton.enabled = enable;
    idPlayButton.enabled = enable;
    idPosition.enabled = enable;
}

- (IBAction)onPositionChanged:(id)sender {
    int pos = idPosition.value;
    self.position = pos;
}

- (void)docItemTapped:(NSString*)docName {
    self.movieFile = docName;
    
    [popover dismissPopoverAnimated:YES];
}

- (IBAction)onFolderButtonTapped:(id)sender {
    DocListViewController * docCtrl = [[[DocListViewController alloc] initWithList:[self docList]] autorelease];
    docCtrl.delegate = self;
    if (!popover) {
        popover = [[UIPopoverController alloc] initWithContentViewController:docCtrl];
        popover.popoverContentSize = docCtrl.view.frame.size;
        popover.delegate = self;
    }
    
    [popover presentPopoverFromRect:[sender frame]
                             inView:self.view
           permittedArrowDirections:UIPopoverArrowDirectionDown
                           animated:YES];
}

- (IBAction)onPrevButtonTapped:(id)sender {
    self.position = self.position - 1;
    self.playerState = stateStepped;
}

- (IBAction)onNextButtonTapped:(id)sender {
    self.position = self.position + 1;
    self.playerState = stateStepped;
}

- (IBAction)onPlayButtonTapped:(id)sender {
    
    self.playerState = statePlaying;
}

- (IBAction)onPlayerTapped:(id)sender {
    if (self.playerState != statePlaying)
        return;
    
    self.playerState = statePaused;
}

- (NSMutableArray *)docList {
    
    NSMutableArray *retval = [NSMutableArray array];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *publicDocumentsDir = [paths objectAtIndex:0];
    
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return retval;
    }
    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"flm" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fullPath = [publicDocumentsDir stringByAppendingPathComponent:file];
            [retval addObject:fullPath];
        }
    }
    
    return retval;    
}

@end
