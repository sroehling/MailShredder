//
//  SubjectFilterFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormInfoCreator.h"

@class SubjectFilter;

@interface SubjectFilterFormInfoCreator :NSObject <FormInfoCreator> 
{
	@private
		SubjectFilter *subjectFilter;
}

@property(nonatomic,retain) SubjectFilter *subjectFilter;

-(id)initWithSubjectFilter:(SubjectFilter*)theSubjectFilter;

@end
