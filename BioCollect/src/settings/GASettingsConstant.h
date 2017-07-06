//
//  GASettingsConstant.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#ifndef GASettingsConstant.h
#define GASettingsConstant.h
#define DEFAULT_TIMEOUT 10

//#define REST_SERVER @"https://fieldcapture.ala.org.au"
//#define ECODATA_SERVER @"https://ecodata.ala.org.au"
//#define BIOCOLLECT_SERVER @"https://biocollect.ala.org.au"
#define REST_SERVER @"https://fieldcapture.ala.org.au"
#define ECODATA_SERVER @"https://ecodata-test.ala.org.au"
#define BIOCOLLECT_SERVER @"https://biocollect-test.ala.org.au"

//#define ECODATA_SERVER @"http://localhost:8080/ecodata"
//#define BIOCOLLECT_SERVER @"http://localhost:8087/biocollect"

#define LIST_PROJECT_ACTIVITIES @"/ws/survey/list"
#define AUTOCOMPLETE_URL @"http://bie.ala.org.au/ws/search.json?q="
#define AUTH_SERVER  @"https://auth.ala.org.au"
#define AUTH_REGISTER @"/userdetails/registration/createAccount"
#define AUTH_USERDETAILS @"/userdetails/userDetails/getUserDetails?userName="
#define CREATE_RECORD @"/ws/bioactivity/save?pActivityId=d57961a1-517d-42f2-8446-c373c0c59579"
#define UNIQUE_SPECIES_ID @"/ws/species/uniqueId"
#define DOCUMENT_UPLOAD_URL @"/ws/attachment/upload"
#define PROJECT_NAME @"OzAtlas Sightings"
#define PROJECT_ACTIVITY_NAME @"Single Sighting - Advanced"
#define SIGHTINGS_PROJECT_ID @"b3d8e243-1137-4d26-9e15-c5a6f90815eb"

// Species Proxy URL:
#define PROXY_SERVER @"http://ozatlas-proxy.ala.org.au"
#define SPECIES_GROUPS @"/proxy/exploreGroups" // ?lat=-37.9659145&lon=145.0715558&radius=532
#define SPECIES_GROUP @"/proxy/exploreGroup" // ?group=Animals&lat=-37.9659145&lon=145.0715558&radius=7&start=0&pageSize=10&common=true
#define SPECIES_THUMBNAIL @"/image/thumbnail" // /urn:lsid:biodiversity.org.au:afd.taxon:7d37e5ed-7232-4ae2-a423-6c63c9a118dd

#endif
