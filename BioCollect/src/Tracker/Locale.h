//
//  Locale.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 26/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

@interface Locale : NSObject {
    NSDictionary* translation;
    NSString* language;
}
-(NSString * ) getLanguage;
-(void) setLanguage : (NSString *) language;
-(NSString*) get : (NSString *) label;
@end
