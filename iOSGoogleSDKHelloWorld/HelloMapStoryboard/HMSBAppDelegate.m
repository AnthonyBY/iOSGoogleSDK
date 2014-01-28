#import "HMSBAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation HMSBAppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  // Add in your API key here:
  [GMSServices provideAPIKey:@"AIzaSyAqtL_ajwbV3REjpvqHyqbj_LWoUswgp4k"];
  return YES;
}

@end
