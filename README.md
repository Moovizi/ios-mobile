<p align="center">
	<!-- METTRE LE LOGO MOOVIZI -->
</p>

# The project

Selected for the final Hack4France held July 8, 2014 at the Ministry of Economy, Recovery and Productive Digital. We finished in 3rd place.<br/>
Moovizi is a collaborative application for route calculation and navigation aids for disabled persons. Our vision is to offer the best route, calculated or recalculated, taking into account the obstacles and the specifics of your disability. We also reference points of interests accessible to persons with reduced mobility.
<p align="center">
  <img height="300px" src="https://github.com/Moovizi/Moovizi-iOS/raw/master/ScreenShots/home_moovizi.jpg" alt="Her" />
  <img height="300px" src="https://github.com/Moovizi/Moovizi-iOS/raw/master/ScreenShots/journey.png" alt="Her" />
</p>

### Obstacles

Ostacles declaration : TODO

<!-- <p align="center">
  <img src="https://github.com/m2omou/easyway/raw/master/Images/screen2.png" alt="Her" />
</p> -->

# How to collaborate with us 

First, checkout the repository
```
git clone https://github.com/Moovizi/Moovizi-iOS.git
```
Then, switch branch to be on the `development` branch
```
git checkout development
```

The repository is ready, now you need to install the pods on your xcode projet with Cocoapods command :
```
pod install
```
If you don't have Cocoapods, how to install it : <a href="http://cocoapods.org/">Link</a>

To launch the project, you just need to launch `Moovizi.xcworkspace`. You will notice that there warning because the Constants.h is missing. We use couple API for this projects, so you need to create a Constants.h and Constants.m that you add on `Moovizi/Sources`. 
You need to add those API Keys :
- Google Map (Request API Key on Google API console <a href="https://code.google.com/apis/console">Link</a>)
- Google Places (Request API Key on Google API console <a href="https://code.google.com/apis/console">Link</a>)
- Navitia (CANALTP) (Request API Key on Navitia Sign Up Page : <a href="http://auth.navitia.io/">Link</a>)

Example for Constants.h and Constants.m :
##### Constants.h
```
//
//  Constants.h
//  Moovizi
//
//  Created by Tchikovani on 13/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

FOUNDATION_EXPORT NSString *const kGOOGLE_MAP_API_KEY;
FOUNDATION_EXPORT NSString *const kGOOGLE_PLACES_API_KEY;
FOUNDATION_EXPORT NSString *const kNAVITIA_API_KEY;
```
##### Constants.m
```
//
//  Constants.m
//  Moovizi
//
//  Created by Tchikovani on 13/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const kGOOGLE_MAP_API_KEY = @"Your-API-Key";
NSString *const kGOOGLE_PLACES_API_KEY =  @"Your-API-Key";
NSString *const kNAVITIA_API_KEY =  @"Your-API-Key";
```

# APIs

<p align="center">
  <img height="50px" src="https://github.com/Moovizi/Moovizi-iOS/raw/master/ScreenShots/CanalTP.png" alt="Her" />
  <img height="50px" src="https://github.com/Moovizi/Moovizi-iOS/raw/master/ScreenShots/Google-Places.png" alt="Her" />
</p>

# Links

- Hackathon official website : http://www.hack4france.fr/
- Hackathon previous repository : https://github.com/m2omou/easyway
