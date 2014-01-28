#import "HMSBViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "AFNetworking.h"

//Add protocol GMSMapViewDelegeate for works with Google Maps events
//see: https://developers.google.com/maps/documentation/ios/map

@interface HMSBViewController () <GMSMapViewDelegate>

//Parse the following data from JSON:
@property (nonatomic, retain) NSMutableData *jsonData;
@property (nonatomic, retain) NSMutableArray *latitude;
@property (nonatomic, retain) NSMutableArray *longitude;
@property (nonatomic, retain) NSMutableArray *name;
@property (nonatomic, retain) NSMutableArray *opening_hours_mon_fri;
@property (nonatomic, retain) NSMutableArray *opening_hours_sat;
@property (nonatomic, retain) NSMutableArray *opening_hours_sun;
@property (nonatomic, retain) NSMutableArray *street;
@property (nonatomic, retain) NSMutableArray *house_number;
@property (nonatomic, retain) NSMutableArray *remarks;
@end

@implementation HMSBViewController


- (void)viewDidLoad {
  [super viewDidLoad];
    
   
    //Parse the JSON data from the http://Pampuni.com to list of NSMutableArray (property)
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://pampuni.com/guideadmin/location/search?category=Breakfast" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON %@", responseObject);
        
        //Parse data to the properties
        
        self.latitude = [responseObject valueForKeyPath:@"location.latitude"];
        self.longitude = [responseObject valueForKeyPath:@"location.longitude"];
        self.name = [responseObject valueForKeyPath:@"location.name"];
        self.street = [responseObject valueForKeyPath:@"location.street"];
        self.opening_hours_mon_fri = [responseObject valueForKeyPath:@"location.opening_hours_mon_fri"];
        self.opening_hours_sat = [responseObject valueForKeyPath:@"location.opening_hours_sat"];
        self.opening_hours_sun = [responseObject valueForKeyPath:@"location.opening_hours_sun"];
        self.house_number = [responseObject valueForKeyPath:@"location.house_number"];
        self.remarks = [responseObject valueForKeyPath:@"location.remarks"];
        
        //Draw just parsed information
        [self drawMarkers];
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void) drawMarkers
{
    // Create a GMSCameraPosition that tells the map to display
    // the first coordinate from JSON at zoom level 14
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[self.latitude objectAtIndex:0] doubleValue]
                                                            longitude:[[self.longitude objectAtIndex:0] doubleValue]
                                                                 zoom:14];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;
    self.view = self.mapView;
    
    //Add Markers to the Google Map
    for (int i = 0; i < [self.name count]; i++)
    {
        GMSMarker *marker = [[GMSMarker alloc] init];
        
        double latitude = [[self.latitude objectAtIndex:i] doubleValue];
        double longtidue = [[self.longitude objectAtIndex:i] doubleValue];
        marker.position = CLLocationCoordinate2DMake(latitude, longtidue);
        marker.title = [self.name objectAtIndex:i];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        NSLog(@"log is %@", [self.house_number objectAtIndex:i]);
        
        //Format snippet for the Marker (Street, House Humber, Working Hours)
        //If Remark is empty set value "emtpy" insted of ""
        NSString *snippet = [NSString stringWithFormat:@"Street: %@, House Number: %@, opening hours Mon_fri: %@, Satarday: %@, Sunday: %@, Remark: %@ \n _CLICK ON INFO once again to get polyline from current location", [self.street objectAtIndex:i], [self.house_number objectAtIndex:i], [self.opening_hours_mon_fri objectAtIndex:i], [self.opening_hours_sat objectAtIndex:i], [self.opening_hours_sun objectAtIndex:i], ![[self.remarks objectAtIndex:i] isEqualToString:@""] ? [self.remarks objectAtIndex:i] : @"empty"];
        marker.snippet = snippet;
        //snippet why it's not possible to add link http://stackoverflow.com/questions/17705549/how-to-put-a-link-in-a-google-map-markers-snippet
        marker.map = self.mapView;
    }
}

//Option method from GSMMapViewDelegate protocol
//Did Tap at Marker
- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    NSLog(@"You tapped at %f,%f", marker.position.latitude, marker.position.longitude);
 
    GMSMutablePath *path = [GMSMutablePath path];
    
    double myCurrentLatitude = self.mapView.myLocation.coordinate.latitude;
    double myCurrentLongitude = self.mapView.myLocation.coordinate.longitude;
    [path addLatitude:myCurrentLatitude longitude:myCurrentLongitude]; // Marker 1
    [path addLatitude:marker.position.latitude longitude:marker.position.longitude]; // Path to current location
    
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = [UIColor blueColor];
    polyline.strokeWidth = 5.f;
    polyline.map = self.mapView;

}

@end
