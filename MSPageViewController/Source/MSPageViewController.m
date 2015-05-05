//
//  MSPageViewController.m
//  MSPageViewController
//
//  Created by Nacho Soto on 2/16/14.
//  Copyright (c) 2014 MindSnacks. All rights reserved.
//

#import "MSPageViewController.h"
#import "MSPageViewController+Protected.h"

@interface MSPageViewController ()

@property (nonatomic) NSInteger pageIndex;

@end

@implementation MSPageViewController

@synthesize showingPageIndicator = _showingPageIndicator;

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary *)options {
    if ((self = [super initWithTransitionStyle:style
                         navigationOrientation:navigationOrientation
                                       options:options])) {
        [self ms_setUp];
      
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self ms_setUp];
    }
    
    return self;
}

#pragma mark - Protected

- (void)ms_setUp {
  self.dataSource = self;
}

- (NSArray *)pageIdentifiers {
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}

- (NSInteger)pageCount {
    return (NSInteger)self.pageIdentifiers.count;
}

- (void)setUpViewController:(UIViewController<MSPageViewControllerChild> *)viewController
                    atIndex:(NSInteger)index {
  _pageIndex = index;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.pageCount > 0, @"%@ has no pages", self);
    
    [self setViewControllers:@[[self viewControllerAtIndex:0]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    
    if (self.pageCount == 1) {
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - swip scrolling enable

- (void)swipScrollEnable:(BOOL)enable
{
  for (UIScrollView *view in self.view.subviews) {
    if ([view isKindOfClass:[UIScrollView class]]) {
      view.scrollEnabled = enable;
    }
  }
}

#pragma mark - page actions

- (void)nextPage
{
  [self setViewControllers:@[[self viewControllerAtIndex:_pageIndex+1]]
                 direction:UIPageViewControllerNavigationDirectionForward
                  animated:YES
                completion:nil];
  
}

- (void)prevPage
{
  [self setViewControllers:@[[self viewControllerAtIndex:_pageIndex-1]]
                 direction:UIPageViewControllerNavigationDirectionReverse
                  animated:YES
                completion:nil];
  
}

- (void)gotoPage:(NSInteger)pageIndex
{
  [self setViewControllers:@[[self viewControllerAtIndex:pageIndex]]
                 direction:UIPageViewControllerNavigationDirectionForward
                  animated:YES
                completion:nil];
  
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController<MSPageViewControllerChild> *)viewController {
    const NSInteger index = viewController.pageIndex;
    
    return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController<MSPageViewControllerChild> *)viewController {
    const NSInteger index = viewController.pageIndex;
    
    return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index + 1];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    UIViewController<MSPageViewControllerChild> *result = nil;
    
    if (index >= 0 && index < self.pageCount) {
        NSAssert(self.storyboard,
                 @"This controller is only meant to be used inside of a UIStoryboard");
        
        result = [self.storyboard instantiateViewControllerWithIdentifier:self.pageIdentifiers[(NSUInteger)index]];
        
        NSParameterAssert(result);
        NSAssert([result conformsToProtocol:@protocol(MSPageViewControllerChild)],
                 @"Child view controller (%@) must conform to %@",
                 result,
                 NSStringFromProtocol(@protocol(MSPageViewControllerChild)));
        
        result.pageIndex = index;
        
        [self setUpViewController:result
                          atIndex:index];
    }
    
    return result;
}

- (NSInteger)presentationCountForPageViewController:(MSPageViewController *)pageViewController {
    if (!_showingPageIndicator)
      return 0;
  
    const BOOL shouldShowPageControl = (pageViewController.pageCount > 1);
    
    return (shouldShowPageControl) ? pageViewController.pageCount : 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
  if (!_showingPageIndicator)
    return 0;

  return [pageViewController.viewControllers.lastObject pageIndex];
}

@end
