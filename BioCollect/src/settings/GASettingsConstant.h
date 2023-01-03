#ifndef GASettingsConstant.h
#define GASettingsConstant.h
#define DEFAULT_TIMEOUT 20

#define REST_SERVER @"https://fieldcapture.ala.org.au"
#define ECODATA_SERVER @"https://ecodata.ala.org.au"
#define BIOCOLLECT_SERVER @"https://biocollect-test.ala.org.au"
#define LISTS_SERVER @"https://lists.ala.org.au"

#define LIST_PROJECT_ACTIVITIES @"/ws/survey/list"
#define AUTOCOMPLETE_URL @"https://bie.ala.org.au/ws/search.json?sort=scientificName&fq=taxonomicStatus:accepted&q="
//#define AUTH_SERVER  @"https://auth-test.ala.org.au"
#define AUTH_SERVER  @"https://auth-test.ala.org.au"
#define AUTH_REGISTER @"/userdetails/registration/createAccount"
#define AUTH_USERDETAILS @"/userdetails/userDetails/getUserDetails?userName="
#define AUTH_TOKEN @"/cas/oidc/token"
#define AUTH_REDIRECT_SIGNIN @"biocollect://auth/signin"
#define AUTH_REDIRECT_SIGNOUT @"biocollect://auth/signout"

#define UNIQUE_SPECIES_ID @"/ws/species/uniqueId"
#define DOCUMENT_UPLOAD_URL @"/ws/attachment/upload"
#define PROJECT_NAME @"OzAtlas Sightings"
#define PROJECT_ACTIVITY_NAME @"Single Sighting - Advanced"

//Sightings Prod config
#define CREATE_RECORD @"/ws/bioactivity/save?pActivityId="
#define SIGHTINGS_PROJECT_ID @""
#define SIGHTINGS_PROJECT_NAME_FACET @"fq=projectNameFacet:" 
#define CREATE_SITE @"/site/ajaxUpdate"

// Species Proxy URL:
#define PROXY_SERVER @"https://ozatlas-proxy.ala.org.au"
#define SPECIES_GROUPS @"/proxy/exploreGroups" // ?lat=-37.9659145&lon=145.0715558&radius=532
#define SPECIES_GROUP @"/proxy/exploreGroup" // ?group=Animals&lat=-37.9659145&lon=145.0715558&radius=7&start=0&pageSize=10&common=true
#define SPECIES_THUMBNAIL @"/image/thumbnail" // /urn:lsid:biodiversity.org.au:afd.taxon:7d37e5ed-7232-4ae2-a423-6c63c9a118dd

// Plist Configuration
#define APP_TYPE @"Bio_AppType"
#define APP_MENU @"Bio_Menu"

// Supported app view
#define OZATLAS_VIEW @"custom"
#define BIOCOLLECT_VIEW @"generic"
#define HUB_VIEW @"hubview"

//open id connect config
// #define CLIENT_ID @"biocollect-mobile-auth-debug"
#define COGNITO_REGION @"ap-southeast-2"
#define COGNITO_USER_POOL @"dqIVUS9bF"
#define CLIENT_ID @"5mqnuhdf75ru6fc153hjifdtsn"
#define CLIENT_SECRET @"u85789gnghdfb765"
#define SCOPE @"email openid profile ala/attrs ala/roles"

#endif
